module Exchange
  module Cache
    class Rails < Base
      class << self
        
        def client
          ::Rails.cache if defined?(::Rails)
        end
        
        def cached api, &block
          result = client.fetch key(api), :expires_in => Exchange::Configuration.update == :daily ? 86400 : 3600, &block
          client.delete(key(api)) unless result && !result.empty?
          
          JSON.load result
        end
        
      end
    end
  end
end