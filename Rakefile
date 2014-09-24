require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'capybara'
require 'capybara/poltergeist'

require_relative 'config/constants.rb'
require_relative 'config/capybara.rb'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Bitpay Tasks"
namespace :bitpay do
  desc "Clear all claim codes from the test server."
  task :clear_claim_codes do
    Capybara.visit ROOT_ADDRESS
    Capybara.click_link('Login')
    Capybara.fill_in 'email', :with => TEST_USER
    Capybara.fill_in 'password', :with => TEST_PASS
    Capybara.click_button('loginButton')
    Capybara.click_link "My Account"
    Capybara.click_link "API Tokens", match: :first
    while Capybara.page.has_selector?(".token-claimcode") || Capybara.page.has_selector?(".token-requiredsins-key") do
      Capybara.page.find(".api-manager-actions-edit", match: :first).click
      Capybara.page.find(".api-manager-actions-revoke", match: :first).click
      Capybara.click_button("Confirm Revoke")
      # this back and forth bit is here because no other reload mechanism worked, and without it the task errors out: either because it can't find the revoke button or it finds multiple elements at each click point
      Capybara.page.go_back
      Capybara.click_link "API Tokens", match: :first
    end
  end

  desc "Run specs and clear claim codes."
  task :spec_clear => ['spec', 'clear_claim_codes']

end
