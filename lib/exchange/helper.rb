# -*- encoding : utf-8 -*-
require 'singleton'
require 'forwardable'

module Exchange
  
  # Helper Functions that get used throughout the gem can be placed here
  # @author Beat Richartz
  # @version 0.6
  # @since 0.3
  #
  class Helper
    include Singleton
    extend SingleForwardable
    
    # A helper function to assure a value is an instance of time
    # @param [Time, String, NilClass] arg The value to be asserted
    # @param [Hash] opts Options for assertion
    # @option opts [Symbol] :default a method that can be sent to Time if the argument is nil (:now for example)
    #
    def assure_time(arg=nil, opts={})
      if arg
        arg.kind_of?(Time) ? arg : Time.gm(*arg.split('-'))
      elsif opts[:default]
        Time.send(opts[:default])
      end
    end
    
    # Forwards the assure_time method to the instance using singleforwardable
    #
    def_delegator :instance, :assure_time
    
  end
  
end
