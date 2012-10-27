module Exchange
  module Cache
    # @author Beat Richartz
    # A class that cooperates with the redis gem and the redis key value store to cache the data from the exchange api in redis
    # 
    # @version 0.1
    # @since 0.1
    # @example Activate caching via redis by setting the cache in the configuration to :redis
    #   Exchange::Configuration.define do |c| 
    #     c.cache = :redis
    #     c.cache_host = 'Your redis host' 
    #     c.cache_port = 'Your redis port (an Integer)'
    #   end
    class Redis < Base
              
      # instantiates a redis client and memoizes it in a class variable.
      # Use this client to access redis data. For further explanation of use visit the redis gem documentation
      # @example
      #   Exchange::Cache::Redis.client.set('FOO', 'BAR')
      # @return [::Redis] an instance of the redis client gem class
      #
      def client
        Exchange::GemLoader.new('redis').try_load unless defined?(::Redis)
        @client ||= ::Redis.new(:host => Exchange.configuration.cache.host, :port => Exchange.configuration.cache.port)
      end
      
      # returns either cached data from the redis client or calls the block and caches it in redis.
      # This method has to be the same in all the cache classes in order for the configuration binding to work
      # @param [Exchange::ExternalAPI::Subclass] api The API class the data has to be stored for
      # @param [Hash] opts the options to cache with
      # @option opts [Time] :at the historic time of the exchange rates to be cached
      # @yield [] This method takes a mandatory block with an arity of 0 and calls it if no cached result is available
      # @raise [CachingWithoutBlockError] an Argument Error when no mandatory block has been given
      #
      def cached api, opts={}, &block          
        if result = client.get(key(api, opts))
          result = opts[:plain] ? result : result.decachify
        else
          result = super
          if result && !result.to_s.empty?
            client.set key(api, opts), result.cachify
            client.expire key(api, opts), Exchange.configuration.cache.expire == :daily ? 86400 : 3600
          end
        end
        
        result
      end
      
    end
  end
end