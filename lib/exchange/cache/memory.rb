module Exchange
  module Cache
    # @author Beat Richartz
    # A class that uses instance variables on the cache singleton class to store values in memory
    # 
    # @version 0.1
    # @since 0.1
    # @example Activate caching via memory by setting the cache in the configuration to :memory
    #   Exchange::Configuration.define do |c| 
    #     c.cache = :memory
    #   end
    #
    class Memory < Base
        
      # returns either cached data from an instance variable or calls the block and caches it in an instance variable.
      # This method has to be the same in all the cache classes in order for the configuration binding to work
      # @param [Exchange::ExternalAPI::Subclass] api The API class the data has to be stored for
      # @param [Hash] opts the options to cache with
      # @option opts [Time] :at the historic time of the exchange rates to be cached
      # @yield [] This method takes a mandatory block with an arity of 0 for caching
      # @raise [CachingWithoutBlockError] an Argument Error when no mandatory block has been given
      #
      def cached api, opts={}, &block
        ivar_name = instance_variable_name(api, opts)

        result = instance_variable_get(ivar_name) 
        
        unless result && !result.to_s.empty?
          result = super

          if result && !result.to_s.empty?
            instance_variable_set(ivar_name, result)
          end 

          clean!
        end
        
        opts[:plain] ? result.cachify : result
      end
      
      private
      
      # Generate an instance variable name for the memory cache to get and set
      # @param [Exchange::ExternalAPI::Subclass] api The API to store the data for
      # @param [Hash] opts The options for caching
      # @return [String] A string that can be used as instance variable name
      #
      def instance_variable_name(api, opts)
        conversion_time          = Exchange::Helper.assure_time(opts[:at], :default => :now)
        time                     = Time.now
        expire_hourly            = Exchange.configuration.cache.expire == :hourly || nil
        
        [
          '@' + api.to_s.downcase.gsub(/::/, '_'),
          conversion_time.year.to_s,
          conversion_time.yday.to_s,
          expire_hourly && conversion_time.hour.to_s,
          time.year.to_s, 
          time.yday.to_s, 
          expire_hourly && time.hour.to_s,
          opts[:key_for] && opts[:key_for].join('_')
        ].compact.join('_')
      end
      
      # Clean the memory from expired exchange instance variables. This removes instance variables matching
      # only the specific key pattern
      # @return [Array] The still persisting instance variables
      #
      def clean!
        time = Time.now
        
        instance_variables.select do |i|
          condition = false
          match = i.to_s.match(/\A@exchange[^\d]+\d{4}_\d{1,3}_?\d{0,2}_(\d{4})_(\d{1,3})_?(\d{1,2})?/)
          
          if match
            condition = match[1].to_i != time.year || match[2].to_i != time.yday
            condition = match[3].to_i != time.hour if match[3]
          end
          
          condition
        end.each do |i|
          remove_instance_variable i
        end
      end
      
    end
  end
end