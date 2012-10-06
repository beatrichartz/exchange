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
        def install_getter key, parent_module
          define_method key do
            @config[key] = OpenStruct.new(@config[key]) unless @config[key].is_a?(OpenStruct)
            @config[key].subclass = parent_module.const_get camelize(@config[key].subclass) unless @config[key].subclass.is_a?(Class)
            @config[key]
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
    
    # Initialize a new configuration. Takes a hash and/or a block. Lets you easily set the configuration the way you want it to be
    # @version 0.6
    # @since 0.6
    # @param [Hash] configuration The configuration as a hash
    # @param [Proc] block A block to yield the configuration with
    # @example Define the configuration with a hash
    #   Exchange::Configuration.new(:allow_mixed_operations => false, :api => {:subclass => :currency_bot, :retries => 2})
    # @example Define the configuration with a block
    #   Exchange::Configuration.new do |c|
    #     c.allow_mixed_operations = false
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
    
    # Getter for the mixed operations configuration. If set to true, operations with mixed currencies will not raise errors
    # If set to false, mixed operations will raise errors
    # @since 0.6
    # @version 0.6
    # @return [Boolean] True if mixed operations are allowed, false if not
    #
    def allow_mixed_operations
      @config[:allow_mixed_operations]
    end
    
    # Setter for the mixed operations configuration. If set to true, operations with mixed currencies will not raise errors
    # If set to false, mixed operations will raise errors
    # @since 0.6
    # @version 0.6
    # @param [Boolean] data The configuration to set
    # @return [Boolean] The configuration set
    #
    def allow_mixed_operations= data
      @config[:allow_mixed_operations] = data
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
    # @return [OpenStruct] an openstruct with the complete api configuration
    #
    install_getter :api, ExternalAPI
    
    # Getter for the cache configuration. Instantiates the configuration as an open struct, if called for the first time.
    # Also camelizes and constantizes the cache subclass, if used for the first time.
    # @return [OpenStruct] an openstruct with the complete cache configuration
    #
    install_getter :cache, Cache

    private
      
      # Camelize a string or a symbol
      # @param [String, Symbol] s The string to camelize
      # @return [String] a camelized string
      # @example Camelize an underscored symbol
      #   camelize(:some_thing) #=> "SomeThing"
      #
      def camelize s
        s = s.to_s.gsub(/(?:^|_)(.)/) { $1.upcase }
      end
      
  end
end