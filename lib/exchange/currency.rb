# Top Level Module of the the gem.
# @author Beat Richartz
# @version 0.7
# @since 0.1

module Exchange
  # @author Beat Richartz
  # Currency Objects instantiated from the currency class can be used for basic mathematical operations and currency conversions
  # @version 0.1
  # @since 0.1
  #
  class Currency
    include Comparable
    
    # @attr_reader
    # @return [BigDecimal] number The number the currency object has been instantiated from
    #
    attr_reader :value
    
    # @attr_reader
    # @return [Symbol, String] currency the currency of the currency object
    #
    attr_reader :currency
    
    # @attr_reader
    # @return [Time] The time at which the conversion has taken place or should take place if the object is involved in operations
    #
    attr_reader :time
    
    # @attr_reader
    # @return [Exchange::Currency] The original currency object this currency object was converted from
    #
    attr_reader :from
    
    # Intialize the currency with a number and a currency
    # @param [Integer, Float] number The number the currency is instantiated from
    # @param [String, Symbol] currency The currency the currency object is in
    # @param [Hash] opts Optional Parameters for instantiation
    # @option opts [Time] :at The time at which conversion took place
    # @option opts [String,Symbol] :from The currency object this currency object was converted from
    # @version 0.2
    #
    # @example Instantiate a currency object of 40 US Dollars
    #   Exchange::Currency.new(40, :usd) 
    #     #=> #<Exchange::Currency @number=40.0 @currency=:usd @time=#<Time>>
    # @example Instantiate a currency object of 40 US Dollars and convert it to Euro. It shows the conversion date and the original currency
    #   Exchange::Currency.new(40, :usd).to_eur(:at => Time.gm(2012,9,1)) 
    #     #=> #<Exchange::Currency @number=37.0 @currency=:usd @time=#<Time> @from=#<Exchange::Currency @number=40.0 @currency=:usd>>
    #
    def initialize value, currency, opts={}
      @value            = ISO4217.instantiate(value, currency)
      @currency         = currency
      @time             = Helper.assure_time(opts[:at], :default => :now)
      @from             = opts[:from]
    end
    
    # Method missing is used to handle conversions from one currency object to another. It only handles currencies which are available in
    # the API class set in the configuration.
    # @example Calls convert_to with 'chf'
    #   Exchange::Currency.new(40,:usd).to_chf
    # @example Calls convert_to with 'sek' and :at => Time.gm(2012,2,2)
    #   Exchange::Currency.new(40,:nok).to_sek(:at => Time.gm(2012,2,2))
    #
    def method_missing method, *args, &block
      match = method.to_s.match(/\Ato_(\w{3})/)
      if match && Exchange.configuration.api.subclass::CURRENCIES.include?($1)
        return self.convert_to($1, {:at => self.time}.merge(args.first || {}))
      elsif match && ISO4217.definitions.keys.include?($1.upcase)
        raise NoRateError.new("Cannot convert to #{$1} because the defined api does not provide a rate")
      end

      self.value.send method, *args, &block
    end
    
    # Converts this instance of currency into another currency
    # @return [Exchange::Currency] An instance of Exchange::Currency with the converted number and the converted currency
    # @param [Symbol, String] other The currency to convert the number to
    # @param [Hash] opts An options hash
    # @option [Time] :at The timestamp of the rate the conversion took place in
    # @example convert to 'chf'
    #   Exchange::Currency.new(40,:usd).convert_to('chf')
    # @example convert to 'sek' at a specific rate
    #   Exchange::Currency.new(40,:nok).convert_to('sek', :at => Time.gm(2012,2,2))
    #
    def convert_to other, opts={}
      Currency.new(Exchange.configuration.api.subclass.new.convert(value, currency, other, opts), other, opts.merge(:from => self))
    end
    
    class << self
      
      private
      
        # @private
        # @macro [attach] install_operations
        #
        def install_operation op
          define_method op do |*precision|
            @value = ISO4217.send(op, self.value, self.currency, precision.first)
            self
          end
        end
      
        # @private
        # @macro [attach] base_operations
        #   @method $1(other)
        #   
        def base_operation op
          self.class_eval <<-EOV
            def #{op}(other)
              test_for_currency_mix_error(other)
              new_value = value #{op} (other.kind_of?(Currency) ? other.convert_to(self.currency, :at => other.time) : other)
              Exchange::Currency.new(new_value, currency, :at => time, :from => self)
            end
          EOV
        end
      
    end
    
    # Round the currency. Since this is a currency, it will round to the standard decimal value.
    # If you want to round it to another precision, you have to specifically ask for it.
    # @return [Exchange::Currency] The currency you started with with a rounded value
    # @param [Integer] precision The precision you want the rounding to have. Defaults to the ISO 4217 standard value for the currency
    # @since 0.1
    # @version 0.3
    # @example Round your currency to the iso standard number of decimals
    #   Exchange::Currency.new(40.545, :usd).round
    #     #=> #<Exchange::Currency @value=40.55 @currency=:usd>
    # @example Round your currency to another number of decimals
    #   Exchange::Currency.new(40.545, :usd).round(0)
    #     #=> #<Exchange::Currency @value=41 @currency=:usd>
    #
    install_operation :round
    
    
    # Ceil the currency. Since this is a currency, it will ceil to the standard decimal value.
    # If you want to ceil it to another precision, you have to specifically ask for it.
    # @return [Exchange::Currency] The currency you started with with a ceiled value
    # @param [Integer] precision The precision you want the ceiling to have. Defaults to the ISO 4217 standard value for the currency
    # @since 0.1
    # @version 0.3
    # @example Ceil your currency to the iso standard number of decimals
    #   Exchange::Currency.new(40.544, :usd).ceil
    #     #=> #<Exchange::Currency @value=40.55 @currency=:usd>
    # @example Ceil your currency to another number of decimals
    #   Exchange::Currency.new(40.445, :usd).ceil(0)
    #     #=> #<Exchange::Currency @value=41 @currency=:usd>
    #
    install_operation :ceil
    
    
    # Floor the currency. Since this is a currency, it will ceil to the standard decimal value.
    # If you want to ceil it to another precision, you have to specifically ask for it.
    # @return [Exchange::Currency] The currency you started with with a floored value
    # @param [Integer] precision The precision you want the flooring to have. Defaults to the ISO 4217 standard value for the currency
    # @since 0.1
    # @version 0.3
    # @example Floor your currency to the iso standard number of decimals
    #   Exchange::Currency.new(40.545, :usd).floor
    #     #=> #<Exchange::Currency @value=40.54 @currency=:usd>
    # @example Floor your currency to another number of decimals
    #   Exchange::Currency.new(40.545, :usd).floor(0)
    #     #=> #<Exchange::Currency @value=40 @currency=:usd>
    #
    install_operation :floor
    
    
    # Add value to the currency
    # @param [Integer, Float, Exchange::Currency] other The value to be added to the currency. If an Exchange::Currency, it is converted to the instance's currency and then the converted value is added.
    # @return [Exchange::Currency] The currency with the added value
    # @raise [CurrencyMixError] If the configuration does not allow mixed operations, this method will raise an error if two different currencies are used in the operation
    # @example Configuration disallows mixed operations
    #   Exchange.configuration.allow_mixed_operations = false
    #   Exchange::Currency.new(20,:nok) + Exchange::Currency.new(20,:sek)
    #     #=> #<CurrencyMixError "You tried to mix currencies">
    # @example Configuration allows mixed operations (default)
    #   Exchange::Currency.new(20,:nok) + Exchange::Currency.new(20,:sek)
    #     #=> #<Exchange::Currency @value=37.56 @currency=:nok>
    # @since 0.1
    # @version 0.7
    #
    base_operation '+'
    
    # Subtract a value from the currency
    # @param [Integer, Float, Exchange::Currency] other The value to be subtracted from the currency. If an Exchange::Currency, it is converted to the instance's currency and then subtracted from the converted value.
    # @return [Exchange::Currency] The currency with the added value
    # @raise [CurrencyMixError] If the configuration does not allow mixed operations, this method will raise an error if two different currencies are used in the operation
    # @example Configuration disallows mixed operations
    #   Exchange.configuration.allow_mixed_operations = false
    #   Exchange::Currency.new(20,:nok) - Exchange::Currency.new(20,:sek)
    #     #=> #<CurrencyMixError "You tried to mix currencies">
    # @example Configuration allows mixed operations (default)
    #   Exchange::Currency.new(20,:nok) - Exchange::Currency.new(20,:sek)
    #     #=> #<Exchange::Currency @value=7.56 @currency=:nok>
    # @since 0.1
    # @version 0.7
    #
    base_operation '-'
    
    # Multiply a value with the currency
    # @param [Integer, Float, Exchange::Currency] other The value to be multiplied with the currency. If an Exchange::Currency, it is converted to the instance's currency and multiplied with the converted value.
    # @return [Exchange::Currency] The currency with the multiplied value
    # @raise [CurrencyMixError] If the configuration does not allow mixed operations, this method will raise an error if two different currencies are used in the operation
    # @example Configuration disallows mixed operations
    #   Exchange.configuration.allow_mixed_operations = false
    #   Exchange::Currency.new(20,:nok) * Exchange::Currency.new(20,:sek)
    #     #=> #<CurrencyMixError "You tried to mix currencies">
    # @example Configuration allows mixed operations (default)
    #   Exchange::Currency.new(20,:nok) * Exchange::Currency.new(20,:sek)
    #     #=> #<Exchange::Currency @value=70.56 @currency=:nok>
    # @since 0.1
    # @version 0.7
    #
    base_operation '*'
    
    # Divide the currency by a value
    # @param [Integer, Float, Exchange::Currency] other The value to be divided by the currency. If an Exchange::Currency, it is converted to the instance's currency and divided by the converted value.
    # @return [Exchange::Currency] The currency with the divided value
    # @raise [CurrencyMixError] If the configuration does not allow mixed operations, this method will raise an error if two different currencies are used in the operation
    # @example Configuration disallows mixed operations
    #   Exchange.configuration.allow_mixed_operations = false
    #   Exchange::Currency.new(20,:nok) / Exchange::Currency.new(20,:sek)
    #     #=> #<CurrencyMixError "You tried to mix currencies">
    # @example Configuration allows mixed operations (default)
    #   Exchange::Currency.new(20,:nok) / Exchange::Currency.new(20,:sek)
    #     #=> #<Exchange::Currency @value=1.56 @currency=:nok>
    # @since 0.1
    # @version 0.7
    #
    base_operation '/'
    
    # Compare a currency with another currency or another value. If the other is not an instance of Exchange::Currency, the value 
    # of the currency is compared
    # @param [Whatever you want to throw at it] other The counterpart to compare
    # @return [Boolean] true if the other is equal, false if not
    # @example Compare two currencies
    #   Exchange::Currency.new(40, :usd) == Exchange::Currency.new(34, :usd) #=> true
    # @example Compare two different currencies, the other will get converted for comparison
    #   Exchange::Currency.new(40, :usd) == Exchange::Currency.new(34, :eur) #=> true, will implicitly convert eur to usd at the actual rate
    # @example Compare a currency with a number, the value of the currency will get compared
    #   Exchange::Currency.new(35, :usd) == 35 #=> true
    # @since 0.1
    # @version 0.6
    #
    def == other
      if is_same_currency?(other)
        other.round.value == self.round.value
      elsif is_currency?(other)
        other.convert_to(self.currency, :at => other.time).round.value == self.round.value
      else
        self.value == other
      end
    end
    
    # Sortcompare a currency with another currency. If the other is not an instance of Exchange::Currency, the value 
    # of the currency is compared. Different currencies will be converted to the comparing instances currency
    # @param [Whatever you want to throw at it] other The counterpart to compare
    # @return [Fixed] a number which can be used for sorting
    # @since 0.3
    # @version 0.6
    # @todo which historic conversion should be used when two are present?
    # @example Compare two currencies in terms of value
    #   Exchange::Currency.new(40, :usd) <=> Exchange::Currency.new(28, :usd) #=> -1
    # @example Compare two different currencies, the other will get converted for comparison
    #   Exchange::Currency.new(40, :usd) <=> Exchange::Currency.new(28, :eur) #=> -1
    # @example Sort multiple currencies in an array
    #   [1.usd, 1.eur, 1.chf].sort.map(&:currency) #=> [:usd, :chf, :eur]
    #
    def <=> other
      if is_same_currency?(other)
        self.value <=> other.value
      elsif is_other_currency?(other)
        self.value <=> other.convert_to(self.currency, :at => other.time).value
      else
        self.value <=> other
      end
    end
    
    # Converts the currency to a string in ISO 4217 standardized format, either with or without the currency. This leaves you
    # with no worries how to display the currency.
    # @since 0.3
    # @version 0.3
    # @param [Symbol] format :currency (default) if you want a string with currency, :amount if you want just the amount.
    # @return [String] The formatted string
    # @example Convert a currency to a string
    #   Exchange::Currency.new(49.567, :usd).to_s #=> "USD 49.57"
    # @example Convert a currency without minor to a string
    #   Exchange::Currency.new(45, :jpy).to_s #=> "JPY 45"
    # @example Convert a currency with a three decimal minor to a string
    #   Exchange::Currency.new(34.34, :omr).to_s #=> "OMR 34.340"
    # @example Convert a currency to a string without the currency
    #   Exchange::ISO4217.stringif(34.34, :omr).to_s(:iso) #=> "34.340"
    #
    def to_s format=:currency
      [
        format == :currency && ISO4217.stringify(self.value, self.currency),
        format == :amount && ISO4217.stringify(self.value, self.currency, :amount_only => true)
      ].detect{|l| l.is_a?(String) }
    end
    
    private
    
      # determine if another given object is an instance of Exchange::Currency
      # @param [Object] other The object to be tested against
      # @return [Boolean] true if the other is an instance of Exchange::Currency, false if not
      # @since 0.6
      # @version 0.6
      #
      def is_currency? other
        other.is_a?(Exchange::Currency)
      end
      
      # determine if another given object is an instance of Exchange::Currency and the same currency
      # @param [Object] other The object to be tested against
      # @return [Boolean] true if the other is an instance of Exchange::Currency and has the same currency as self, false if not
      # @since 0.6
      # @version 0.6
      #
      def is_same_currency? other
        is_currency?(other) && other.currency == self.currency
      end
      
      # determine if another given object is an instance of Exchange::Currency and has another currency
      # @param [Object] other The object to be tested against
      # @return [Boolean] true if the other is an instance of Exchange::Currency and has another currency as self, false if not
      # @since 0.6
      # @version 0.6
      #
      def is_other_currency? other
        is_currency?(other) && other.currency != self.currency
      end
      
      # Test if another currency is used in an operation, and if so, if the operation is allowed
      # @param [Numeric, Exchange::Currency] other The counterpart in the operation
      # @raise [CurrencyMixError] an error if mixing currencies is not allowed and currencies where mixed
      # @since 0.6
      # @version 0.6
      #
      def test_for_currency_mix_error other
        raise CurrencyMixError.new("You\'re trying to mix up #{self.currency} with #{other.currency}. You denied mixing currencies in the configuration, allow it or convert the currencies before mixing") if !Exchange.configuration.allow_mixed_operations && other.kind_of?(Currency) && other.currency != self.currency
      end
  
  end
  
  # The error that will get thrown when currencies get mixed up in base operations
  #
  CurrencyMixError = Class.new(ArgumentError)
  
end