Capybara.javascript_driver = :poltergeist
Capybara.default_driver = :poltergeist
Capybara.default_wait_time = 10
Capybara.register_driver :poltergeist do |app|
	Capybara::Poltergeist::Driver.new(app, timeout: 60, js_errors: false, phantomjs_options: ['--ignore-ssl-errors=yes', '--ssl-protocol=TLSv1', '--web-security=false'])
end
