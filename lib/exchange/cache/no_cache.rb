module Exchange
  module Cache
    
    # @author Beat Richartz
    # A class that allows to store api call results in files. THIS NOT A RECOMMENDED CACHING OPTION!
    # It just may be necessary to cache large files somewhere, this class allows you to do that
    # 
    # @version 0.3
    # @since 0.3
    NoCache = Class.new Base
  end
end