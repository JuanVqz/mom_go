source "https://rubygems.org"

gem "jbuilder"
gem "propshaft"
gem "puma", ">= 5.0"
gem "rails", "~> 8.0.4"
gem "solid_cache"
gem "solid_queue"
gem "sqlite3", ">= 2.1"
gem "thruster", require: false
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
