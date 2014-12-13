require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'capybara'
require 'capybara/poltergeist'
require 'mongo'

require_relative 'config/constants.rb'
require_relative 'config/capybara.rb'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Bitpay Tasks"
namespace :bitpay do

  desc "Clear all claim codes from the test server."
  task :clear_claim_codes do
    puts "clearing claim codes"
    client = Mongo::MongoClient.new
    db     = client['bitpay-dev']
    coll   = db['tokenaccesses']
    coll.remove()
    puts "claim codes cleared"
  end

  desc "Clear rate limiters from local mongo host"

  task :clear_rate_limiters do
    puts "clearing rate limiters"
    client = Mongo::MongoClient.new
    db     = client['bitpay-dev']
    coll   = db['ratelimiters']
    coll.remove()
    puts "rate limiters cleared"
  end

  desc "Run specs and clear claim codes and rate_limiters."
  task :spec_clear => ['spec', 'clear_claim_codes', 'clear_rate_limiters']
  task :tests_clear => ['spec', 'clear_rate_limiters', 'clear_claim_codes', 'clear_local_files', 'features', 'clear_local_files', 'clear_claim_codes', 'clear_rate_limiters']

end
