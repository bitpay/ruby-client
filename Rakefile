require "rake/testtask"

desc "Run all tests"
Rake::TestTask.new do |t|
  t.libs << "spec"
  t.test_files = FileList['test/*_test.rb','test/bitpay/*_test.rb']
  t.verbose = true
end

task :default => :test