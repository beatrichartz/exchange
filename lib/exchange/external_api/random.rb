# -*- encoding : utf-8 -*-
module Exchange
  module ExternalAPI
    
    # The Random API class, which is only intended for use in development mode. Returns random exchange rates.
    # @author Beat Richartz
    # @version 1.0
    # @since 1.0
    #
    class Random < Base
      
      CURRENCIES           = Exchange::ISO.currencies
      RANDOM_RATES         = lambda { Hash[*CURRENCIES.map{|c| [c, rand] }.flatten] }
      
      # Updates the rates with new random ones
      # The call gets cached for a maximum of 24 hours.
      # @version 0.7
      # @param [Hash] opts Options to define for the API Call
      # @option opts [Time, String] :at a historical date to get the exchange rates for
      # @example Update the currency bot API to use the file of March 2, 2010
      #   Exchange::ExternalAPI::XavierMedia.new.update(:at => Time.gm(3,2,2010))
      #
      def update opts={}
        @base                 = :usd
        @rates                = RANDOM_RATES.call
        @timestamp            =  Time.now.to_i
      end

    end
  end
end