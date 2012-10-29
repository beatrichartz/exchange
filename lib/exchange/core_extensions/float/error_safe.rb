module Exchange
  
  # Make Floating Points forget about their incapabilities when dealing with money
  #
  module ErrorSafe
    
    def self.included base
      %W(* / + -).each do |meth|
        base.send(:define_method, :"#{meth}without_errors", lambda { |other|
          if other.is_a?(Exchange::Money)
            (BigDecimal.new(self.to_s).send(meth, other)).to_f
          else
            send(:"#{meth}with_errors", other)
          end
        })
        base.send :alias_method, :"#{meth}with_errors", meth.to_sym
        base.send :alias_method, meth.to_sym, :"#{meth}without_errors"
      end
    end
    
  end
  
end

Float.send(:include, Exchange::ErrorSafe)