source 'http://rubygems.org'

gem 'rails', '3.2.13'
gem 'actionpack', '3.2.13' # added b/c google_charts gem isn't being a good citizen in gemspec

gem 'pg'
gem 'foreman'
gem 'thin'

gem 'cancan'
gem 'activeadmin', :git => 'git://github.com/macfanatic/active_admin.git', branch: 'stable_batch_actions'
gem 'sass-rails'
gem "meta_search",    '>= 1.1.0.pre'

gem 'ckeditor_rails', :require => 'ckeditor-rails'
gem 'haml'

gem 'paper_trail'
gem 'stringex'
gem 'settingslogic'

gem 'mysql2'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rspec-rails'
end

# Assets
gem 'carrierwave'
gem 'mini_magick'

# Validation helpers
gem 'validates_as_email_address'
gem 'date_validator'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'therubyracer'
end

gem 'jquery-rails'

group :test do
  # Pretty printed test output
  gem 'turn', '0.8.2', :require => false
  gem 'rspec-rails'
  gem 'factory_girl'
end

# Charting
gem 'google_charts'
