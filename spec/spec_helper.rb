require File.join File.dirname(__FILE__), '..', 'lib', 'bitpay', 'client.rb'
require File.join File.dirname(__FILE__), '..', 'lib', 'bitpay', 'key_utils.rb'
require File.join File.dirname(__FILE__), '..', 'lib', 'bitpay.rb'

require 'webmock/rspec'
require 'pry'

## Test Variables
#
PRIV_KEY = "16d7c3508ec59773e71ae728d29f41fcf5d1f380c379b99d68fa9f552ce3ebc3"
PUB_KEY = "0353a036fb495c5846f26a3727a28198da8336ae4f5aaa09e24c14a4126b5d969d"
SIN = "TfFVQhy2hQvchv4VVG4c7j4XPa2viJ9HrR8"