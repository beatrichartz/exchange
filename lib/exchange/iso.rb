# -*- encoding : utf-8 -*-
require 'singleton'
require 'forwardable'
require 'yaml'

module Exchange
  
  # This class handles everything that has to do with certified formatting of the different currencies. The standard is stored in 
  # the iso4217 YAML file.
  # @version 0.6
  # @since 0.3
  # @author Beat Richartz
  #
  class ISO
    include Singleton
    extend SingleForwardable
    
    class << self
      
      private
        # @private
        # @macro [attach] install_operations
      
        def install_operation op      
          self.class_eval <<-EOV
            def #{op}(amount, currency, precision=nil, opts={})
              minor = definitions[currency][:minor_unit]
              money = amount.is_a?(BigDecimal) ? amount : BigDecimal.new(amount.to_s, precision_for(amount, currency))
              if opts[:psych] && minor > 0
                money.#{op}(0) - BigDecimal.new((1.0/(10**minor)).to_s)
              elsif opts[:psych]
                (((money.#{op}(0) / BigDecimal.new("10.0")).#{op}(0)) - BigDecimal.new("0.1")) * BigDecimal.new("10")
              else
                money.#{op}(precision || minor)
              end
            end
          EOV
        end
    
    end
          
    # The ISO 4217 that have to be loaded. Use this method to get to the definitions
    # They are static, so they can be stored in a class variable without many worries
    # @return [Hash] The iso4217 Definitions with the currency code as keys
    #
    def definitions
      @definitions ||= symbolize_keys(YAML.load_file(File.join(ROOT_PATH, 'iso4217.yml')))
    end
    
    # A map of country abbreviations to currency codes. Makes an instantiation of currency codes via a country code
    # possible
    # @return [Hash] The ISO3166 (1 and 2) country codes matched to a currency
    #
    def country_map
      @country_map ||= symbolize_keys(YAML.load_file(File.join(ROOT_PATH, 'iso4217_country_map.yml')))
    end
    
    # All currencies defined by ISO 4217 as an array of symbols for inclusion testing
    # @return [Array] An Array of currency symbols
    #
    def currencies
      @currencies  ||= definitions.keys.sort_by(&:to_s)
    end
    
    # Check if a currency is defined by ISO 4217 standards
    # @param [Symbol] currency the downcased currency symbol
    # @return [Boolean] true if the symbol matches a currency, false if not
    #
    def defines? currency
      currencies.include?(country_map[currency] ? country_map[currency] : currency)
    end
    
    # Asserts a given argument is a currency. Tries to match with a country code if the argument is not a currency
    # @param [Symbol, String] arg The argument to assert
    # @return [Symbol] The matching currency as a symbol
    #
    def assert_currency! arg
      defines?(arg) ? (country_map[arg] || arg) : raise(Exchange::NoCurrencyError.new("#{arg} is not a currency nor a country code matchable to a currency"))
    end
    
    # Use this to instantiate a currency amount. For one, it is important that we use BigDecimal here so nothing gets lost because
    # of floating point errors. For the other, This allows us to set the precision exactly according to the iso definition
    # @param [BigDecimal, Fixed, Float, String] amount The amount of money you want to instantiate
    # @param [String, Symbol] currency The currency you want to instantiate the money in
    # @return [BigDecimal] The instantiated currency
    # @example instantiate a currency from a string
    #   Exchange::ISO.instantiate("4523", "usd") #=> #<Bigdecimal 4523.00>
    # @note Reinstantiation is not needed in case the amount is already a big decimal. In this case, the maximum precision is already given.
    #
    def instantiate amount, currency
      if amount.is_a?(BigDecimal)
        amount
      else
        BigDecimal.new(amount.to_s, precision_for(amount, currency))
      end
    end
    
    # Converts the currency to a string in ISO 4217 standardized format, either with or without the currency. This leaves you
    # with no worries how to display the currency.
    # @param [BigDecimal, Fixed, Float] amount The amount of currency you want to stringify
    # @param [String, Symbol] currency The currency you want to stringify
    # @param [Hash] opts The options for formatting
    # @option opts [Boolean] :format The format to put the string out in: :amount for only the amount, :symbol for a string with a currency symbol
    # @return [String] The formatted string
    # @example Convert a currency to a string
    #   Exchange::ISO.stringify(49.567, :usd) #=> "USD 49.57"
    # @example Convert a currency without minor to a string
    #   Exchange::ISO.stringif(45, :jpy) #=> "JPY 45"
    # @example Convert a currency with a three decimal minor to a string
    #   Exchange::ISO.stringif(34.34, :omr) #=> "OMR 34.340"
    # @example Convert a currency to a string without the currency
    #   Exchange::ISO.stringif(34.34, :omr, :amount_only => true) #=> "34.340"
    #
    def stringify amount, currency, opts={}    
      definition    = definitions[currency]
      separators    = definition[:separators] || {}
      format        = "%.#{definition[:minor_unit]}f"
      string        = format % amount
      major, minor  = string.split('.')
      
      major.gsub!(/(?<=\d)(?=(?:\d{3})+\z)/, separators[:major]) if separators[:major] && opts[:format] != :plain
      
      string      = minor ? major + (opts[:format] == :plain || !separators[:minor] ? '.' : separators[:minor]) + minor : major
      pre         = [[:amount, :plain].include?(opts[:format]) && '', opts[:format] == :symbol && definition[:symbol], currency.to_s.upcase + ' '].detect{|a| a.is_a?(String)}
      
      "#{pre}#{string}"
    end
    
    # Returns the symbol for a given currency. Returns nil if no symbol is present
    # @param currency The currency to return the symbol for
    # @return [String, NilClass] The symbol or nil
    # 
    def symbol currency      
      definitions[currency][:symbol]
    end
    
    # Use this to round a currency amount. This allows us to round exactly to the number of minors the currency has in the 
    # iso definition
    # @param [BigDecimal, Fixed, Float, String] amount The amount of money you want to round
    # @param [String, Symbol] currency The currency you want to round the money in
    # @example Round a currency with 2 minors
    #   Exchange::ISO.round("4523.456", "usd") #=> #<Bigdecimal 4523.46>
    
    install_operation :round
    
    # Use this to ceil a currency amount. This allows us to ceil exactly to the number of minors the currency has in the 
    # iso definition
    # @param [BigDecimal, Fixed, Float, String] amount The amount of money you want to ceil
    # @param [String, Symbol] currency The currency you want to ceil the money in
    # @example Ceil a currency with 2 minors
    #   Exchange::ISO.ceil("4523.456", "usd") #=> #<Bigdecimal 4523.46>
    
    install_operation :ceil
    
    # Use this to floor a currency amount. This allows us to floor exactly to the number of minors the currency has in the 
    # iso definition
    # @param [BigDecimal, Fixed, Float, String] amount The amount of money you want to floor
    # @param [String, Symbol] currency The currency you want to floor the money in
    # @example Floor a currency with 2 minors
    #   Exchange::ISO.floor("4523.456", "usd") #=> #<Bigdecimal 4523.46>
    
    install_operation :floor
    
    # Forwards the assure_time method to the instance using singleforwardable
    #
    def_delegators :instance, :definitions, :instantiate, :stringify, :symbol, :round, :ceil, :floor, :currencies, :country_map, :defines?, :assert_currency!
    
    private
    
    # symbolizes keys and returns a new hash
    #
    def symbolize_keys hsh
      new_hsh = Hash.new
      
      hsh.each_pair do |k,v| 
        v = symbolize_keys v if v.is_a?(Hash)        
        new_hsh[k.downcase.to_sym] = v
      end
      
      new_hsh
    end
    
    # Interpolates a string with separators every 3 characters
    # 
    
    # get a precision for a specified amount and a specified currency
    # @params [Float, Integer] amount The amount to get the precision for
    # @params [Symbol] currency the currency to get the precision for
    #
    def precision_for amount, currency
      defined_minor_precision                         = definitions[currency][:minor_unit]
      given_major_precision, given_minor_precision    = amount.to_s.match(/^-?(\d*)\.?(\d*)$/).to_a[1..2].map(&:size)
      
      given_major_precision + [defined_minor_precision, given_minor_precision].max
    end
    
  end
end
