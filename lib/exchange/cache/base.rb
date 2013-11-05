# -*- encoding : utf-8 -*-
require 'singleton'
require 'forwardable'

module Exchange
  # The cache module. All Classes handling caching for this gem have to be placed here. Allows easy extension with own caching solutions
  # as shown in the example below.
  # @example Write your own caching module
  #   module Cache
  #     class MyCustomCache < Base
  #       # A cache class has to have the method "cached".
  #       # The cache Base is a singleton and forwards the method "cached"
  #       # to the instance
  #       #
  #       def cached api, opts={}, &block
  #         # generate the storage with key(api, opts[:at]) and you will get a 
  #         # unique key to store in your cache
  #         #
  #         # Your code goes here
  #       end
  #     end
  #   end
  #
  #   # Now, you can configure your Caching solution in the configuration. The Symbol will get camelcased and constantized
  #   #
  #   Exchange.configuration.cache.subclass = :my_custom_cache
  #
  #   # Have fun, and don't forget to write tests.
  
  module Cache
    
    # The base Class for all Caching operations. Essentially generates a helper function for all cache classes to generate a key
    # @author Beat Richartz
    # @version 0.6
    # @since 0.1
    #
    class Base
      include Singleton
      extend SingleForwardable
      
      # returns The result of the block called
      # This method has to be the same in all the cache classes in order for the configuration binding to work
      # @param [Exchange::ExternalAPI::Subclass] api The API class the data has to be stored for
      # @param [Hash] opts the options to cache with
      # @option opts [Time] :at is ignored for filecache, other than that is the time of the cached rate
      # @option opts [Symbol] :cache_period The period to cache for
      # @yield [] This method takes a mandatory block with an arity of 0 and calls it if no cached result is available
      # @raise [CachingWithoutBlockError] an Argument Error when no mandatory block has been given
      #
      def cached api, opts={}, &block
        raise_caching_needs_block! unless block_given?

        block.call
      end
      
      # Forwards the cached method to the instance using singleforwardable
      #
      def_delegator :instance, :cached
                    
      protected
      
      # A Cache Key generator for the API Classes and the time
      # Generates a key which can handle expiration by itself
      # @param [Exchange::ExternalAPI::Subclass] api The API to store the data for
      # @param [Hash] opts The options for caching
      # @option opts [Array] :key_for An array of additional key elements
      # @option opts [Time] :at The timestamp for the key 
      # @return [String] A string that can be used as cache key
      # @example
      #   Exchange::Cache::Base.key(Exchange::ExternalAPI::OpenExchangeRates, Time.gm(2012,1,1)) #=> "Exchange_ExternalAPI_CurrencyBot_2012_1"
      #
      def key api, opts={}
        time          = helper.assure_time(opts[:at], :default => :now)
        ['exchange',
          api.to_s, 
          time.year.to_s, 
          time.yday.to_s, 
          config.expire == :hourly ? time.hour.to_s : nil,
          *(opts[:key_for] || [])
        ].compact.join('_')
      end
      
      # Convenience accessor to get to the cache configuration
      # @return [Exchange::Cache::Configuration] the current cache configuration
      #
      def config
        Exchange.configuration.cache
      end
      
      # Convenience accessor for the helper
      # @return [Exchange::Helper] the helper class
      #
      def helper
        @helper ||= Exchange::Helper
      end
      
      # Raise a caching needs a block error
      #
      def raise_caching_needs_block!
        raise CachingWithoutBlockError.new('Caching needs a block')
      end
        
    end
    
    # The error getting thrown if caching is attempted without a given block
    # @since 0.1
    # @version 0.1
    #
    CachingWithoutBlockError = Class.new ArgumentError
  end
end
