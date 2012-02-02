# Top Level Module of the the gem.
# @author Beat Richartz
# @version 0.1
# @since 0.1

module Exchange
  # @author Beat Richartz
  # Currency Objects instantiated from the currency class can be used for basic mathematical operations and currency conversions
  # @version 0.1
  # @since 0.1
  class Currency
    
    # @attr_reader
    # @return [Float] number The number the currency object has been instantiated from
    attr_reader :value
    
    # @attr_reader
    # @return [Symbol, String] currency the currency of the currency object
    attr_reader :currency
    
    # @attr_reader
    # @return [Time] The time at which the conversion has taken place
    attr_reader :time
    
    # @attr_reader
    # @return [Exchange::Currency] The original currency object this currency object was converted from
    attr_reader :from
    
    # Intialize the currency with a number and a currency
    # @param [Integer, Float] number The number the currency is instantiated from
    # @param [String, Symbol] currency The currency the currency object is in
    # @param [Hash] opts Optional Parameters for instantiation
    # @option opts [Time] :at The time at which conversion took place
    # @option opts [String,Symbol] :from The currency object this currency object was converted from
    #
    # @example Instantiate a currency object of 40 US Dollars
    #   Exchange::Currency.new(40, :usd) 
    #     #=> #<Exchange::Currency @number=40.0 @currency=:usd @time=#<Time>>
    # @example Instantiate a currency object of 40 US Dollars and convert it to Euro. It shows the conversion date and the original currency
    #   Exchange::Currency.new(40, :usd).to_eur(:at => Time.gm(2012,9,1)) 
    #     #=> #<Exchange::Currency @number=37.0 @currency=:usd @time=#<Time> @from=#<Exchange::Currency @number=40.0 @currency=:usd>>
    
    def initialize value, currency, opts={}
      @value            = value.to_f
      @currency         = currency
      @time             = opts[:at] || Time.now
      @from             = opts[:from] if opts[:from]
    end
    
    # Method missing is used to handle conversions from one currency object to another. It only handles currencies which are available in
    # the API class set in the configuration.
    # @example Calls convert_to with 'chf'
    #   Exchange::Currency.new(40,:usd).to_chf
    # @example Calls convert_to with 'sek' and :at => Time.gm(2012,2,2)
    #   Exchange::Currency.new(40,:nok).to_sek(:at => Time.gm(2012,2,2))
    
    def method_missing method, *args, &block
      if method.to_s.match(/\Ato_(\w+)/) && Exchange::Configuration.api_class::CURRENCIES.include?($1)
        return self.convert_to(*([$1] + args))
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
    
    def convert_to other, opts={}
      Exchange::Currency.new(Exchange::Configuration.api_class.new.convert(value, currency, other, opts), other, opts.merge(:from => self))
    end
    
    class << self
      
      private
        # @private
        # @macro [attach] install_operations
         
        def install_operation op
          define_method op do
            @value = self.value.send(op)
            self
          end
        end
      
        # @private
        # @macro [attach] base_operations
        #   @method $1(other)
      
        def base_operation op
          self.class_eval <<-EOV
            def #{op}(other)
              #{'raise Exchange::CurrencyMixError.new("You\'re trying to mix up #{self.currency} with #{other.currency}. You denied mixing currencies in the configuration, allow it or convert the currencies before mixing") if !Exchange::Configuration.allow_mixed_operations && other.kind_of?(Exchange::Currency) && other.currency != self.currency'}
              @value #{op}= other.kind_of?(Exchange::Currency) ? other.convert_to(self.currency) : other
              self
            end
          EOV
        end
      
    end
    
    # Round the currency (Equivalent to normal round)
    # @return [Exchange::Currency] The currency you started with with a rounded value
    # @example
    #   Exchange::Currency.new(40.5, :usd).round
    #     #=> #<Exchange::Currency @number=41 @currency=:usd>
    
    install_operation :round
    
    
    # Ceil the currency (Equivalent to normal ceil)
    # @return [Exchange::Currency] The currency you started with with a ceiled value
    # @example
    #   Exchange::Currency.new(40.4, :usd).ceil
    #     #=> #<Exchange::Currency @number=41 @currency=:usd>
    
    install_operation :ceil
    
    
    # Floor the currency (Equivalent to normal floor)
    # @return [Exchange::Currency] The currency you started with with a floored value
    # @example
    #   Exchange::Currency.new(40.7, :usd).floor
    #     #=> #<Exchange::Currency @number=40 @currency=:usd>
    
    install_operation :floor
    
    
    # Add value to the currency
    # @param [Integer, Float, Exchange::Currency] other The value to be added to the currency. If an Exchange::Currency, it is converted to the instance's currency and then the converted value is added.
    # @return [Exchange::Currency] The currency with the added value
    # @raise [CurrencyMixError] If the configuration does not allow mixed operations, this method will raise an error if two different currencies are used in the operation
    # @example Configuration disallows mixed operations
    #   Exchange::Configuration.allow_mixed_operations = false
    #   Exchange::Currency.new(20,:nok) + Exchange::Currency.new(20,:sek)
    #     #=> #<CurrencyMixError "You tried to mix currencies">
    # @example Configuration allows mixed operations (default)
    #   Exchange::Currency.new(20,:nok) + Exchange::Currency.new(20,:sek)
    #     #=> #<Exchange::Currency @value=37.56 @currency=:nok>
    
    base_operation '+'
    
    # Subtract a value from the currency
    # @param [Integer, Float, Exchange::Currency] other The value to be subtracted from the currency. If an Exchange::Currency, it is converted to the instance's currency and then subtracted from the converted value.
    # @return [Exchange::Currency] The currency with the added value
    # @raise [CurrencyMixError] If the configuration does not allow mixed operations, this method will raise an error if two different currencies are used in the operation
    # @example Configuration disallows mixed operations
    #   Exchange::Configuration.allow_mixed_operations = false
    #   Exchange::Currency.new(20,:nok) - Exchange::Currency.new(20,:sek)
    #     #=> #<CurrencyMixError "You tried to mix currencies">
    # @example Configuration allows mixed operations (default)
    #   Exchange::Currency.new(20,:nok) - Exchange::Currency.new(20,:sek)
    #     #=> #<Exchange::Currency @value=7.56 @currency=:nok>
    
    base_operation '-'
    
    # Multiply a value with the currency
    # @param [Integer, Float, Exchange::Currency] other The value to be multiplied with the currency. If an Exchange::Currency, it is converted to the instance's currency and multiplied with the converted value.
    # @return [Exchange::Currency] The currency with the multiplied value
    # @raise [CurrencyMixError] If the configuration does not allow mixed operations, this method will raise an error if two different currencies are used in the operation
    # @example Configuration disallows mixed operations
    #   Exchange::Configuration.allow_mixed_operations = false
    #   Exchange::Currency.new(20,:nok) * Exchange::Currency.new(20,:sek)
    #     #=> #<CurrencyMixError "You tried to mix currencies">
    # @example Configuration allows mixed operations (default)
    #   Exchange::Currency.new(20,:nok) * Exchange::Currency.new(20,:sek)
    #     #=> #<Exchange::Currency @value=70.56 @currency=:nok>
    
    base_operation '*'
    
    # Divide the currency by a value
    # @param [Integer, Float, Exchange::Currency] other The value to be divided by the currency. If an Exchange::Currency, it is converted to the instance's currency and divided by the converted value.
    # @return [Exchange::Currency] The currency with the divided value
    # @raise [CurrencyMixError] If the configuration does not allow mixed operations, this method will raise an error if two different currencies are used in the operation
    # @example Configuration disallows mixed operations
    #   Exchange::Configuration.allow_mixed_operations = false
    #   Exchange::Currency.new(20,:nok) / Exchange::Currency.new(20,:sek)
    #     #=> #<CurrencyMixError "You tried to mix currencies">
    # @example Configuration allows mixed operations (default)
    #   Exchange::Currency.new(20,:nok) / Exchange::Currency.new(20,:sek)
    #     #=> #<Exchange::Currency @value=1.56 @currency=:nok>
    
    base_operation '/'
  
  end
  
  # The error that will get thrown when currencies get mixed up in base operations
  CurrencyMixError = Class.new(ArgumentError)
end