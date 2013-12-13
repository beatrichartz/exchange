# -*- encoding : utf-8 -*-
module Exchange
  module Cache
    # @author Beat Richartz
    # A Class that handles caching configuration options
    # 
    # @version 0.9
    # @since 0.9
    #
    class Configuration < Exchange::Configurable
      
      # Additional properties which are proprietary to the cache configuration
      #
      attr_accessor :expire, :host, :port, :path
            
      class << self
        
        # Alias method chain to set the client to nil before an attribute of the configuration is set.
        # @param setters The attribute names for which the chain has to be installed
        #
        def wipe_client_before_setting *setters
          
          setters.each do |setter|
            define_method :"#{setter}_with_client_wipe=" do |data|
              wipe_subclass_client!
              send(:"#{setter}_without_client_wipe=", data)
            end
            alias_method :"#{setter}_without_client_wipe=", :"#{setter}="
            alias_method :"#{setter}=", :"#{setter}_with_client_wipe="
          end
          
        end
        
      end
      
      # delegate all necessary methods to the instance
      #
      def_delegators :instance, :expire, :expire=, :host, :host=, :port, :port=, :path, :path=
      
      # set the client to nil before setting the host or the port
      #
      wipe_client_before_setting :host, :port
      
      # Overrides the parent class method to set the client to nil before setting the configuration via a hash
      # @param [Hash] hash The hash with the configuration options to set the configuration to
      # 
      def set hash
        wipe_subclass_client!
        super
      end
      
      # The parent module to get the constants from
      # @returns [Class] the Cache class, always
      #
      def parent_module
        Cache
      end
      
      # The key of the configuration
      #
      def key
        :cache
      end
      
      private
      
      # set the client instance variable to nil if possible
      #
      def wipe_subclass_client!
        subclass.wipe_client! if subclass && subclass.respond_to?(:wipe_client!)
      end
            
    end
  end 
end
