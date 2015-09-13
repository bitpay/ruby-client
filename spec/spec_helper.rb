require 'webmock/rspec'
require 'pry'
require 'coveralls'
Coveralls.wear!

require File.join File.dirname(__FILE__), '..', 'lib', 'bitpay_sdk.rb'
require_relative '../config/constants.rb'

#
## Test Variables
#
PEM = "-----BEGIN EC PRIVATE KEY-----\nMHQCAQEEICg7E4NN53YkaWuAwpoqjfAofjzKI7Jq1f532dX+0O6QoAcGBSuBBAAK\noUQDQgAEjZcNa6Kdz6GQwXcUD9iJ+t1tJZCx7hpqBuJV2/IrQBfue8jh8H7Q/4vX\nfAArmNMaGotTpjdnymWlMfszzXJhlw==\n-----END EC PRIVATE KEY-----\n"

PUB_KEY = '038d970d6ba29dcfa190c177140fd889fadd6d2590b1ee1a6a06e255dbf22b4017'
CLIENT_ID = "TeyN4LPrXiG5t2yuSamKqP3ynVk3F52iHrX"

def generate_code(number)
  legal_map = [*'A'..'Z'] + [*'a'..'z'] + [*0..9]
  Array.new(number) { legal_map.sample }.join
end

  
def an_illegal_claim_code
  short_code = generate_code(rand(6))
  long_code  = generate_code(rand(8..25))
  [nil, short_code, long_code].sample
end

## Gets JSON responses from the fixtures directory
#
def get_fixture(name)
  #JSON.parse(File.read(File.expand_path("../fixtures/#{name}",  __FILE__)))
  File.read(File.expand_path("../fixtures/#{name}",  __FILE__))
end
