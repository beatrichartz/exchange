require 'redis'

module Exchange
  module Cache
    class Redis < Base
      class << self
        
        def client
          @@client ||= ::Redis.new(:host => Exchange::Configuration.cache_host, :port => Exchange::Configuration.cache_port)
        end
        
        def cached api, &block
          if result = client.get(key(api))
            result = JSON.load result
          else
            result = block.call
            if result && !result.empty?
              client.set key(api), result.to_json
              client.expire key(api), Exchange::Configuration.update == :daily ? 86400 : 3600
            end
          end
          
          result
        end
        
      end
    end
  end
end