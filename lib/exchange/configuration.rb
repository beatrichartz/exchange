module Exchange
  class Configuration
    class << self
      @@config ||= {:api => :currency_bot, :retries => 5, :allow_mixed_operations => true, :cache => :memcached, :cache_host => 'localhost', :cache_port => 11211, :update => :daily} 
      def define &blk
        self.instance_eval(&blk)
      end
      
      [:api, :retries, :cache, :cache_host, :cache_port, :update, :allow_mixed_operations].each do |m|
        define_method m do
          @@config[m]
        end
        define_method :"#{m}=" do |data|
          @@config.merge! m => data
        end
      end
      
      def api_class
        Exchange::ExternalAPI.const_get self.api.to_s.gsub(/(?:^|_)(.)/) { $1.upcase }
      end
      
      def cache_class
        Exchange::Cache.const_get self.cache.to_s.gsub(/(?:^|_)(.)/) { $1.upcase } if self.cache
      end
    end 
  end
end