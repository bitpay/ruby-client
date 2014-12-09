# license Copyright 2011-2014 BitPay, Inc., MIT License
# see http://opensource.org/licenses/MIT
# or https://github.com/bitpay/php-bitpay-client/blob/master/LICENSE

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
  PRIVATE_KEY_FILE = 'bitpay.pem'
  PRIVATE_KEY_PATH = File.join(BITPAY_CREDENTIALS_DIR, PRIVATE_KEY_FILE)

  # User agent reported to API
  USER_AGENT = 'ruby-bitpay-client '+VERSION
  
  MISSING_KEY = 'No Private Key specified.  Pass priv_key or set ENV variable PRIV_KEY'
  MISSING_PEM = 'No pem file specified. Pass pem or set ENV variable BITPAY_PEM'
  
  class BitPayError < StandardError; end
  class ArgumentError < ArgumentError; end
  class ConnectionError < Errno::ECONNREFUSED; end
  
end
