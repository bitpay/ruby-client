libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'active_support/core_ext/object/to_query'
require 'json'
require 'uri'
require 'net/https'
require 'bitpay/client'
require 'bitpay/version'

module BitPay
  # Location of the directory of SSL certificates.
  DATA_DIR = File.join File.dirname(__FILE__), 'bitpay', 'data'

  # SSL Certificate
  CERT = File.join DATA_DIR, 'cert.pem'

  # Location of API
  API_URI = 'https://bitpay.com/api'

  # User agent reported to API
  USER_AGENT = 'ruby-bitpay-client '+VERSION
end
