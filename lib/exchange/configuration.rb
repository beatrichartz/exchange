# -*- encoding : utf-8 -*-
module Exchange
  
  class << self
    
    # A configuration setter for the Exchange gem. This comes in handy if you want to have backup or test setting
    # @param [Exchange::Configuration] configuration the configuration to install
    # @raise [ArgumentError] if fed with anything else than an Exchange::Configuration
    # @return [Exchange::Configuration] The configuration installed
    #
    def configuration= configuration
      if configuration.is_a? Exchange::Configuration
        @configuration = configuration
      else
        raise ArgumentError.new("The configuration needs to be an instance of Exchange::Configuration")
      end
    end
    
    # A getter for the configuration, returns the currently installed configuration or a default configuration
    # if no configuration is installed
    # @return [Exchange::Configuration] The currently installed / the default configuration
    #
    def configuration
      @configuration ||= Configuration.new
    end
  end
  
  # @author Beat Richartz
  # A configuration class that stores the configuration of the gem. It allows to set the api from which the data gets retrieved,
  # the cache in which the data gets cached, the regularity of updates for the currency rates, how many times the api calls should be 
  # retried on failure, and wether operations mixing currencies should raise errors or not
  # @version 0.6
  # @since 0.1
  #
  class Configuration
    
    class << self
      
      private
        
        # @private
        # @macro [setter] install_setter
        #
        def install_setter key
          define_method :"#{key}=" do |data|
            @config[key] = DEFAULTS[key].merge(data)
          end
        end

        
        # @private
        # @macro [getter] install_getter
        #
        def install_getter key
          define_method key do
            config_part = @config[key]
            
            if key == :api && !config_part.is_a?(ExternalAPI::Configuration)
              config_part = ExternalAPI::Configuration.set(config_part)
            elsif key == :cache && !config_part.is_a?(Cache::Configuration)
              config_part = Cache::Configuration.set(config_part)
            end

            @config[key] = config_part
          end
        end
        
    end
    
    # The configuration defaults
    # @version 0.6
    # @since 0.6
    #
    DEFAULTS = { 
                  :api => {
                    :subclass => ExternalAPI::XavierMedia, 
                    :retries => 5,
                    :protocol => :http,
                    :app_id => nil,
                    :raise => true
                  },
                  :cache => {
                    :subclass => Cache::Memory,
                    :expire => :daily,
                    :path => nil,
                    :host => nil,
                    :port => nil
                  },
                  :implicit_conversions => true
                }
    
    # Initialize a new configuration. Takes a hash and/or a block. Lets you easily set the configuration the way you want it to be
    # @version 0.6
    # @since 0.6
    # @param [Hash] configuration The configuration as a hash
    # @param [Proc] block A block to yield the configuration with
    # @example Define the configuration with a hash
    #   Exchange::Configuration.new(:implicit_conversions => false, :api => {:subclass => :open_exchange_rates, :retries => 2})
    # @example Define the configuration with a block
    #   Exchange::Configuration.new do |c|
    #     c.implicit_conversions = false
    #     c.cache = {
    #       :subclass => Exhange::Cache::Redis,
    #       :expire => :hourly
    #     }
    #
    def initialize configuration={}, &block
      @config = DEFAULTS.merge(configuration)
      self.instance_eval(&block) if block_given?
      super()
    end 
    
    # Allows to reset the configuration to the defaults
    # @version 0.9
    # @since 0.9
    #
    def reset
      api.reset
      cache.reset
      self.implicit_conversions = DEFAULTS[:implicit_conversions]
    end
    
    # Getter for the implicit Conversions configuration. If set to true, implicit conversions will not raise errors
    # If set to false, implicit conversions will raise errors
    # @since 0.6
    # @version 0.6
    # @return [Boolean] True if implicit conversions are allowed, false if not
    #
    def implicit_conversions
      @config[:implicit_conversions]
    end
    
    # Setter for the implicit conversions configuration. If set to true, implicit conversions will not raise errors
    # If set to false, implicit conversions will raise errors
    # @since 0.6
    # @version 0.6
    # @param [Boolean] data The configuration to set
    # @return [Boolean] The configuration set
    #
    def implicit_conversions= data
      @config[:implicit_conversions] = data
    end
        
    # Setter for the api configuration.
    # @since 0.6
    # @version 0.6
    # @param [Hash] The hash to set the configuration to
    # @option [Symbol] :subclass The API subclass to use as a underscored symbol (will be camelized and constantized)
    # @option [Integer] :retries The amount of retries on connection failure
    # @example set the api to be ecb with a maximum of 8 retries on connection failure
    #   configuration.api = { :subclass => :ecb, :retries => 8 }
    #
    install_setter :api
    
    # Setter for the cache configuration.
    # @since 0.6
    # @version 0.6
    # @param [Hash] The hash to set the configuration to
    # @option [Symbol] :subclass The Cache subclass to use as a underscored symbol (will be camelized and constantized)
    # @option [String] :host The cache connection host
    # @option [Integer] :port The cache connection port
    # @option [Symbol] :expire The expiration period for the cache, can be :daily or :hourly, defaults to daily
    # @example set the cache to be redis on localhost:6578 with hourly expiration
    #   configuration.cache = { :subclass => :redis, :host => 'localhost', :port => 6578, :expire => :hourly }
    #
    install_setter :cache
    
    # Getter for the api configuration. Instantiates the configuration as an open struct, if called for the first time.
    # Also camelizes and constantizes the api subclass, if used for the first time.
    # @return [Exchange::ExternalAPI::Configuration] an api configuration
    #
    install_getter :api
    
    # Getter for the cache configuration. Instantiates the configuration as an open struct, if called for the first time.
    # Also camelizes and constantizes the cache subclass, if used for the first time.
    # @return [Exchange::Cache::Configuration] a cache configuration
    #
    install_getter :cache
      
  end
end
