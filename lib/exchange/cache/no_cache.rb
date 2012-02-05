module Exchange
  module Cache
    
    # @author Beat Richartz
    # A class that allows to store api call results in files. THIS NOT A RECOMMENDED CACHING OPTION!
    # It just may be necessary to cache large files somewhere, this class allows you to do that
    # 
    # @version 0.3
    # @since 0.3
    
    class NoCache < Base
      class << self
        
        # returns either cached data from a stored file or stores a file.
        # This method has to be the same in all the cache classes in order for the configuration binding to work
        # @param [Exchange::ExternalAPI::Subclass] api The API class the data has to be stored for
        # @param [Hash] opts the options to cache with
        # @option opts [Time] :at IS IGNORED FOR FILECACHE
        # @option opts [Symbol] :cache_period The period to cache the file for
        # @yield [] This method takes a mandatory block with an arity of 0 and calls it if no cached result is available
        # @raise [CachingWithoutBlockError] an Argument Error when no mandatory block has been given
        
        def cached api, opts={}, &block
          raise CachingWithoutBlockError.new('Caching needs a block') unless block_given?
          
          block.call
        end

        
      end
    end
  end
end