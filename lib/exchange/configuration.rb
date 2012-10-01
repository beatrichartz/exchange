module Exchange
  # @author Beat Richartz
  # A configuration class that stores the configuration of the gem. It allows to set the api from which the data gets retrieved,
  # the cache in which the data gets cached, the regularity of updates for the currency rates, how many times the api calls should be 
  # retried on failure, and wether operations mixing currencies should raise errors or not
  # @version 0.1
  # @since 0.1
  def self.configuration= configuration
    if configuration.is_a? Exchange::Configuration
      @@configuration = configuration
    else
      raise ArgumentError.new("The configuration needs to be an instance of Exchange::Configuration")
    end
  end
  
  def self.configuration
    @@configuration ||= Configuration.new
  end
  
  class Configuration
    DEFAULTS = { 
                  :api => {
                    :subclass => ExternalAPI::XavierMedia, 
                    :retries => 5
                  },
                  :cache => {
                    :subclass => Cache::Memcached,
                    :host => 'localhost',
                    :port => 11211,
                    :expire => :daily
                  },
                  :allow_mixed_operations => true
                }
    
    
    def initialize configuration={}, &block
      @config = DEFAULTS.merge(configuration)
      self.instance_eval(&block) if block_given?
      super()
    end 
    
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
    #   configuration.cache = :redis
    #   Exchange::Configuration.api   = :xavier_media
    
    def allow_mixed_operations
      @config[:allow_mixed_operations]
    end
    
    def allow_mixed_operations= data
      @config[:allow_mixed_operations] = data
    end
    
    {:api => ExternalAPI, :cache => Cache}.each do |key, parent_module|
      define_method :"#{key}=" do |data|
        @config[key] = DEFAULTS[key].merge(data)
      end
      
      define_method key do
        @config[key] = OpenStruct.new(@config[key]) unless @config[key].is_a?(OpenStruct)
        @config[key].subclass = parent_module.const_get camelize(@config[key].subclass) unless @config[key].subclass.is_a?(Class)
        @config[key]
      end
    end

    private
      
      def camelize s
        s = s.to_s.gsub(/(?:^|_)(.)/) { $1.upcase }
      end
      
  end
end