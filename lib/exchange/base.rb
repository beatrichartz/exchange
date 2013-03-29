# -*- encoding : utf-8 -*-
module Exchange
  
  # The current version of the exchange gem
  #
  VERSION = '0.12.0'
  
  # The root installation path of the gem
  # @version 0.5
  # @since 0.1
  #
  ROOT_PATH = File.dirname(__FILE__).to_s.sub(/\/lib\/exchange\/?$/, '')
  
  # The error that gets thrown if no conversion rate is available
  # @version 0.1
  # @since 0.1
  #
  NoRateError       = Class.new StandardError
  
  # The error that gets thrown if the given currency is not a currency
  # @version 0.10
  # @since 0.10
  #
  NoCurrencyError   = Class.new(ArgumentError)
  
end
