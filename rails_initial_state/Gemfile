source 'https://rubygems.org'

gem 'rails', '3.2.9'
gem 'pg'

gem 'json'
gem "formtastic", "~> 2.2.1"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.5'
  gem 'coffee-rails', '~> 3.2.2'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
  gem "bootstrap-sass", "~> 2.2.2.0"
end

group :development, :test do
  gem "guard"
  gem "open4", "~> 1.3.0"
  gem "popen4", "~> 0.1.2"
  gem 'rb-fsevent', '~> 0.9.2'
  gem 'capybara'
end

group :development do
  gem 'guard-livereload'
  gem 'rack-livereload'
end

group :test do
  gem "spork", '1.0.0rc3'
  gem 'guard-spork'
  gem 'vcr'
  gem 'fakeweb'
  gem 'timecop'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
end

gem 'jquery-rails'
gem 'rspec-rails'
gem 'haml'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use debugger
# gem 'ruby-debug'
