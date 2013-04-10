# -*- encoding : utf-8 -*-
module Exchange
  module Cache
    
    # @author Beat Richartz
    # A class that allows to store api call results in files. THIS NOT A RECOMMENDED CACHING OPTION!
    # It just may be necessary to cache large files somewhere, this class allows you to do that
    # 
    # @version 0.6
    # @since 0.3
    
    class File < Base
        
      # returns either cached data from a stored file or stores a file.
      # This method has to be the same in all the cache classes in order for the configuration binding to work
      # @param [Exchange::ExternalAPI::Subclass] api The API class the data has to be stored for
      # @param [Hash] opts the options to cache with
      # @option opts [Time] :at IS IGNORED FOR FILECACHE
      # @option opts [Symbol] :cache_period The period to cache the file for
      # @yield [] This method takes a mandatory block with an arity of 0 and calls it if no cached result is available
      # @raise [CachingWithoutBlockError] an Argument Error when no mandatory block has been given
      #
      def cached api, opts={}, &block
        today = Time.now
        dir   = config.path
        path  = ::File.join(dir, key(api, opts[:cache_period]))
        
        if ::File.exists?(path)
          result = opts[:plain] ? ::File.read(path) : ::File.read(path).decachify
        else
          result = super
          if result && !result.to_s.empty?
            make_sure_exists dir
            clean!           dir, api
            
            ::File.open(path, 'w') {|f| f.write(result.cachify) }
          end
        end
        
        result
      end
      
      private
      
      # A Cache Key generator for the file Cache Class and the time
      # Generates a key which can handle expiration by itself
      # @param [Exchange::ExternalAPI::Subclass] api_class The API to store the data for
      # @param [optional, Symbol] cache_period The time for which the data is valid
      # @return [String] A string that can be used as cache key
      # @example
      #   Exchange::Cache::Base.key(Exchange::ExternalAPI::OpenExchangeRates, :monthly) #=> "Exchange_ExternalAPI_CurrencyBot_monthly_2012_1"
      #
      def key api_class, cache_period=:daily
        time      = Time.now
        [api_class.to_s.gsub(/::/, '_'), cache_period, time.year, time.send(cache_period == :monthly ? :month : :yday)].join('_')
      end
      
      # Make sure the directory exists
      # @param [String] dir the directory path
      #
      def make_sure_exists dir
        FileUtils.mkdir_p(dir) unless Dir.respond_to?(:exists?) && Dir.exists?(dir)
      end
      
      # Clean the files not needed anymore
      # @param [String] dir the directory path
      #
      def clean! dir, api
        keep_files = [key(api, :daily), key(api, :monthly)]
        Dir.entries(dir).each do |e|
          ::File.delete(::File.join(dir, e)) unless keep_files.include?(e) || e.match(/\A\./)
        end
      end
    
    end
  end
end
