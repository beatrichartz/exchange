module Exchange
  
  # This class handles everything that has to do with certified formatting of the different currencies. The standard is stored in 
  # the iso4217 YAML file.
  # @version 0.3
  # @since 0.3
  # @author Beat Richartz
  
  class ISO4217
    class << self
      
      # The ISO 4217 that have to be loaded. Nothing much to say here. Just use this method to get to the definitions
      # They are static, so they can be stored in a class variable without many worries
      # @return [Hash] The iso427 Definitions with the currency code as keys
      
      def definitions
        @@definitions ||= YAML.load_file(File.join(EXCHANGE_GEM_ROOT_PATH, 'iso4217.yml'))
      end
      
      # Use this to instantiate a currency amount. For one, it is important that we use BigDecimal here so nothing gets lost because
      # of floating point errors. For the other, This allows us to set the precision exactly according to the iso definition
      # @param [BigDecimal, Fixed, Float, String] amount The amount of money you want to instantiate
      # @param [String, Symbol] currency The currency you want to instantiate the money in
      # @return [BigDecimal] The instantiated currency
      # @example instantiate a currency from a string
      #   Exchange::ISO4217.instantiate("4523", "usd") #=> #<Bigdecimal 4523.00>
      
      def instantiate(amount, currency)
        BigDecimal.new(amount.to_s, definitions[currency.to_s.upcase]['minor_unit'])
      end
      
      # Converts the currency to a string in ISO 4217 standardized format, either with or without the currency. This leaves you
      # with no worries how to display the currency.
      # @param [BigDecimal, Fixed, Float] amount The amount of currency you want to stringify
      # @param [String, Symbol] currency The currency you want to stringify
      # @param [Hash] opts The options for formatting
      # @option opts [Boolean] :amount_only Whether you want to have the currency in the string or not
      # @return [String] The formatted string
      # @example Convert a currency to a string
      #   Exchange::ISO4217.stringify(49.567, :usd) #=> "USD 49.57"
      # @example Convert a currency without minor to a string
      #   Exchange::ISO4217.stringif(45, :jpy) #=> "JPY 45"
      # @example Convert a currency with a three decimal minor to a string
      #   Exchange::ISO4217.stringif(34.34, :omr) #=> "OMR 34.340"
      # @example Convert a currency to a string without the currency
      #   Exchange::ISO4217.stringif(34.34, :omr, :amount_only => true) #=> "34.340"
      
      def stringify(amount, currency, opts={})
        format      = "%.#{definitions[currency.to_s.upcase]['minor_unit']}f"
        "#{currency.to_s.upcase + ' ' unless opts[:amount_only]}#{format % amount}"
      end
      
      private
        # @private
        # @macro [attach] install_operations
      
        def install_operation op      
          self.class_eval <<-EOV
            def self.#{op}(amount, currency, precision=nil)
              minor = definitions[currency.to_s.upcase]['minor_unit']
              (amount.is_a?(BigDecimal) ? amount : BigDecimal.new(amount.to_s, minor)).#{op}(precision || minor)
            end
          EOV
        end
    end
    
    # Use this to round a currency amount. This allows us to round exactly to the number of minors the currency has in the 
    # iso definition
    # @param [BigDecimal, Fixed, Float, String] amount The amount of money you want to round
    # @param [String, Symbol] currency The currency you want to round the money in
    # @example Round a currency with 2 minors
    #   Exchange::ISO4217.round("4523.456", "usd") #=> #<Bigdecimal 4523.46>
    
    install_operation :round
    
    # Use this to ceil a currency amount. This allows us to ceil exactly to the number of minors the currency has in the 
    # iso definition
    # @param [BigDecimal, Fixed, Float, String] amount The amount of money you want to ceil
    # @param [String, Symbol] currency The currency you want to ceil the money in
    # @example Ceil a currency with 2 minors
    #   Exchange::ISO4217.ceil("4523.456", "usd") #=> #<Bigdecimal 4523.46>
    
    install_operation :ceil
    
    # Use this to floor a currency amount. This allows us to floor exactly to the number of minors the currency has in the 
    # iso definition
    # @param [BigDecimal, Fixed, Float, String] amount The amount of money you want to floor
    # @param [String, Symbol] currency The currency you want to floor the money in
    # @example Floor a currency with 2 minors
    #   Exchange::ISO4217.floor("4523.456", "usd") #=> #<Bigdecimal 4523.46>
    
    install_operation :floor
    
  end
end