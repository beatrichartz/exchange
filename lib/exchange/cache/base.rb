module Exchange
  module Cache
    class Base
      class << self
        
        protected
          
          def key(*args)
            time      = Time.now
            api_class = args.shift
            key_parts = [api_class.to_s.gsub(/::/, '_'), time.year, time.yday] + args
            key_parts << time.hour if Exchange::Configuration.update == :hourly
            key_parts.join('_')
          end
        
      end
    end
  end
end