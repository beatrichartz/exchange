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
  #       class MyCustom < Base
  #         # Define here which currencies your API can handle
  #         CURRENCIES = %W(usd chf)
  #         
  #         # Every instance of ExternalAPI Class has to have an update function which gets the rates from the API
  #         def update(opts={})
  #           # assure that you will get a Time object for the historical dates
  #           time = Exchange::Helper.assure_time(opts[:at]) 
  #
  #           # call your API (shown here with a helper function that builds your API URL). Like this, your calls will get cached.
  #           Call.new(api_url(time), :at => time) do |result|
  #
  #             # assign the currency conversion base, attention, this is readonly, so don't do self.base = 
  #             @base                 = result['base']
  #
  #             # assign the rates, this has to be a hash with the following format: {'USD' => 1.23242, 'CHF' => 1.34323}. Attention, this is readonly.
  #             @rates                = result['rates']
  #
  #             # timestamp the api call result. This may come in handy to assure you have the right result. Attention, this is readonly.
  #             @timestamp            = result['timestamp'].to_i
  #           end
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
  #   # Now, you can configure your API in the configuration. The Symbol will get camelcased and constantized
  #   Exchange::Configuration.api = :my_custom
  #   # Have fun, and don't forget to write tests.
  
  module ExternalAPI
    
    # The Base class of all External APIs, handling basic exchange rates and conversion
    # @author Beat Richartz
    # @version 0.1
    # @since 0.1
    
    class Base
      # @attr_reader
      # @return [String] The currency which was the base for the rates
      attr_reader :base
      
      # @attr_reader
      # @return [Integer] A unix timestamp for the rates, delivered by the API
      attr_reader :timestamp
      
      # @attr_reader
      # @return [Hash] A Hash which delivers the exchange rate of every available currency to the base currency
      attr_reader :rates
      
      
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
      def rate(from, to, opts={})
        rate = Configuration.cache_class.cached(Exchange::Configuration.api, opts.merge(:key_for => [from, to])) do
          update(opts)
          rate_from   = self.rates[to.to_s.upcase]
          rate_to     = self.rates[from.to_s.upcase]
          raise NoRateError.new("No rates where found for #{from} to #{to} #{'at ' + opts[:at].to_s if opts[:at]}") unless rate_from && rate_to
          rate_from / rate_to
        end
        BigDecimal.new(rate.to_s)
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
      def convert(amount, from, to, opts={})
        amount * rate(from, to, opts)
      end
        
    end
  end
end