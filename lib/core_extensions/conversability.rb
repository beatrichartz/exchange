module Exchange
  module Conversability
    def method_missing method, *args, &block
      return Exchange::Currency.new(self, method) if method.to_s.length == 3 && Exchange::Configuration.api_class::CURRENCIES.include?(method.to_s)
    
      super method, *args, &block
    end
  end
end

Fixnum.send :include, Exchange::Conversability
Float.send  :include, Exchange::Conversability