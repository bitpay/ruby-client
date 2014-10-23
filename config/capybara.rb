Capybara.javascript_driver = :poltergeist
Capybara.default_driver = :poltergeist
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false, phantomjs_options: ['--ignore-ssl-errors=yes', '--ssl-protocol=TLSv1'] )
end
