module Exchange
  
  # The conversability module which will get included in Fixnum and Float, giving them the currency exchange methods
  # @author Beat Richartz
  # @version 0.1
  # @since 0.1
  
  module Conversability
    # Method missing is used here to allow instantiation and immediate conversion of Currency objects from a common Fixnum or Float
    # @example Instantiate from any type of number
    #   40.usd => #<Exchange::Currency @value=40 @currency=:usd>
    #   -33.nok => #<Exchange::Currency @value=-33 @currency=:nok>
    #   33.333.sek => #<Exchange::Currency @value=33.333 @currency=:sek>
    # @example Instantiate and immediatly convert
    #   1.usd.to_eur => #<Exchange::Currency @value=0.79 @currency=:eur>
    #   1.nok.to_chf => #<Exchange::Currency @value=6.55 @currency=:chf>
    #   -3.5.dkk.to_huf => #<Exchange::Currency @value=-346.55 @currency=:huf>
    # @example Instantiate and immediatly convert at a specific time in the past
    #   1.usd.to_eur(:at => Time.now - 86400) => #<Exchange::Currency @value=0.80 @currency=:eur>
    #   1.nok.to_chf(:at => Time.now - 3600) => #<Exchange::Currency @value=6.57 @currency=:chf>
    #   -3.5.dkk.to_huf(:at => Time.now - 172800) => #<Exchange::Currency @value=-337.40 @currency=:huf>
    
    def method_missing method, *args, &block
      return Exchange::Currency.new(self, method) if method.to_s.length == 3 && Exchange::Configuration.api_class::CURRENCIES.include?(method.to_s)
    
      super method, *args, &block
    end
  end
end

Fixnum.send :include, Exchange::Conversability
Float.send  :include, Exchange::Conversability