# -*- encoding : utf-8 -*-
module Exchange
  module ExternalAPI
    
    # A class to handle API calls in a standardized way for all APIs
    # @author Beat Richartz
    # @version 0.1
    # @since 0.1
    #
    class Call < Base
      
      # Initialization of the Call class is the call itself. This means that every instance of the class will only exist during the call
      # @param [String] url The url of the API to call
      # @param [Hash] options The options of the API call
      # @option options [Time] :at The time of the historical exchange rate file to get
      # @option options [Class] :api The class to generate the key for
      # @option options [Integer] :retries The number of retries if the API Call should fail with a HTTP Error
      # @option options [Array] :retry_with an Array of urls to retry the call with (if the API does not have a file for the specified date). These values will be shifted until a call succeeds or the number of maximum retries is reached.
      # @option options [Symbol] :format The format to return / yield the API call result in, defaults to :json
      # @yield [Nokogiri::XML, Hash] The result of the API call, either nokogiri parsed XML or a hash loaded from JSON
      # @return [Nokogiri::XML, Hash] Returns the result of the API call if no block is given, either nokogiri parsed XML or a hash loaded from JSON
      # @example Call an API an yield the result
      #   Exchange::ExternalAPI::Call.new('http://yourapiurl.com', :format => :xml) do |result|
      #     # Do something with the result here, for example
      #     rates = {}
      #     result.css('rates').each do |rate|
      #       rates.merge! rate.css('currency').children.to_s => rate.css('rate').children.to_s.to_f
      #     end
      #   end
      # @example Call the API and do something with the result
      #   result = Exchange::ExternalAPI::Call.new('http://yourapiurl.com', :format => :xml)
      #   # Do something with that result
      #
      def initialize url, options={}, &block        
        Exchange::GemLoader.new(options[:format] == :xml ? 'nokogiri' : 'json').try_load
                
        result = cache_config.subclass.cached(options[:api] || config.subclass, options) do
          load_url(url, options[:retries] || config.retries, options[:retry_with])
        end
        
        parsed = options[:format] == :xml ? Nokogiri::XML.parse(result.sub("\n", '')) : ::JSON.load(result)
        
        return parsed unless block_given?
        yield  parsed
      end
      
      private
      
        # A helper function to load the API URL with
        # @param [String] url The url to be loaded
        # @param [Integer] retries The number of retries to do if the API Call should fail with a HTTP Error
        # @param [Array] retry_with An array of urls to retry the API call with if the call to the original URL should fail. These values will be shifted until a call succeeds or the number of maximum retries is reached
        # @todo install a timeout for slow requests, but respect when loading large files
        #
        def load_url url, retries, retry_with          
          begin            
            result = URI.parse(url).open.read
          rescue SocketError
            raise APIError.new("Calling API #{url} produced a socket error")
          rescue OpenURI::HTTPError => e
            retries -= 1
            if retries > 0
              url = retry_with.shift if retry_with && !retry_with.empty?
              retry
            else
              raise APIError.new("API #{url} was not reachable and returned #{e.message}. May be you requested a historic rate not provided")
            end
          end
          result          
        end
      
    end
    
    # The Api Error to throw when an API Call fails
    #
    APIError = Class.new(StandardError)
    
  end
end
