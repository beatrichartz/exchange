module Exchange
  class GemLoader
    # The error that gets thrown if a needed gem is not available or loadable
    GemNotFoundError  = Class.new LoadError

    def initialize gem
      @gem = gem
    end

    def try_load
      require @gem
    rescue LoadError => e
      raise GemNotFoundError.new("You specified #{@gem} to be used with Exchange, yet it is not loadable. Please install #{@gem} to be able to use it with Exchange")
    end
  end
end