module Exchange
  module ExternalAPI
    class XML < Base
      
      def initialize *args
        Exchange::GemLoader.new('nokogiri').try_load unless defined?(Nokogiri)
        super *args
      end
      
    end
  end
end