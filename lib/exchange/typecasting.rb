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
        
        define_method :"#{attribute}_with_exchange_typecasting" do
          currency = evaluate_money_option(options[:currency]) if options[:currency]
          raise NoCurrencyError.new("No currency is given for typecasting #{attributes.join(', ')}. Make sure a currency is present") unless currency
          
          time     = evaluate_money_option(options[:at]) if options[:at]
          
          Exchange::Money.new(send(:"#{attribute}_without_exchange_typecasting")) do |c|
            c.currency = currency
            c.time     = time if time
          end
        end
        alias_method :"#{attribute}_without_exchange_typecasting", attribute.to_sym
        alias_method attribute.to_sym, :"#{attribute}_with_exchange_typecasting"
      
        define_method :"#{attribute}_with_exchange_typecasting=" do |data|
          att = send(attribute)
          
          if !data.respond_to?(:currency)
            send(:"#{attribute}_without_exchange_typecasting=", data)
          elsif att.currency == data.currency
            send(:"#{attribute}_without_exchange_typecasting=", data.value)
          elsif att.currency != data.currency
            send(:"#{attribute}_without_exchange_typecasting=", data.send(:"to_#{att.currency}").value)
          end
        end
        alias_method :"#{attribute}_without_exchange_typecasting=", :"#{attribute}="
        alias_method :"#{attribute}=", :"#{attribute}_with_exchange_typecasting="
        
      end
      
      define_method :evaluate_money_option do |option|
        option.is_a?(Proc) ? instance_eval(&option) : send(option)
      end
    end
        
    # Is raised when no currency is given for typecasting
    #
    NoCurrencyError = Class.new(ArgumentError)
    
  end

end