EXCHANGE_GEM_ROOT_PATH = File.dirname(__FILE__).sub(/\/lib/, '') if __FILE__.is_a?(String) 

require 'bigdecimal'
require 'open-uri'
require 'bundler'
require 'json'
require 'nokogiri'
require 'redis'
require 'memcached'
require 'exchange/helper'
require 'exchange/configuration'
require 'exchange/iso_4217'
require 'exchange/currency'
require 'exchange/external_api'
require 'exchange/cache'
require 'core_extensions/conversability'

# The error that gets thrown if no conversion rate is available
NoRateError = Class.new(StandardError)