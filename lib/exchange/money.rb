# -*- encoding : utf-8 -*-
# Top Level Module of the the gem.
# @author Beat Richartz
# @version 0.9
# @since 0.1

module Exchange
  # @author Beat Richartz
  # Money Objects instantiated from the money class can be used for basic mathematical operations and currency conversions
  # @version 0.1
  # @since 0.1
  #
  class Money
    include Comparable
    
    # @return [BigDecimal] number The number the money object has been instantiated from
    #
    attr_accessor :value
    
    # @return [Symbol, String] currency the currency of the money object
    #
    attr_accessor :currency
    
    # @return [Time] The time at which the conversion has taken place or should take place if the object is involved in operations
    #
    attr_accessor :time
    
    # @attr_reader
    # @return [Exchange::Money] The original money object this money object was converted from
    #
    attr_reader :from
    
    # @attr_reader
    # @return [Exchange::ExternalAPI] The current api subclass
    attr_reader :api
    
    # Intialize the currency with a number and a currency
    # @param [Integer, Float] value The number the currency is instantiated from
    # @param [Symbol] currency_arg The currency the money object is in as a downcased symbol
    # @param [Hash] opts Optional Parameters for instantiation
    # @option opts [Time] :at The time at which conversion took place
    # @option opts [String,Symbol] :from The money object this money object was converted from
    # @version 0.9
    #
    # @example Instantiate a money object of 40 US Dollars
    #   Exchange::Money.new(40, :usd) 
    #     #=> #<Exchange::Money @number=40.0 @currency=:usd @time=#<Time>>
    # @example Instantiate a money object of 40 US Dollars and convert it to Euro. It shows the conversion date and the original currency
    #   Exchange::Money.new(40, :usd).to(:eur, :at => Time.gm(2012,9,1)) 
    #     #=> #<Exchange::Money @number=37.0 @currency=:usd @time=#<Time> @from=#<Exchange::Money @number=40.0 @currency=:usd>>
    #
    def initialize value, currency_arg=nil, opts={}, &block
      currency_arg      = ISO.assert_currency!(currency_arg) if currency_arg
      
      @from             = opts[:from] if Exchange.configuration.trace
      @api              = Exchange.configuration.api.subclass
      
      yield(self) if block_given?
      
      self.time             = Helper.assure_time(time || opts[:at], :default => :now)
      self.value            = ISO.instantiate(value, currency || currency_arg)
      self.currency         = currency || currency_arg
    end
    
    # Method missing is used to handle conversions from one money object to another. It only handles currencies which are available in
    # the API class set in the configuration.
    # @example convert to chf
    #   Exchange::Money.new(40,:usd).to(:chf)    
    # @example convert to sek at a given time
    #   Exchange::Money.new(40,:nok).to(:sek, :at => Time.gm(2012,2,2))
    #
    def method_missing method, *args, &block
      value.send method, *args, &block
    end
    
    # Converts this instance of currency into another currency
    # @return [Exchange::Money] An instance of Exchange::Money with the converted number and the converted currency
    # @param [Symbol, String] other The currency to convert the number to
    # @param [Hash] options An options hash
    # @option [Time] :at The timestamp of the rate the conversion took place in
    # @example convert to 'chf'
    #   Exchange::Money.new(40,:usd).to(:chf)
    # @example convert to 'sek' at a specific rate
    #   Exchange::Money.new(40,:nok).to(:sek, :at => Time.gm(2012,2,2))
    #
    def to other, options={}
      other = ISO.assert_currency!(other)
      
      return self if other == currency && (!options[:at] || options[:at] == time)

      if api_supports_currency?(currency) && api_supports_currency?(other)
        opts = { :at => time, :from => [value, currency, time] }.merge(options)
        Money.new(api.new.convert(value, currency, other, opts), other, opts)
      elsif fallback!
        to other, options
      else
        raise_no_rate_error(other)
      end
    rescue ExternalAPI::APIError
      if fallback!
        to other, options
      else
        raise
      end
    end
    alias :in :to
    
    # Revert a conversion, raise an error if information is missing
    # @since 1.2
    # @version 0.1
    # @return [Exchange::Money] An instance of Exchange::Money with the unconverted value and currency
    # @raise [Exchange::ImpossibleReversionError] An error indicating that no information for reversion is present
    #
    def revert!
      raise ImpossibleReversionError.new("Can not revert currency to a previous state because information is missing") unless from
      
      Exchange::Money.new(from[0], from[1], :at => from[2])
    end
    
    class << self
      
      private
      
        # @private
        # @!macro [attach] install_operation
        #
        def install_operation op
          define_method op do |*arguments|
            psych       = arguments.first == :psych
            precision   = psych ? nil : arguments.first
            val         = ISO.send(op, self.value, self.currency, precision, {:psych => psych})
            
            Exchange::Money.new(val, currency, :at => time, :from => [value, currency, time])
          end
        end
      
        # @private
        # @!macro [attach] base_operation
        #   @method $1(other)
        #   
        def base_operation op
          self.class_eval <<-EOV
            def #{op}(other)
              test_for_currency_mix_error(other)
              new_value = value #{op} (other.kind_of?(Money) ? other.to(self.currency, :at => other.time).value : BigDecimal.new(other.to_s))
              Exchange::Money.new(new_value, currency, :at => time, :from => [value, currency, time])
            end
          EOV
        end
      
    end
    
    # Round the currency. Since this is a currency, it will round to the standard decimal value.
    # If you want to round it to another precision, you have to specifically ask for it.
    # @return [Exchange::Money] The currency you started with with a rounded value
    # @param [Integer] precision The precision you want the rounding to have. Defaults to the ISO 4217 standard value for the currency
    # @since 0.1
    # @version 0.7.1
    # @example Round your currency to the iso standard number of decimals
    #   Exchange::Money.new(40.545, :usd).round
    #     #=> #<Exchange::Money @value=40.55 @currency=:usd>
    # @example Round your currency to another number of decimals
    #   Exchange::Money.new(40.545, :usd).round(0)
    #     #=> #<Exchange::Money @value=41 @currency=:usd>
    #
    install_operation :round
    
    
    # Ceil the currency. Since this is a currency, it will ceil to the standard decimal value.
    # If you want to ceil it to another precision, you have to specifically ask for it.
    # @return [Exchange::Money] The currency you started with with a ceiled value
    # @param [Integer] precision The precision you want the ceiling to have. Defaults to the ISO 4217 standard value for the currency
    # @since 0.1
    # @version 0.7.1
    # @example Ceil your currency to the iso standard number of decimals
    #   Exchange::Money.new(40.544, :usd).ceil
    #     #=> #<Exchange::Money @value=40.55 @currency=:usd>
    # @example Ceil your currency to another number of decimals
    #   Exchange::Money.new(40.445, :usd).ceil(0)
    #     #=> #<Exchange::Money @value=41 @currency=:usd>
    #
    install_operation :ceil
    
    
    # Floor the currency. Since this is a currency, it will ceil to the standard decimal value.
    # If you want to ceil it to another precision, you have to specifically ask for it.
    # @return [Exchange::Money] The currency you started with with a floored value
    # @param [Integer] precision The precision you want the flooring to have. Defaults to the ISO 4217 standard value for the currency
    # @since 0.1
    # @version 0.7.1
    # @example Floor your currency to the iso standard number of decimals
    #   Exchange::Money.new(40.545, :usd).floor
    #     #=> #<Exchange::Money @value=40.54 @currency=:usd>
    # @example Floor your currency to another number of decimals
    #   Exchange::Money.new(40.545, :usd).floor(0)
    #     #=> #<Exchange::Money @value=40 @currency=:usd>
    #
    install_operation :floor
    
    
    # Add value to the currency
    # @param [Integer, Float, Exchange::Money] other The value to be added to the currency. If an Exchange::Money, it is converted to the instance's currency and then the converted value is added.
    # @return [Exchange::Money] The currency with the added value
    # @raise [ImplicitConversionError] If the configuration does not allow mixed operations, this method will raise an error if two different currencies are used in the operation
    # @example Configuration disallows mixed operations
    #   Exchange.configuration.implicit_conversions = false
    #   Exchange::Money.new(20,:nok) + Exchange::Money.new(20,:sek)
    #     #=> #<ImplicitConversionError "You tried to mix currencies">
    # @example Configuration allows mixed operations (default)
    #   Exchange::Money.new(20,:nok) + Exchange::Money.new(20,:sek)
    #     #=> #<Exchange::Money @value=37.56 @currency=:nok>
    # @since 0.1
    # @version 0.7
    #
    base_operation '+'
    
    # Subtract a value from the currency
    # @param [Integer, Float, Exchange::Money] other The value to be subtracted from the currency. If an Exchange::Money, it is converted to the instance's currency and then subtracted from the converted value.
    # @return [Exchange::Money] The currency with the added value
    # @raise [ImplicitConversionError] If the configuration does not allow mixed operations, this method will raise an error if two different currencies are used in the operation
    # @example Configuration disallows implicit conversions
    #   Exchange.configuration.implicit_conversions = false
    #   Exchange::Money.new(20,:nok) - Exchange::Money.new(20,:sek)
    #     #=> #<ImplicitConversionError "You tried to mix currencies">
    # @example Configuration allows mixed operations (default)
    #   Exchange::Money.new(20,:nok) - Exchange::Money.new(20,:sek)
    #     #=> #<Exchange::Money @value=7.56 @currency=:nok>
    # @since 0.1
    # @version 0.7
    #
    base_operation '-'
    
    # Multiply a value with the currency
    # @param [Integer, Float, Exchange::Money] other The value to be multiplied with the currency. If an Exchange::Money, it is converted to the instance's currency and multiplied with the converted value.
    # @return [Exchange::Money] The currency with the multiplied value
    # @raise [ImplicitConversionError] If the configuration does not allow mixed operations, this method will raise an error if two different currencies are used in the operation
    # @example Configuration disallows mixed operations
    #   Exchange.configuration.implicit_conversions = false
    #   Exchange::Money.new(20,:nok) * Exchange::Money.new(20,:sek)
    #     #=> #<ImplicitConversionError "You tried to mix currencies">
    # @example Configuration allows mixed operations (default)
    #   Exchange::Money.new(20,:nok) * Exchange::Money.new(20,:sek)
    #     #=> #<Exchange::Money @value=70.56 @currency=:nok>
    # @since 0.1
    # @version 0.7
    #
    base_operation '*'
    
    # Divide the currency by a value
    # @param [Integer, Float, Exchange::Money] other The value to be divided by the currency. If an Exchange::Money, it is converted to the instance's currency and divided by the converted value.
    # @return [Exchange::Money] The currency with the divided value
    # @raise [ImplicitConversionError] If the configuration does not allow mixed operations, this method will raise an error if two different currencies are used in the operation
    # @example Configuration disallows mixed operations
    #   Exchange.configuration.implicit_conversions = false
    #   Exchange::Money.new(20,:nok) / Exchange::Money.new(20,:sek)
    #     #=> #<ImplicitConversionError "You tried to mix currencies">
    # @example Configuration allows mixed operations (default)
    #   Exchange::Money.new(20,:nok) / Exchange::Money.new(20,:sek)
    #     #=> #<Exchange::Money @value=1.56 @currency=:nok>
    # @since 0.1
    # @version 0.7
    #
    base_operation '/'
    
    # Calculate the modulo of a value
    # @param [Integer, Float, Exchange::Money] other The value to be calculated the modulo of. If an Exchange::Money, it is converted to the instance's currency and divided by the converted value.
    # @return [Exchange::Money] The currency with the modulo calculation value
    # @raise [ImplicitConversionError] If the configuration does not allow mixed operations, this method will raise an error if two different currencies are used in the operation
    # @example Configuration disallows mixed operations
    #   Exchange.configuration.implicit_conversions = false
    #   Exchange::Money.new(20,:nok) % Exchange::Money.new(20,:sek)
    #     #=> #<ImplicitConversionError "You tried to mix currencies">
    # @example Configuration allows mixed operations (default)
    #   Exchange::Money.new(20,:nok) % Exchange::Money.new(20,:sek)
    #     #=> #<Exchange::Money @value=1.56 @currency=:nok>
    # @since 0.1
    # @version 0.7
    #
    base_operation '%'
    
    # Used to handle operations when arguments order is reversed
    # @param [Anything] other The value coercing
    # @return [Array] an array containing self and other
    #
    # @example
    #   2 * Exchange::Money.new(13, :eur) #=> #<Exchange::Money @value=26 @currency=:eur>
    def coerce(other)
      [self, other]
    end
    
    # Split an amount of a currency into parts without losing fractions
    # @param [Integer] The number of parts to split into
    # @return [Array] Array of rounded instances of Exchange::Money.
    # @example Split a dollar by three
    #   Exchange::Money.new(1, :usd).split(3).map &:to_s #=> ["USD 0.33", "USD 0.33", "USD 0.34"]
    #
    def split(number)
      parts             = number.times.map { Money.new(value / BigDecimal.new(number.to_s), currency, :at => time).round }
      smallest_fraction = BigDecimal.new(BigDecimal.new("1.0") / (10 ** ISO.minor(currency)))
      times             = (self - parts.reduce(:+)) / smallest_fraction
      negative          = times != times.abs
      
      times.abs.to_i.times do |i|
        index = negative ? -i-1 : i
        parts[index] = parts[index].send(negative ? :- : :+, smallest_fraction)
      end
      
      parts
    end
    
    # Compare a currency with another currency or another value. If the other is not an instance of Exchange::Money, the value 
    # of the currency is compared
    # @param [Whatever you want to throw at it] other The counterpart to compare
    # @return [Boolean] true if the other is equal, false if not
    # @example Compare two currencies
    #   Exchange::Money.new(40, :usd) == Exchange::Money.new(34, :usd) #=> true
    # @example Compare two different currencies, the other will get converted for comparison
    #   Exchange::Money.new(40, :usd) == Exchange::Money.new(34, :eur) #=> true, will implicitly convert eur to usd at the actual rate
    # @example Compare a currency with a number, the value of the currency will get compared
    #   Exchange::Money.new(35, :usd) == 35 #=> true
    # @since 0.1
    # @version 0.11
    #
    def == other
      if is_same_currency?(other)
        other.round.value == self.round.value
      elsif is_other_currency?(other)
        test_for_currency_mix_error(other)
        other.to(currency, :at => other.time).round.value == self.round.value
      else
        value == other
      end
    end
    
    # Sortcompare a currency with another currency. If the other is not an instance of Exchange::Money, the value 
    # of the currency is compared. Different currencies will be converted to the comparing instances currency
    # @param [Whatever you want to throw at it] other The counterpart to compare
    # @return [Fixed] a number which can be used for sorting
    # @since 0.3
    # @version 0.11
    # @todo which historic conversion should be used when two are present?
    # @example Compare two currencies in terms of value
    #   Exchange::Money.new(40, :usd) <=> Exchange::Money.new(28, :usd) #=> -1
    # @example Compare two different currencies, the other will get converted for comparison
    #   Exchange::Money.new(40, :usd) <=> Exchange::Money.new(28, :eur) #=> -1
    # @example Sort multiple currencies in an array
    #   [1.usd, 1.eur, 1.chf].sort.map(&:currency) #=> [:usd, :chf, :eur]
    #
    def <=> other
      if is_same_currency?(other)
        value <=> other.value
      elsif is_other_currency?(other)
        test_for_currency_mix_error(other)
        value <=> other.to(currency, :at => other.time).value
      else
        value <=> other
      end
    end
    
    # Converts the currency to a string in ISO 4217 standardized format, either with or without the currency. 
    # @since 0.3
    # @version 0.3
    # @param [Symbol] format :currency (default) if you want a string with currency, :amount if you want just the amount, :plain if you want the unformatted amount
    # @return [String] The formatted string
    # @example Convert a currency to a string
    #   Exchange::Money.new(49.567, :usd).to_s #=> "USD 49.57"
    # @example Convert a currency without minor to a string
    #   Exchange::Money.new(45, :jpy).to_s #=> "JPY 45"
    # @example Convert a currency with a three decimal minor to a string
    #   Exchange::Money.new(34.34, :omr).to_s #=> "OMR 34.340"
    # @example Convert a currency with a three decimal minor to a string with a currency symbol
    #   Exchange::Money.new(34.34, :usd).to_s(:symbol) #=> "$34.34"
    # @example Convert a currency with a three decimal minor to a string with just the amount
    #   Exchange::Money.new(3423.34, :usd).to_s(:amount) #=> "3,423.34"
    # @example Convert a currency with just the plain amount using decimal notation
    #   Exchange::Money.new(3423.34, :omr).to_s(:plain) #=> "3423.340"
    #
    def to_s format=:currency
      ISO.stringify(value, currency, :format => format)
    end
    
    # Converts the currency to a string in ISO 4217 standardized format with html wrappers, either with or without the currency.
    # @since 1.2
    # @version 0.1
    # @param [Symbol] format :currency (default) if you want two span elements (one with currency, the other with the amount), :amount if you want just a span with the amount, :plain if you want the unformatted amount within a span
    # @param [Hash] options
    # @option [Symbol] :tag The HTML tag to use, defaults to span
    # @option [Symbol] :wrap A html tag to wrap the currency element(s) in
    # @option [Symbol] :amount The amount formatter to use (if it differs from the default)
    # @return [String] The HTML formatted string
    # @example Convert a currency to a html formatted string with currency
    #   Exchange::Money.new(49.567, :usd).to_html #=> '<span class="currency usd">USD</span><span class="amount usd">49.57</span>'
    # @example Convert a currency to a HTML formatted string with a symbol span and an amount span
    #   Exchange::Money.new(34.34, :usd).to_html(:symbol) #=> '<span class="currency usd symbol">$</span><span class="amount usd">34.34</span>'
    # @example Convert a currency to a HTML formatted string with an empty icon span with icon and usd class and an amount span
    #   Exchange::Money.new(34.34, :usd).to_html(:icon) #=> '<span class="currency usd icon"></span><span class="amount usd">34.34</span>'
    # @example Convert a currency to a HTML formatted string with an empty icon span with icon and usd class and an amount span formatted to plain format
    #   Exchange::Money.new(3434.34, :usd).to_html(:icon, amount: :plain) #=> '<span class="currency usd icon"></span><span class="amount plain usd">3434.34</span>'
    # @example Convert a currency to a HTML formatted string with div tags instead of span
    #   Exchange::Money.new(3434.34, :usd).to_html(:icon, tag: :div) #=> '<div class="currency usd icon"></div><div class="amount usd">3434.34</div>'
    # @example Convert a currency to a HTML formatted list
    #   Exchange::Money.new(3434.34, :usd).to_html(:icon, tag: :li, wrap: :ul) #=> '<ul class="currency usd"><li class="currency usd icon"></li><li class="amount usd">3434.34</li></ul>'
    #
    def to_html *args
      options       = args.last.is_a?(Hash) ? args.pop : {}
      format        = args.shift || :currency
      amount_format = options[:amount] || format == :plain ? :plain : :amount
      tag           = options[:tag] || 'span'
      wrap          = options[:wrap]
      
      result        = ''
      result        += "<#{wrap} class=\"currency #{currency}\">" if wrap
      result        += "<#{tag} class=\"#{[:currency, format].uniq.join(' ')} #{currency}\">" if [:symbol, :icon, :currency].include?(format)
      result        += (symbol || iso_code) if format == :symbol
      result        += iso_code if format == :currency
      result        += "</#{tag}>" if [:symbol, :icon, :currency].include?(format)
      result        += "<#{tag} class=\"#{[:amount, amount_format].uniq.join(' ')} #{currency}\">#{to_s(amount_format)}</#{tag}>"
      result        += "</#{wrap}>" if wrap
      
      result
    end
    
    # Returns the symbol for the given currency
    # @since 1.2
    # @version 0.1
    # @return [String] The currency symbol, if there is any
    # @example Get the symbol for USD
    #   Exchange::Money.new(12.12, :usd).symbol #=> '$'
    #
    def symbol
      ISO.symbol(currency)
    end
    
    # Returns the ISO Code for the given currency
    # @since 1.2
    # @version 0.1
    # @return [String] The currency ISO 4217 code
    # @example Get the ISO Code for EUR
    #   Exchange::Money.new(13.13, :eur).iso_code #=> 'EUR'
    #
    def iso_code
      currency.to_s.upcase
    end
    
    private
    
      # Fallback to the next api defined in the api fallbacks. Changes the api for the given instance
      # @return [Boolean] true if the fallback was successful, false if not
      # @since 1.0
      # @version 1.0
      #
      def fallback!
        fallback = Exchange.configuration.api.fallback
        new_api  = fallback.index(api) ? fallback[fallback.index(api) + 1] : fallback.first
        
        if new_api
          @api = new_api
          return true
        end
        
        return false
      end
    
      # determine if another given object is an instance of Exchange::Money
      # @param [Object] other The object to be tested against
      # @return [Boolean] true if the other is an instance of Exchange::Money, false if not
      # @since 0.6
      # @version 0.6
      #
      def is_money? other
        other.is_a?(Exchange::Money)
      end
      
      # determine if another given object is an instance of Exchange::Money and the same currency
      # @param [Object] other The object to be tested against
      # @return [Boolean] true if the other is an instance of Exchange::Money and has the same currency as self, false if not
      # @since 0.6
      # @version 0.6
      #
      def is_same_currency? other
        is_money?(other) && other.currency == currency
      end
      
      # determine if another given object is an instance of Exchange::Money and has another currency
      # @param [Object] other The object to be tested against
      # @return [Boolean] true if the other is an instance of Exchange::Money and has another currency as self, false if not
      # @since 0.6
      # @version 0.6
      #
      def is_other_currency? other
        is_money?(other) && other.currency != currency
      end
      
      # determine wether the chosen api supports converting the given currency
      # @param [String] currency The currency to test the api for
      # @return [Boolean] True if the api supports the given currency, false if not
      #
      def api_supports_currency? currency
        api::CURRENCIES.include?(currency)
      end
      
      # Test if another currency is used in an operation, and if so, if the operation is allowed
      # @param [Numeric, Exchange::Money] other The counterpart in the operation
      # @raise [ImplicitConversionError] an error if mixing currencies is not allowed and currencies where mixed
      # @since 0.6
      # @version 0.6
      #
      def test_for_currency_mix_error other
        raise ImplicitConversionError.new("You\'re trying to mix up #{currency} with #{other.currency}. You denied mixing currencies in the configuration, allow it or convert the currencies before mixing") if !Exchange.configuration.implicit_conversions && is_other_currency?(other)
      end
      
      # Helper method to raise a no rate error for a given currency if no rate is given
      # @param [String] other a possible currency
      # @raise [NoRateError] an error indicating that the given string is a currency, but no rate is present
      # @since 0.7.2
      # @version 0.7.2
      #
      def raise_no_rate_error other
        raise NoRateError.new("Cannot convert #{currency} to #{other} because the defined api nor the fallbacks provide a rate")
      end
  
  end
  
  # The error that will get thrown when implicit conversions take place and are not allowed
  #
  ImplicitConversionError = Class.new StandardError
  
  # The error that will get thrown when a reversion is impossible
  #
  ImpossibleReversionError = Class.new StandardError
  
end
