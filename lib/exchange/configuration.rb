module Exchange
  # @author Beat Richartz
  # A configuration class that stores the configuration of the gem. It allows to set the api from which the data gets retrieved,
  # the cache in which the data gets cached, the regularity of updates for the currency rates, how many times the api calls should be 
  # retried on failure, and wether operations mixing currencies should raise errors or not
  # @version 0.1
  # @since 0.1
  class Configuration    
    class << self
      @@config ||= {:api => :currency_bot, :retries => 5, :filestore_path => File.expand_path('exchange_filestore'), :allow_mixed_operations => true, :cache => :memcached, :cache_host => 'localhost', :cache_port => 11211, :update => :daily} 
      
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
      # @yieldparam [optional, String] The path where files can be stored for the gem (used for large files from ECB). Make sure ruby has write access.
      # @example Set configuration values directly to the class
      #   Exchange::Configuration.cache = :redis
      #   Exchange::Configuration.api   = :xavier_media
      
      def define &blk
        self.instance_eval(&blk)
      end
            
      [:api, :retries, :cache, :cache_host, :cache_port, :filestore_path, :update, :allow_mixed_operations].each do |m|
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
      # @param [Hash] options A hash of Options
      # @option options [Class] :api A api to return instead of the api class (use for fallback)
      # @return [Exchange::ExternalAPI::Subclass] A subclass of Exchange::ExternalAPI
      
      def api_class(options={})
        Exchange::ExternalAPI.const_get((options[:api] || self.api).to_s.gsub(/(?:^|_)(.)/) { $1.upcase })
      end
      
      # The instantiated cache class according to the configuration
      # @example
      #   Exchange::Configuration.cache = :redis
      #   Exchange::Configuration.cache_class #=> Exchange::ExternalAPI::Redis
      # @param [Hash] options A hash of Options
      # @option options [Class] :api A api to return instead of the api class (use for fallback)
      # @return [Exchange::Cache::Subclass] A subclass of Exchange::Cache (or nil if caching has been set to false)
      
      def cache_class(options={})
        if self.cache
          Exchange::Cache.const_get((options[:cache] || self.cache).to_s.gsub(/(?:^|_)(.)/) { $1.upcase })
        else
          Exchange::Cache::NoCache
        end
      end
    end 
  end
end