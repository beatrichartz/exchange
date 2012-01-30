module Exchange
  module ExternalAPI
    class Base      
      attr_accessor :base, :timestamp, :rates
      
      def rate(from, to, opts={})
        update(opts)
        self.rates[to.to_s.upcase] / self.rates[from.to_s.upcase]
      end
      
      def convert(amount, from, to, opts={})
        (amount.to_f * rate(from, to, opts) * 100).round.to_f / 100
      end
      
      protected
        
        def assure_time(arg=nil, opts={})
          if arg
            arg.kind_of?(Time) ? arg : Time.gm(*arg.split('-'))
          elsif opts[:default] == :now
            Time.now
          end
        end
        
    end
  end
end