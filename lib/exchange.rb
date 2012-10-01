EXCHANGE_GEM_ROOT_PATH = File.dirname(__FILE__).sub(/\/lib/, '') if __FILE__.is_a?(String)

require 'rubygems'
require 'bigdecimal'
require 'open-uri'
require 'ostruct'
require 'json'
require 'exchange/version'
require 'exchange/gem_loader'
require 'exchange/helper'
require 'exchange/iso_4217'
require 'exchange/currency'
require 'exchange/external_api'
require 'exchange/cache'
require 'exchange/configuration'
require 'core_extensions/conversability'


module Exchange
  # The error that gets thrown if no conversion rate is available
  NoRateError       = Class.new StandardError
end
