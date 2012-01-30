require 'redis'

module Exchange
  module Cache
    class Redis < Base
      class << self
        
        def client
          @@client ||= ::Redis.new(:host => Exchange::Configuration.cache_host, :port => Exchange::Configuration.cache_port)
        end
        
        def cached api, opts={}, &block
          if result = client.get(key(api, opts[:at]))
            result = JSON.load result
          else
            result = block.call
            if result && !result.empty?
              client.set key(api, opts[:at]), result.to_json
              client.expire key(api, opts[:at]), Exchange::Configuration.update == :daily ? 86400 : 3600
            end
          end
          
          result
        end
        
      end
    end
  end
end