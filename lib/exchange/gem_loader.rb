# -*- encoding : utf-8 -*-
module Exchange
  
  # The gem loader takes care of loading gems without adding too many unnecessary dependencies to the gem
  # @author Beat Richartz
  # @version 0.6
  # @since 0.6
  #
  class GemLoader
    
    # The error that gets thrown if a needed gem is not available or loadable
    #
    GemNotFoundError  = Class.new LoadError

    # initialize the loader with a gem name. 
    # @param [string] gem The gem to require
    # @return [Exchange::Gemloader] an instance of the gemloader
    # @example initialize a loader for the nokogiri gem
    #   Exchange::GemLoader.new('nokogiri')
    #
    def initialize gem
      @gem = gem
    end
    
    # Try to require the gem specified on initialization.
    # @raise [GemNotFoundError] an error indicating that the gem could not be found rather than a load error
    # @example Try to load the JSON gem
    #   Exchange::GemLoader.new('json').try_load
    #
    def try_load
      require @gem
    rescue LoadError => e
      raise GemNotFoundError.new("You specified #{@gem} to be used with Exchange, yet it is not loadable. Please install #{@gem} to be able to use it with Exchange")
    end
  end
end
