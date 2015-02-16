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
  sleep 2
  Capybara::visit ROOT_ADDRESS
  sleep 2
  log_in unless logged_in
  sleep 1
  Capybara::visit DASHBOARD_URL
  sleep 1
  raise "Bad Login" unless Capybara.current_session.current_url == DASHBOARD_URL
  Capybara::visit "#{ROOT_ADDRESS}/dashboard/merchant/api-tokens"
  sleep 4 # Wait for frame to transition
  Capybara::current_session.within_frame 0 do
    Capybara::find(".token-access-new-button").find(".btn").find(".icon-plus").click
    sleep 2
    Capybara::find_button("Add Token", match: :first).click
    sleep 2
    claim_code = Capybara::find(".token-claimcode", match: :first).text
    return claim_code
  end
end

def log_in
  Capybara::click_link('Login')
  Capybara::fill_in 'email', :with => TEST_USER
  Capybara::fill_in 'password', :with => TEST_PASS
  Capybara::click_button('Login')
end

def new_client_from_stored_values
  if File.file?(BitPay::PRIVATE_KEY_PATH) && File.file?(BitPay::TOKEN_FILE_PATH)
    token = get_token_from_file
    pem = File.read(BitPay::PRIVATE_KEY_PATH)
    client = BitPay::SDK::Client.new(pem: pem, tokens: token, insecure: true, api_uri: ROOT_ADDRESS )
    unless client.verify_tokens then 
      raise "Locally stored tokens are invalid, please remove #{BitPay::TOKEN_FILE_PATH}" end
  else
    claim_code = get_claim_code_from_server
    pem = BitPay::KeyUtils.generate_pem
    client = BitPay::SDK::Client.new(api_uri: ROOT_ADDRESS, pem: pem, insecure: true)
    sleep 1 # rate limit compliance
    token = client.pair_pos_client(claim_code)
    FileUtils.mkdir_p(BitPay::BITPAY_CREDENTIALS_DIR)
    File.write(BitPay::PRIVATE_KEY_PATH, pem)
    File.write(BitPay::TOKEN_FILE_PATH, JSON.generate(token))
  end   
  client
end

def get_token_from_file
  token = JSON.parse(File.read(BitPay::TOKEN_FILE_PATH))['data'][0]
  {token['facade'] => token['token']}
end

def logged_in
  Capybara::has_link?('Dashboard')
end
