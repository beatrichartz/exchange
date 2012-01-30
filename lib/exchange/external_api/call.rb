require 'open-uri'
require 'json'
require 'nokogiri'

module Exchange
  module ExternalAPI
    class Call
      
      def initialize url, options={}, &block
        if Exchange::Configuration.cache
          result = Exchange::Configuration.cache_class.cached(Exchange::Configuration.api_class, options[:at]) do
            load_url(url, options[:retries] || 5, options[:retry_with])
          end
        else
          result = load_url(url, options[:retries] || 5, options[:retry_with])
        end
        
        parsed = options[:format] == :xml ? Nokogiri.parse(result) : JSON.load(result)
        
        return parsed unless block_given?

        yield parsed
      end
      
      private
      
        def load_url(url, retries, retry_with)
          begin
            result = URI.parse(url).open.read
          rescue SocketError
            raise APIError.new("Calling API #{url} produced a socket error")
          rescue OpenURI::HTTPError
            if retries > 0
              retries -= 1
              url = retry_with.shift if retry_with && !retry_with.empty?
              retry
            else
              raise APIError.new("API #{url} was not reachable")
            end
          end
        end
      
    end
    
    APIError = Class.new(StandardError)
  end
end