module Exchange
  # The cache module. All Classes handling caching for this gem have to be placed here. Allows easy extension with own caching solutions
  # as shown in the example below.
  # @example Write your own caching module
  #   module Cache
  #     class MyCustomCache < Base
  #       class << self
  #         # a cache class has to have the class method "cached"
  #         def cached api, opts={}, &block
  #           # generate the key with key(api, opts[:at]) and you will get a unique key to store in your cache
  #           # Your code goes here
  #         end
  #       end
  #     end
  #   end
  #   # Now, you can configure your Caching solution in the configuration. The Symbol will get camelcased and constantized
  #   Exchange::Configuration.cache = :my_custom_cache
  #   # Have fun, and don't forget to write tests.
  
  module Cache
    
    # The base Class for all Caching operations. Essentially generates a helper function for all cache classes to generate a key
    # @author Beat Richartz
    # @version 0.1
    # @since 0.1
    
    class Base
      class << self
        
        protected
        
          # A Cache Key generator for the API Classes and the time
          # Generates a key which can handle expiration by itself
          # @param [Exchange::ExternalAPI::Subclass] api_class The API to store the data for
          # @param [optional, Time] time The time for which the data is valid
          # @return [String] A string that can be used as cache key
          # @example
          #   Exchange::Cache::Base.key(Exchange::ExternalAPI::CurrencyBot, Time.gm(2012,1,1)) #=> "Exchange_ExternalAPI_CurrencyBot_2012_1"
          
          def key(api, opts={})
            time          = assure_time(opts[:at], :default => :now)
            key_parts     = [ 'exchange',
                              api, 
                              time.year, 
                              time.yday, 
                              Exchange::Configuration.update == :hourly ? time.hour : ''
                            ] + (opts[:key_for]  || [])
            key_parts.join('_')
          end
          
          def assure_time(arg=nil, opts={})
            if arg
              arg.kind_of?(Time) ? arg : Time.gm(*arg.split('-'))
            elsif opts[:default]
              Time.send(opts[:default])
            end
          end
        
      end
    end
    CachingWithoutBlockError = Class.new(ArgumentError)
  end
end