require './lib/bitpay/version.rb'
Gem::Specification.new do |s|
  s.name = 'bitpay-client'
  s.version = BitPay::VERSION
  s.licenses = ['MIT']
  s.authors = 'Bitpay, Inc.'
  s.email = 'sales-engineering@bitpay.com'
  s.homepage = 'https://github.com/bitpay/ruby-client'
  s.summary = 'Official Ruby library for the BitPay API'
  s.description = 'Powerful, flexible, lightweight, thread-safe interface to the BitPay developers API'

  s.files = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
  s.rubyforge_project = s.name
  s.required_rubygems_version = '>= 2.6'
  s.required_ruby_version = '>= 2.1'
  s.bindir        = 'bin'
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_dependency 'bitpay-key-utils', '>= 2.2'

  s.add_development_dependency 'rack', '~> 2.1.4'
  s.add_development_dependency 'rake', '10.3.2'
  s.add_development_dependency 'webmock', '1.18.0'
  s.add_development_dependency 'pry', '0.10.1'
  s.add_development_dependency 'pry-byebug', '2.0.0'
  s.add_development_dependency 'pry-rescue', '1.4.1'
  s.add_development_dependency 'cucumber', '~> 1.3.17'
  s.add_development_dependency 'airborne', '0.0.20'
  s.add_development_dependency 'rspec', '3.1.0'
  s.add_development_dependency 'mongo', '~> 2.6'
  s.add_development_dependency 'coveralls'
end
