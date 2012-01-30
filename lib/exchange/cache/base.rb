module Exchange
  module Cache
    class Base
      class << self
        
        protected
          
          def key(api_class, time=nil)
            time      ||= Time.now
            key_parts = [api_class.to_s.gsub(/::/, '_'), time.year, time.yday]
            key_parts << time.hour if Exchange::Configuration.update == :hourly
            key_parts.join('_')
          end
        
      end
    end
  end
end