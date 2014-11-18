require 'webmock/rspec'
require 'pry'
require 'capybara/rspec'
require 'capybara/poltergeist'

require File.join File.dirname(__FILE__), '..', 'lib', 'bitpay', 'client.rb'
require File.join File.dirname(__FILE__), '..', 'lib', 'bitpay', 'key_utils.rb'
require File.join File.dirname(__FILE__), '..', 'lib', 'bitpay.rb'
require_relative '../config/constants.rb'
require_relative '../config/capybara.rb'

#
## Test Variables
#
PEM = "-----BEGIN EC PRIVATE KEY-----\nMHQCAQEEICg7E4NN53YkaWuAwpoqjfAofjzKI7Jq1f532dX+0O6QoAcGBSuBBAAK\noUQDQgAEjZcNa6Kdz6GQwXcUD9iJ+t1tJZCx7hpqBuJV2/IrQBfue8jh8H7Q/4vX\nfAArmNMaGotTpjdnymWlMfszzXJhlw==\n-----END EC PRIVATE KEY-----\n"

PUB_KEY = '038d970d6ba29dcfa190c177140fd889fadd6d2590b1ee1a6a06e255dbf22b4017'
CLIENT_ID = "TeyN4LPrXiG5t2yuSamKqP3ynVk3F52iHrX"


RSpec.configure do |config|
  config.before :each do |example|
    WebMock.allow_net_connect! if example.metadata[:type] == :feature 
  end
end
