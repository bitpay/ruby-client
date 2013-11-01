require 'addressable/uri'
require 'json'
require 'minitest/autorun'
require 'webmock'
require './lib/bitpay.rb'

include WebMock::API
