module Exchange
  # @author Beat Richartz
  # A configuration class that stores the configuration of the gem. It allows to set the api from which the data gets retrieved,
  # the cache in which the data gets cached, the regularity of updates for the currency rates, how many times the api calls should be 
  # retried on failure, and wether operations mixing currencies should raise errors or not
  # @version 0.1
  # @since 0.1
  class Configuration    
    class << self
      @@config ||= {:api => :currency_bot, :retries => 5, :allow_mixed_operations => true, :cache => :memcached, :cache_host => 'localhost', :cache_port => 11211, :update => :daily} 
      
      # A configuration method that stores the configuration of the gem. It allows to set the api from which the data gets retrieved,
      # the cache in which the data gets cached, the regularity of updates for the currency rates, how many times the api calls should be 
      # retried on failure, and wether operations mixing currencies should raise errors or not
      # @version 0.1
      # @since 0.1
      # @example Set a configuration by passing a block to the configuration
      #   Exchange::Configuration.define do |c| 
      #     c.cache       = :redis
      #     c.cache_host  = '127.0.0.1'
      #     c.cache_port  = 6547
      #     c.api         = :currency_bot
      #     c.retries     = 1
      #     c.allow_mixed_operations  = false
      #     c.update      = :hourly
      #   end
      # @yield [Exchange::Configuration] yields a the configuration class
      # @yieldparam [optional, Symbol] cache The cache type to use. Possible Values: :redis, :memcached or :rails or false to disable caching. Defaults to :memcached
      # @yieldparam [optional, String] cache_host A string with the hostname or IP to set the cache host to. Does not have to be set for Rails cache
      # @yieldparam [optional, Integer] cache_port An integer for the cache port. Does not have to be set for Rails cache
      # @yieldparam [optional, Symbol] api The API to use. Possible Values: :currency_bot (Open Source currency bot API) or :xavier_media (Xavier Media API). Defaults to :currency_bot
      # @yieldparam [optional, Integer] retries The number of times the gem should retry to connect to the api host. Defaults to 5.
      # @yieldparam [optional, Boolean] If set to false, Operations with with different currencies raise errors. Defaults to true.
      # @yieldparam [optional, Symbol] The regularity of updates for the API. Possible values: :daily, :hourly. Defaults to :daily.
      # @example Set configuration values directly to the class
      #   Exchange::Configuration.cache = :redis
      #   Exchange::Configuration.api   = :xavier_media
      
      def define &blk
        self.instance_eval(&blk)
      end
            
      [:api, :retries, :cache, :cache_host, :cache_port, :update, :allow_mixed_operations].each do |m|
        define_method m do
          @@config[m]
        end
        define_method :"#{m}=" do |data|
          @@config.merge! m => data
        end
      end
      
      # The instantiated api class according to the configuration
      # @example
      #   Exchange::Configuration.api = :currency_bot
      #   Exchange::Configuration.api_class #=> Exchange::ExternalAPI::CurrencyBot
      # @return [Exchange::ExternalAPI::Subclass] A subclass of Exchange::ExternalAPI
      
      def api_class
        Exchange::ExternalAPI.const_get self.api.to_s.gsub(/(?:^|_)(.)/) { $1.upcase }
      end
      
      # The instantiated cache class according to the configuration
      # @example
      #   Exchange::Configuration.cache = :redis
      #   Exchange::Configuration.cache_class #=> Exchange::ExternalAPI::Redis
      # @return [Exchange::Cache::Subclass] A subclass of Exchange::Cache (or nil if caching has been set to false)
      
      def cache_class
        Exchange::Cache.const_get self.cache.to_s.gsub(/(?:^|_)(.)/) { $1.upcase } if self.cache
      end
    end 
  end
end