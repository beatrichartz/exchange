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
      attr_accessor :expire, :host, :port, :path
            
      class << self
        
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
      
      def_delegators :instance, :expire, :expire=, :host, :host=, :port, :port=, :path, :path=
      wipe_client_before_setting :host, :port
      
      # Overrides the parent class method to wipe the client before setting
      # 
      def set hash
        wipe_subclass_client!
        super
      end
      
      def parent_module
        Cache
      end
      
      def key
        :cache
      end
      
      private
      
      def wipe_subclass_client!
        subclass.wipe_client! if subclass && subclass.respond_to?(:wipe_client!)
      end
            
    end
  end 
end
