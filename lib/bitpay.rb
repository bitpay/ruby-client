libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'bitpay/client'
require 'bitpay/version'

module BitPay

  # Location of SSL Certificate Authority File
  # As sourced from http://curl.haxx.se/ca/cacert.pem
  CA_FILE = File.join File.dirname(__FILE__), 'bitpay','cacert.pem'

  # Location of API
  #API_URI = 'https://test.bitpay.com/api/v2'
  API_URI = 'https://localhost:8088'
  #API_URI = 'https://test.bitpay.com'

  # User agent reported to API
  USER_AGENT = 'ruby-bitpay-client '+VERSION
end
