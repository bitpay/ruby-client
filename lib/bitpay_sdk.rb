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
  

  # User agent reported to API
  USER_AGENT = 'BitPay_Ruby_Client_v'+VERSION
  
  class BitPayError < StandardError; end
  class ConnectionError < Errno::ECONNREFUSED; end
  
end
