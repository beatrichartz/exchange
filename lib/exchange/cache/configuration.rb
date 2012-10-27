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
      
      def_delegators :instance, :expire, :expire=, :host, :host=, :port, :port=, :path, :path=
      
      def parent_module
        Cache
      end
      
      def key
        :cache
      end
    
    end
  end 
end