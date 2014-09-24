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


RSpec.configure do |config|
  config.before :each do |example|
    WebMock.allow_net_connect! if example.metadata[:type] == :feature 
  end
end
