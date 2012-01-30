module Exchange
  class Currency
    attr_accessor :number, :currency
    
    def initialize number, currency
      self.number = number
      self.currency = currency
    end
    
    def method_missing method, *args, &block
      if method.to_s.match(/\Ato_(\w+)/) && Exchange::Configuration.api_class::CURRENCIES.include?($1)
        return self.convert_to($1)
      end

      self.number.send method, *args, &block
    end
    
    def convert_to other
      Exchange::Currency.new(Exchange::Configuration.api_class.new.convert(number, currency, other), other)
    end
    
    [:round, :ceil, :floor].each do |m|
      define_method m do
        self.number = self.number.send(m)
        self
      end
    end
    
    %W(+ - / *).each do |m|
      self.class_eval <<-EOV
        def #{m}(other)
          #{'raise Exchange::CurrencyMixError.new("You\'re trying to mix up #{self.currency} with #{other.currency}. You denied mixing currencies in the configuration, allow it or convert the currencies before mixing") if !Exchange::Configuration.allow_mixed_operations && other.kind_of?(Exchange::Currency) && other.currency != self.currency'}
          self.number #{m}= other.kind_of?(Exchange::Currency) ? other.convert_to(self.currency) : other
          self
        end
      EOV
    end
  end
  
  CurrencyMixError = Class.new(ArgumentError)
end