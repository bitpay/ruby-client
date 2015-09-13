require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'mongo'
require 'cucumber'
require 'cucumber/rake/task'
require_relative 'config/constants.rb'

RSpec::Core::RakeTask.new(:spec)

#task :default => :spec
task :default => :default_tasks

Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "features --format pretty"
end

desc "Run BitPay tests"
task :default_tasks do
  Rake::Task["spec"].invoke
  Rake::Task["features"].invoke
end

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

  desc "Clear local pem and token file"
  task :clear_local_files do
    puts "clearing local files"
    HOME_DIR = File.join(Dir.home, '.bitpay')
    KEY_FILE = File.join(HOME_DIR, 'bitpay.pem')
    TOKEN_FILE = File.join(HOME_DIR, 'tokens.json')
    File.delete(KEY_FILE) if File.file?(KEY_FILE)
    File.delete(TOKEN_FILE) if File.file?(TOKEN_FILE)
    puts "local files cleared"
  end

  desc "Clear tokens, rate limiters, and local files."
  task :clear do
    ["bitpay:clear_local_files", "bitpay:clear_rate_limiters", "bitpay:clear_claim_codes"].each{|task| Rake::Task[task].reenable}
    ["bitpay:clear_local_files", "bitpay:clear_rate_limiters", "bitpay:clear_claim_codes"].each{|task| Rake::Task[task].invoke}
  end

  desc "Run specs and clear claim codes and rate_limiters."
  task :spec_clear => ['spec', 'clear_claim_codes', 'clear_rate_limiters']

  desc "Run specs, clear data, run cukes, clear data"
  task :tests_clear do
    Rake::Task["bitpay:clear"].invoke
    Rake::Task["spec"].invoke
    Rake::Task["bitpay:clear"].reenable
    Rake::Task["bitpay:clear"].invoke
    Rake::Task["features"].invoke
    Rake::Task["bitpay:clear"].reenable
    Rake::Task["bitpay:clear"].invoke
  end

end
