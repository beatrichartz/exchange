# -*- encoding : utf-8 -*-
module Exchange
  module Cache
    # @author Beat Richartz
    # A class that cooperates with the memcached gem to cache the data from the exchange api in memcached
    # 
    # @version 0.1
    # @since 0.1
    # @example Activate caching via memcache by setting the cache in the configuration to :memcached
    #   Exchange::Configuration.define do |c| 
    #     c.cache = :memcached
    #     c.cache_host = 'Your memcached host' 
    #     c.cache_port = 'Your memcached port'
    #   end
    #
    class Memcached < Base
      
      # delegate client and wiping the client to the instance
      #
      def_delegators :instance, :client, :wipe_client!
        
      # instantiates a memcached client and memoizes it in a class variable.
      # Use this client to access memcached data. For further explanation of use visit the memcached gem documentation
      # @example
      #   Exchange::Cache::Memcached.client.set('FOO', 'BAR')
      # @return [Dalli::Client] an instance of the dalli gem client class
      #
      def client
        Exchange::GemLoader.new('dalli').try_load unless defined?(::Dalli)
        @client ||= Dalli::Client.new("#{config.host}:#{config.port}")
      end
      
      # Wipe the client instance variable
      #
      def wipe_client!
        @client = nil
      end
      
      # returns either cached data from the memcached client or calls the block and caches it in memcached.
      # This method has to be the same in all the cache classes in order for the configuration binding to work
      # @param [Exchange::ExternalAPI::Subclass] api The API class the data has to be stored for
      # @param [Hash] opts the options to cache with
      # @option opts [Time] :at the historic time of the exchange rates to be cached
      # @yield [] This method takes a mandatory block with an arity of 0 for caching
      # @raise [CachingWithoutBlockError] an Argument Error when no mandatory block has been given
      #
      def cached api, opts={}, &block
        stored = client.get(key(api, opts))
        result = opts[:plain] ? stored : stored.decachify if stored && !stored.to_s.empty?
        
        unless result
          result = super
          if result && !result.to_s.empty?
            client.set key(api, opts), result.cachify, config.expire == :daily ? 86400 : 3600
          end
        end
        
        result
      end
      
    end
  end
end
