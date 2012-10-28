module Exchange
  
  # The conversability module which will get included in Fixnum and Float, giving them the currency exchange methods
  # @author Beat Richartz
  # @version 0.2
  # @since 0.1
  #
  module Conversability
    
    # Dynamic method generation is used here to allow instantiation and immediate conversion of Currency objects from 
    # a common Fixnum or Float or BigDecimal. Since some builds of ruby 1.9 handle certain type conversion of Fixnum, Float 
    # and others via method missing, this is not handled via method missing because it would seriously break down performance.
    # 
    # @example Instantiate from any type of number
    #   40.usd => #<Exchange::Money @value=40 @currency=:usd>
    #   -33.nok => #<Exchange::Money @value=-33 @currency=:nok>
    #   33.333.sek => #<Exchange::Money @value=33.333 @currency=:sek>
    # @example Instantiate and immediatly convert
    #   1.usd.to_eur => #<Exchange::Money @value=0.79 @currency=:eur>
    #   1.nok.to_chf => #<Exchange::Money @value=6.55 @currency=:chf>
    #   -3.5.dkk.to_huf => #<Exchange::Money @value=-346.55 @currency=:huf>
    # @example Instantiate and immediatly convert at a specific time in the past
    #   1.usd.to_eur(:at => Time.now - 86400) => #<Exchange::Money @value=0.80 @currency=:eur>
    #   1.nok.to_chf(:at => Time.now - 3600) => #<Exchange::Money @value=6.57 @currency=:chf>
    #   -3.5.dkk.to_huf(:at => Time.now - 172800) => #<Exchange::Money @value=-337.40 @currency=:huf>
    #
    # @since 0.1
    # @version 0.2
    #
    ISO4217.currencies.each do |c|
      define_method c do |*args|
        Money.new(self, c, *args)
      end
    end
    
  end
end

# include the Conversability methods in all number operations. Stack traces will indicate the module if something goes wrong.
Numeric.send :include, Exchange::Conversability