module Exchange
  module ExternalAPI
    class JSON < Base
      
      def initialize *args
        Exchange::GemLoader.new('json').try_load unless defined?(::JSON)
        super *args
      end
      
    end
  end
end