# -*- encoding : utf-8 -*-
module Exchange
  
  # The external API module. Every class Handling an API has to be placed here and inherit from base. It has to call an api and define
  # a rates hash, an exchange base and a unix timestamp. The call will get cached automatically with the right structure
  # Allows for easy extension with an own api, as shown below
  # @author Beat Richartz
  # @version 0.1
  # @since 0.1
  # @example Easily connect to your custom API by writing an ExternalAPI Class
  #   module Exchange
  #     module ExternalAPI
  #
  #       # Inherit from Json to write for a json api, and the json gem is automatically loaded
  #       # Inherit from XML to write for an xml api, and nokogiri is automatically loaded
  #       # 
  #       class MyCustom < Json
  #         
  #         # Define here which currencies your API can handle
  #         #
  #         CURRENCIES = %W(usd chf).map(&:to_sym)
  #         
  #         # Every instance of ExternalAPI Class has to have an update function which 
  #         # gets the rates from the API
  #         #
  #         def update(opts={})
  #
  #           # assure that you will get a Time object for the historical dates
  #           #
  #           time = helper.assure_time(opts[:at]) 
  #
  #           # Call your API (shown here with a helper function that builds your API URL). 
  #           # Like this, your calls will get cached.
  #           #
  #           Call.new(api_url(time), :at => time) do |result|
  # 
  #           # Assign the currency conversion base.
  #           # Attention, this is readonly, self.base= won't work
  #           #
  #           @base                 = result['base']
  # 
  #           # assign the rates, this has to be a hash with the following format: 
  #           # {'USD' => 1.23242, 'CHF' => 1.34323}. 
  #           #
  #           # Attention, this is readonly, self.rates= won't work
  #           #
  #           @rates                = result['rates']
  # 
  #           # Timestamp the api call result. This may come in handy to assure you have 
  #           # the right result. 
  #           #
  #           # Attention, this is readonly, self.timestamp= won't work
  #           #
  #           @timestamp            = result['timestamp'].to_i
  #
  #         end
  #         
  #         private
  #
  #           def api_url(time)
  #             # code a helper function that builds your api url for the specified time
  #           end
  #
  #       end
  #     end
  #   end
  #
  #   # Now, you can configure your API in the configuration. The Symbol will get camelcased and constantized
  #   #
  #   Exchange::Configuration.api.subclass = :my_custom
  #
  #   # Have fun, and don't forget to write tests.
  #
  module ExternalAPI
    
    # The Base class of all External APIs, handling basic exchange rates and conversion
    # @author Beat Richartz
    # @version 0.1
    # @since 0.1
    #
    class Base
      
      # @attr_reader
      # @return [String] The currency which was the base for the rates
      #
      attr_reader :base
      
      # @attr_reader
      # @return [Integer] A unix timestamp for the rates, delivered by the API
      #
      attr_reader :timestamp
      
      # @attr_reader
      # @return [Hash] A Hash which delivers the exchange rate of every available currency to the base currency
      #
      attr_reader :rates
      
      # @attr_reader
      # @return [Exchange::Cache] The cache subclass
      attr_reader :cache
      
      # @attr_reader
      # @return [Exchange::Helper] The Exchange Helper
      attr_reader :helper
      
      # Initialize with a convenience accessor for the Cache and the api subclass
      # @param [Any] args The args to initialize with
      #
      def initialize *args
        @cache  = Exchange.configuration.cache.subclass
        @helper = Exchange::Helper.instance
        
        super *args
      end
      
      # Delivers an exchange rate from one currency to another with the option of getting a historical exchange rate. This rate
      # has to be multiplied with the amount of the currency which you define in from
      # @param [String, Symbol] from The currency which should be converted
      # @param [String, Symbol] to The currency which the should be converted to
      # @param [Hash] opts The options to throw at the rate
      # @option opts [Time] :at Define a Time here to get a historical rate
      # @return [Float] The exchange rate for those two currencies
      # @example Get the exchange rate for a conversion from USD to EUR at March 23 2009
      #   Exchange::ExternalAPI::Base.new.rate(:usd, :eur, :at => Time.gm(3,23,2009))
      #     #=> 1.232231231
      #
      def rate from, to, opts={}
        rate = cache.cached(self.class, opts.merge(:key_for => [from, to])) do
          update(opts)
          
          rate_from   = rates[from]
          rate_to     = rates[to]
          
          test_for_rates_and_raise_if_nil [from, rate_from], [to, rate_to], opts[:at]
          
          rate_to / rate_from
        end
        
        rate.is_a?(BigDecimal) ? rate : BigDecimal.new(rate.to_s)
      end
      
      # Converts an amount of one currency into another
      # @param [Fixed, Float] amount The amount of the currency to be converted
      # @param [String, Symbol] from The currency to be converted from
      # @param [String, Symbol] to The currency which should be converted to
      # @param [Hash] opts Options to throw at the conversion
      # @option opts [Time] :at Define a Time here to convert at a historical rate
      # @return [Float] The amount in the currency converted to, rounded to two decimals
      # @example Convert 23 EUR to CHF at the rate of December 1 2011
      #   Exchange::ExternalAPI::Base.new.convert(23, :eur, :chf, :at => Time.gm(12,1,2011))
      #     #=> 30.12
      #
      def convert amount, from, to, opts={}
        amount * rate(from, to, opts)
      end
      
      # Converts an array to a hash
      # @param [Array] array The array to convert
      # @return [Hash] The hash out of the array
      #
      def to_hash! array
        Hash[*array]
      end
      
      # Test for a error to be thrown when no rates are present
      # @param [String] rate_from The rate from which should be converted
      # @param [String] rate_to The rate to which should be converted
      # @param [Time] time The time at which should be converted
      # @raise [NoRateError] An error indicating that there is no rate present when there is no rate present
      #
      def test_for_rates_and_raise_if_nil rate_from, rate_to, time=nil
        raise NoRateError.new("No rates where found for #{rate_from[0]} to #{rate_to[0]} #{'at ' + time.to_s if time}") unless rate_from[1] && rate_to[1]
      end
      
      protected
      
      # Convenience accessor to api configuration
      # @return [Exchange::ExternalAPI::Configuration] the current configuration
      #
      def config
        @config ||= Exchange.configuration.api
      end
      
      # Convenience accessor to the cache configuration
      # @return [Exchange::Cache::Configuration] the current configuration
      #
      def cache_config
        @cache_config ||= Exchange.configuration.cache
      end
      
    end
  end
end
