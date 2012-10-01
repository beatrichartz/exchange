source "http://rubygems.org"
# Add dependencies required to use your gem here.
# Example:
#gem "nokogiri",   ">= 1.5.0"
#gem "json",       ">= 1.6.5"
#gem "memcached",  ">= 1.3.0"
#gem "redis",      ">= 2.2.0"

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.

gemspec

group :development do
  gem "yard",       "~> 0.7.4"
  gem "bundler",    ">= 1.0.0"
  gem "jeweler",    "~> 1.8.3"
end

group :test do
  gem "nokogiri",   ">= 1.5.0", :require => false
  gem "dalli",      ">= 2.0.0", :require => false
  gem "redis",      ">= 2.2.0", :require => false
  gem "shoulda",    ">= 0"
  gem "rspec"
end
