libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'json'
require 'uri'
require 'net/https'
require 'bitpay/client'
require 'bitpay/version'

module BitPay
  DATA_DIR = File.join File.dirname(__FILE__), 'bitpay', 'data'
  CERT     = File.join DATA_DIR, 'cert.pem'
  KEY      = File.join DATA_DIR, 'key.pem'
  API_URI  = 'https://bitpay.com/api'
  USER_AGENT = 'bitpay-ruby '+VERSION
end