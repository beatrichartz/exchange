module Exchange
  
  # The current version of the exchange gem
  #
  VERSION = '0.7.3'
  
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
  
end