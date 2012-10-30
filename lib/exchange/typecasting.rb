module Exchange
  
  # Allows to access properties of an object as currencies
  # The setter takes care of passing the right values to the original setter method,
  # The getter takes care of instantiating a currency of the original getter method,
  # This is framework agnostic. It works in ActiveRecord/Rails, Datamapper, Ohm, Your own, whatever you want
  #
  # @example The setter converts the currency automatically when the currency is not the one set (example in Active Record)
  #   class MyClass < ActiveRecord::Base
  #     extend Exchange::Typecasting
  #     money :price, :currency => lambda { |s| s.manager.currency }
  #     
  #     has_one :manager
  #
  #     attr_accessible :price
  #
  #   end
  #   
  #   MyClass.find(1).update_attributes :price => 1.usd
  #   MyClass.find(1).price #=> 0.77 EUR
  # 
  # @example The getter sets the currency automatically to the currency set in the definition (example in Ohm)
  #   class MyClass < Ohm::Model
  #     extend Exchange::Typecasting
  #     reference :manager, Manager
  #     attribute :price
  #   
  #     money :price, :currency => :manager_currency
  #
  #     def manager_currency
  #       manager.currency
  #     end
  #     
  #   end
  #
  #   my_instance = MyClass[0]
  #   my_instance.price #=> instance of exchange currency in eur
  #
  #   manager = my_instance.manager
  #   managermanager.update :currency => :usd
  #   my_instance.price #=> instance of exchange currency in usd
  #
  # @author Beat Richartz
  # @since 0.9.0
  # @version 0.9.0
  #
  module Typecasting
    
    # @private
    # @macro [attach] install_money_getters
    #
    def install_money_getter attribute, options={}
      
      define_method :"#{attribute}_with_exchange_typecasting" do
        currency = evaluate_money_option(options[:currency]) if options[:currency]
        
        test_for_currency_error(currency)
        
        time     = evaluate_money_option(options[:at]) if options[:at]
        
        Exchange::Money.new(send(:"#{attribute}_without_exchange_typecasting")) do |c|
          c.currency = currency
          c.time     = time if time
        end
      end
      exchange_typecasting_alias_method_chain attribute
      
    end
    
    # @private
    # @macro [attach] install_money_setters
    #
    def install_money_setter attribute, options={}
      define_method :"#{attribute}_with_exchange_typecasting=" do |data|
        att = send(attribute)
        attribute_setter = :"#{attribute}_without_exchange_typecasting="
        
        if !data.respond_to?(:currency)
          send(attribute_setter, data)
        elsif att.currency == data.currency
          send(attribute_setter, data.value)
        elsif att.currency != data.currency
          send(attribute_setter, data.send(:"to_#{att.currency}").value)
        end
      end
      exchange_typecasting_alias_method_chain attribute, '='
    end
    
    # Install an alias method chain for an attribute
    # @param [String, Symbol] attribute The attribute to install the alias method chain for
    # @param [String] setter The setter sign ('=') if this is a setter
    #
    def exchange_typecasting_alias_method_chain attribute, setter=nil
      alias_method :"#{attribute}_without_exchange_typecasting#{setter}", :"#{attribute}#{setter}"
      alias_method :"#{attribute}#{setter}", :"#{attribute}_with_exchange_typecasting#{setter}"
    end
    
    # @private
    # @macro [attach] install_money_option_eval
    #
    def install_money_option_eval
      define_method :evaluate_money_option do |option|
        option.is_a?(Proc) ? instance_eval(&option) : send(option)
      end
    end
    
    # @private
    # @macro [attach] install_currency_error_tester
    #
    def install_currency_error_tester
      define_method :test_for_currency_error do |currency|
        raise NoCurrencyError.new("No currency is given for typecasting #{attribute}. Make sure a currency is present") unless currency
      end
    end

    # installs a setter and a getter for the attribute you want to typecast as exchange money
    # @overload def money(*attributes, options={})
    #   @param [Symbol] attributes The attributes you want to typecast as money. 
    #   @param [Hash] options Pass a hash as last argument as options
    #   @option options [Symbol, Proc] :currency The currency to evaluate the money with. Can be a symbol or a proc
    #   @option options [Symbol, Proc] :at The time at which the currency should be casted. All conversions of this currency will take place at this time
    # @raise [NoCurrencyError] if no currency option is given or the currency evals to nil
    # @example configure money with symbols, the currency option here will call the method currency in the object context
    #   money :price, :currency => :currency, :time => :created_at
    # @example configure money with a proc, the proc will be called with the object as an argument. This is equivalent to the example above
    #   money :price, :currency => lambda {|o| o.currency}, :time => lambda{|o| o.created_at}
    #
    def money *attributes
      
      options = attributes.last.is_a?(Hash) ? attributes.pop : {}
      
      attributes.each do |attribute|
        
        # Get the attribute typecasted into money 
        # @return [Exchange::Money] an instance of money
        #
        install_money_getter attribute, options
        
        # Set the attribute either with money or just any data
        # Implicitly converts values given that are not in the same currency as the currency option evaluates to
        # @param [Exchange::Money, String, Numberic] data The data to set the attribute to
        # 
        install_money_setter attribute, options
        
      end
      
      # Evaluates options given either as symbols or as procs
      # @param [Symbol, Proc] option The option to evaluate
      #
      install_money_option_eval
      
      # Evaluates whether an error should be raised because there is no currency present
      # @param [Symbol] currency The currency, if given
      #
      install_currency_error_tester
    end
        
    # Is raised when no currency is given for typecasting
    #
    NoCurrencyError = Class.new(ArgumentError)
    
  end

end