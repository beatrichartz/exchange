# -*- encoding : utf-8 -*-
module Exchange
  module ExternalAPI
    
    # The json base class takes care of JSON apis. 
    # This may serve as a base for some operations which might be common to the json apis
    # @author Beat Richartz
    # @version 0.6
    # @since 0.6
    #
    class Json < Base
      
      # Initializer, essentially takes the arguments passed to initialization, loads json on the way
      # and passes the arguments to the api base
      #
      def initialize *args
        Exchange::GemLoader.new('json').try_load unless defined?(JSON)
        super *args
      end
      
    end
  end
end
