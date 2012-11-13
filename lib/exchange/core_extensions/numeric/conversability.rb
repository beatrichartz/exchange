module Exchange
  
  # The conversability module which will get included in Fixnum and Float, giving them the in currency instantiate methods
  # @author Beat Richartz
  # @version 0.10
  # @since 0.1
  #
  module Conversability
    
    # The in method instantiates a money object from a numeric type.
    # @param [Symbol] currency the currency to instantiate the money with
    # @param [Hash] options The options to instantiate the currency with
    # @option [Time] :at The time for which the currency should be instantiated
    # 
    # @example Instantiate from any type of number
    #   40.in(:usd) => #<Exchange::Money @value=40 @currency=:usd>
    #   -33.in(:nok) => #<Exchange::Money @value=-33 @currency=:nok>
    #   33.333.in(:sek) => #<Exchange::Money @value=33.333 @currency=:sek>
    # @example Instantiate and immediatly convert
    #   1.in(:usd).to(:eur) => #<Exchange::Money @value=0.79 @currency=:eur>
    #   1.in(:nok).to(:chf) => #<Exchange::Money @value=6.55 @currency=:chf>
    #   -3.5.in(:chf).to(:dkk) => #<Exchange::Money @value=-346.55 @currency=:huf>
    # @example Instantiate and immediatly convert at a specific time in the past
    #   1.in(:usd).to(:eur, :at => Time.now - 86400) => #<Exchange::Money @value=0.80 @currency=:eur>
    #   1.in(:nok).to(:chf, :at => Time.now - 3600) => #<Exchange::Money @value=6.57 @currency=:chf>
    #   -3.5.in(:dkk).to(:huf, :at => Time.now - 172800) => #<Exchange::Money @value=-337.40 @currency=:huf>
    #
    # @since 0.1
    # @version 0.10
    #
    def in currency, options={}
      if ISO4217.currencies.include? currency
        Money.new(self, currency, options)
      else
        raise Exchange::NoCurrencyError.new("#{currency} is not a currency")
      end
    end    
  end
end

# include the Conversability methods in all number operations. Stack traces will indicate the module if something goes wrong.
Numeric.send :include, Exchange::Conversability