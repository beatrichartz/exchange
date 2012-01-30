module Exchange
  module ExternalAPI
    class Base      
      attr_accessor :base, :timestamp, :rates
      
      def rate(from, to)
        update
        self.rates[to.to_s.upcase] / self.rates[from.to_s.upcase]
      end
      
      def convert(amount, from, to)
        (amount.to_f * rate(from, to) * 100).round.to_f / 100
      end
    end
  end
end