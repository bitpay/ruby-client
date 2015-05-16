require 'capybara/poltergeist'
require 'pry'
require 'fileutils' 

require File.join File.dirname(__FILE__), '..', '..', 'lib', 'bitpay_sdk.rb'
require_relative '../../config/constants.rb'
require_relative '../../config/capybara.rb'


module BitPay
  # Location for API Credentials
  BITPAY_CREDENTIALS_DIR = File.join(Dir.home, ".bitpay")
  PRIVATE_KEY_FILE = 'bitpay.pem'
  PRIVATE_KEY_PATH = File.join(BITPAY_CREDENTIALS_DIR, PRIVATE_KEY_FILE)
  TOKEN_FILE = 'tokens.json'
  TOKEN_FILE_PATH = File.join(BITPAY_CREDENTIALS_DIR, TOKEN_FILE)
end

# Lots of sleeps in here to deal with finicky transitions and PhantomJS
def get_claim_code_from_server
  Capybara::visit ROOT_ADDRESS
  log_in unless logged_in
  Capybara::visit DASHBOARD_URL
  raise "Bad Login" unless Capybara.current_session.current_url == DASHBOARD_URL
  Capybara::visit "#{ROOT_ADDRESS}/api-tokens"
  Capybara::find(".token-access-new-button").find(".btn").find(".icon-plus", match: :first).trigger("click")
  sleep 0.50
  Capybara::find(".token-access-new-button-wrapper").find_by_id("token-new-form", visible: true).find(".btn").trigger("click")
  Capybara::find(".token-claimcode", match: :first).text
end

def approve_token_on_server(pairing_code)
  Capybara::visit ROOT_ADDRESS
  log_in unless logged_in
  Capybara::visit DASHBOARD_URL
  raise "Bad Login" unless Capybara.current_session.current_url == DASHBOARD_URL
  Capybara::visit "#{ROOT_ADDRESS}/api-tokens"
  Capybara::fill_in 'pairingCode', :with => pairing_code
  Capybara::click_button "Find"
  Capybara::click_button "Approve"
end

def log_in
  Capybara::visit "#{ROOT_ADDRESS}/dashboard/login/"
  Capybara::fill_in 'email', :with => TEST_USER
  Capybara::fill_in 'password', :with => TEST_PASS
  Capybara::click_on('Login')
  Capybara::find(".ion-gear-a", match: :first)
end

def new_paired_client
  claim_code = get_claim_code_from_server
  pem = BitPay::KeyUtils.generate_pem
  client = BitPay::SDK::Client.new(api_uri: ROOT_ADDRESS, pem: pem, insecure: true)
  client.pair_pos_client(claim_code)
  client
end

def new_client_from_stored_values
  if File.file?(BitPay::PRIVATE_KEY_PATH) && File.file?(BitPay::TOKEN_FILE_PATH)
    token = get_token_from_file
    pem = File.read(BitPay::PRIVATE_KEY_PATH)
    client = BitPay::SDK::Client.new(pem: pem, tokens: token, insecure: true, api_uri: ROOT_ADDRESS )
    unless client.verify_tokens then 
      raise "Locally stored tokens are invalid, please remove #{BitPay::TOKEN_FILE_PATH}" end
  else
    pem = BitPay::KeyUtils.generate_pem
    client = BitPay::SDK::Client.new(api_uri: ROOT_ADDRESS, pem: pem, insecure: true)
    sleep 1 # rate limit compliance
    response = client.pair_client({facade: 'merchant'})
    pairing_code = response.first["pairingCode"]
    token = response  #.first["token"]
    approve_token_on_server(pairing_code)
    

    FileUtils.mkdir_p(BitPay::BITPAY_CREDENTIALS_DIR)
    File.write(BitPay::PRIVATE_KEY_PATH, pem)
    File.write(BitPay::TOKEN_FILE_PATH, JSON.generate(token))
  end   
  client
end

def get_token_from_file
  token = JSON.parse(File.read(BitPay::TOKEN_FILE_PATH))[0]
  {token['facade'] => token['token']}
end

def logged_in
  Capybara::has_link?('Dashboard')
end
