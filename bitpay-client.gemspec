require './lib/bitpay/version.rb'
Gem::Specification.new do |s|
  s.name = 'bitpay-client'
  s.version = BitPay::VERSION
  s.authors = 'Bitpay, Inc.'
  s.email = 'info@bitpay.com'
  s.homepage = 'https://github.com/bitpay/ruby-client'
  s.summary = 'Official ruby client library for the BitPay API'
  s.description = 'Powerful, flexible, lightweight, thread-safe interface to the BitPay developers API'

  s.files = `git ls-files`.split("\n")
  s.require_paths = %w[lib]
  s.rubyforge_project = s.name
  s.required_rubygems_version = '>= 1.3.4'

  s.add_dependency 'json'
  s.add_dependency 'rack',    '>= 0'
  s.add_dependency 'ecdsa'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec'
end