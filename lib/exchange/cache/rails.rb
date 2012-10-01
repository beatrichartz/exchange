module Exchange
  module Cache
    # @author Beat Richartz
    # A class that cooperates with rails to cache the data from the exchange api in rails
    # 
    # @version 0.1
    # @since 0.1
    # @example Activate caching via rails by setting the cache in the configuration to :rails
    #   Exchange::Configuration.define do |c| 
    #     c.cache = :rails
    #   end
    class Rails < Base
        
      # returns a Rails cache client. This has not to be stored since rails already memoizes it.
      # Use this client to access rails cache data. For further explanation of use visit the rails documentation
      # @example
      #   Exchange::Cache::Rails.client.set('FOO', 'BAR')
      # @return [ActiveSupport::Cache::Subclass] an instance of the rails cache class (presumably a subclass of ActiveSupport::Cache)
      
      def client
        Exchange::GemLoader.new('rails').try_load unless defined?(::Rails)
        ::Rails.cache
      end
      
      # returns either cached data from the memcached client or calls the block and caches it in rails cache.
      # This method has to be the same in all the cache classes in order for the configuration binding to work
      # @param [Exchange::ExternalAPI::Subclass] api The API class the data has to be stored for
      # @param [Hash] opts the options to cache with
      # @option opts [Time] :at the historic time of the exchange rates to be cached
      # @yield [] This method takes a mandatory block with an arity of 0 and calls it if no cached result is available
      # @raise [CachingWithoutBlockError] an Argument Error when no mandatory block has been given
      
      def cached api, opts={}, &block
        raise CachingWithoutBlockError.new('Caching needs a block') unless block_given?
        
        result = client.fetch key(api, opts), :expires_in => Exchange.configuration.cache.expire == :daily ? 86400 : 3600, &block
        client.delete(key(api, opts)) unless result && !result.to_s.empty?
        
        result
      end
        
    end
  end
end