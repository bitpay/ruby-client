require './lib/bitpay/version.rb'
Gem::Specification.new do |s|
  s.name = 'bitpay-client'
  s.version = BitPay::VERSION
  s.licenses = ['MIT']
  s.authors = 'Bitpay, Inc.'
  s.email = 'info@bitpay.com'
  s.homepage = 'https://github.com/bitpay/ruby-client'
  s.summary = 'Official ruby client library for the BitPay API'
  s.description = 'Powerful, flexible, lightweight, thread-safe interface to the BitPay developers API'

  s.files = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
  s.rubyforge_project = s.name
  s.required_rubygems_version = '>= 1.3.4'
  s.required_ruby_version = '~> 2.1'
  s.bindir        = 'bin'
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_dependency 'json'
  s.add_dependency 'rack',    '>= 0'
  s.add_dependency 'ecdsa'
  s.add_dependency 'commander'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'pry-rescue'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'airborne'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'mongo'
end
