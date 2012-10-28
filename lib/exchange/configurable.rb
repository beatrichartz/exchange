require 'singleton'
require 'forwardable'

module Exchange
  
  class Configurable
    include Singleton
    extend SingleForwardable
    
    attr_accessor :subclass
    
    def_delegators :instance, :subclass, :subclass=, :set
     
    def subclass_with_constantize
      self.subclass = parent_module.const_get camelize(self.subclass_without_constantize) unless self.subclass_without_constantize.is_a?(Class)
      subclass_without_constantize
    end
    alias_method :subclass_without_constantize, :subclass
    alias_method :subclass, :subclass_with_constantize
    
    def set hash
      hash.each_pair do |k,v|
        self.send(:"#{k}=", v)
      end
      
      self
    end
    
    def reset
      set Exchange::Configuration::DEFAULTS[key]
    end
    
    [:key, :parent_module].each do |subclass_method|
      define_method subclass_method do
        raise StandardError.new("Subclass Responsibility")
      end
    end
    
    private

      # Camelize a string or a symbol
      # @param [String, Symbol] s The string to camelize
      # @return [String] a camelized string
      # @example Camelize an underscored symbol
      #   camelize(:some_thing) #=> "SomeThing"
      #
      def camelize s
        s = s.to_s.gsub(/(?:^|_)(.)/) { $1.upcase }
      end
    
  end
  
end