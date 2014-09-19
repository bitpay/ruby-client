libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'bitpay/client'
require 'bitpay/version'

module BitPay

  # Location of SSL Certificate Authority File
  # As sourced from http://curl.haxx.se/ca/cacert.pem
  CA_FILE = File.join File.dirname(__FILE__), 'bitpay','cacert.pem'

  # Location of API
  API_URI = 'https://bitpay.com'
  TEST_API_URI = 'https://test.bitpay.com'
  CLIENT_REGISTRATION_PATH = '/api-access-request'
  
  # Location for API Credentials
  BITPAY_CREDENTIALS_DIR = File.join(Dir.home, ".bitpay")
  PRIVATE_KEY_FILE = 'api.key'
  PRIVATE_KEY_PATH = File.join(BITPAY_CREDENTIALS_DIR, PRIVATE_KEY_FILE)

  # User agent reported to API
  USER_AGENT = 'ruby-bitpay-client '+VERSION
  
  MISSING_KEY = 'No Private Key specified.  Pass priv_key or set ENV variable PRIV_KEY'
  
  class BitPayError < StandardError; end
  
end
