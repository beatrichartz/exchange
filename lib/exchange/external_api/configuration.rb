# -*- encoding : utf-8 -*-
module Exchange
  module ExternalAPI
    # @author Beat Richartz
    # A Class that handles api configuration options
    # 
    # @version 0.9
    # @since 0.9
    #
    class Configuration < Exchange::Configurable

      attr_accessor :retries, :app_id, :protocol, :fallback
      
      def_delegators :instance, :retries, :retries=, :app_id, :app_id=, :protocol, :protocol=, :fallback, :fallback=
      
      def fallback_with_constantize
        self.fallback = Array(fallback_without_constantize).map do |fb|
          unless !fb || fb.is_a?(Class)
            parent_module.const_get camelize(fb)
          else
            fb
          end
        end
        
        fallback_without_constantize
      end
      alias_method :fallback_without_constantize, :fallback
      alias_method :fallback, :fallback_with_constantize
      
      def parent_module
        ExternalAPI
      end
      
      def key
        :api
      end
      
    end
  end 
end
