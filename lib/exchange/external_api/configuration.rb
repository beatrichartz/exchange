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

      attr_accessor :retries, :app_id, :protocol
      
      def_delegators :instance, :retries, :retries=, :app_id, :app_id=, :protocol, :protocol=
      
      def parent_module
        ExternalAPI
      end
      
      def key
        :api
      end
      
    end
  end 
end
