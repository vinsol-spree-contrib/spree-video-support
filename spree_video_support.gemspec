# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_video_support'
  s.version     = '3.1.0'
  s.summary     = 'Adds video support for spree customers'
  s.description = 'Adds video support for spree customers'
  s.required_ruby_version = '>= 2.0.0'

  s.author    = 'Vinsol'
  s.email     = 'rai@vinsol.com'
  # s.homepage  = 'http://www.spreecommerce.com'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 3.1.0'

  s.add_development_dependency 'capybara', '~> 2.4'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.5'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 3.1'
  s.add_development_dependency 'sass-rails', '~> 5.0.0.beta1'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'shoulda-matchers', '~> 3.0'
  s.add_development_dependency 'shoulda-callback-matchers', '~> 1.1'
  s.add_development_dependency 'byebug', '~> 8.2'
end
