module Exchange
  module Cache
    class Rails < Base
      class << self
        
        def client
          ::Rails.cache if defined?(::Rails)
        end
        
        def cached api, opts={}, &block
          result = client.fetch key(api, opts[:at]), :expires_in => Exchange::Configuration.update == :daily ? 86400 : 3600, &block
          client.delete(key(api, opts[:at])) unless result && !result.empty?
          
          JSON.load result
        end
        
      end
    end
  end
end