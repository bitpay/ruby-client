require 'pry'
require 'fileutils' 

require File.join File.dirname(__FILE__), '..', '..', 'lib', 'bitpay_sdk.rb'
require_relative '../../config/constants.rb'


module BitPay
  # Location for API Credentials
  BITPAY_CREDENTIALS_DIR = File.join(Dir.home, ".bitpay")
  PRIVATE_KEY_FILE = 'bitpay.pem'
  PRIVATE_KEY_PATH = File.join(BITPAY_CREDENTIALS_DIR, PRIVATE_KEY_FILE)
  TOKEN_FILE = 'tokens.json'
  TOKEN_FILE_PATH = File.join(BITPAY_CREDENTIALS_DIR, TOKEN_FILE)
end

def new_client_from_stored_values
  pem = ENV['BITPAYPEM'].gsub("\\n", "\n")
  BitPay::SDK::Client.new(api_uri: APIURI, pem: pem, insecure: true)
end

def get_claim_code_from_server client
  token = client.get(path: "tokens")["data"].select{|tuple| tuple["merchant"]}.first.values.first
  client.post(path: "tokens", token: token, params: {facade: "pos"})["data"][0]["pairingCode"]
end

def client_has_tokens client
  data = client.get(path: "tokens")["data"]
  data.select{|tuple| tuple["pos"]}.any? && data.select{|tuple| tuple["merchant"]}.any?
end

