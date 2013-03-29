# -*- encoding : utf-8 -*-
module Exchange
  module ExternalAPI
    
    # The xml base class takes care of XML apis. It assumes you would want to use nokogiri as a parser and preloads the gem
    # Also, this may serve as a base for some operations which might be common to the xml apis
    # @author Beat Richartz
    # @version 0.6
    # @since 0.6
    #
    class XML < Base
      
      # Initializer, essentially takes the arguments passed to initialization, loads nokogiri on the way
      # and passes the arguments to the api base
      #
      def initialize *args
        Exchange::GemLoader.new('nokogiri').try_load unless defined?(Nokogiri)
        super *args
      end
      
    end
  end
end
