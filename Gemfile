#source 'http://ruby.taobao.org'
source 'https://rubygems.org'

gem 'rails', '3.2.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platform => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

gem 'chinese_pinyin'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
#

gem 'delayed_job_active_record'
gem "daemons"

group :development, :test do
  gem "rspec-rails", "~> 2.10.1"
  gem "factory_girl_rails", "~> 3.2.0"
  gem "guard-rspec", "~> 0.7.0"
  gem "annotate", "2.5.0"
end

group :test do
  gem "faker", "~> 1.0.1"
  gem "capybara", "~> 1.1.2"
  gem "database_cleaner", "~> 0.7.2"
  gem "launchy", "~> 2.1.0"
  gem 'rb-inotify', '0.8.8'
  gem 'libnotify', '0.5.9'
  gem 'guard-spork', '0.3.2'
  gem 'spork', '~> 0.9.2'
  gem 'email_spec'
end
