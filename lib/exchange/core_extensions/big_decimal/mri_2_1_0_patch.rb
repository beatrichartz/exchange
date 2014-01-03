# -*- encoding : utf-8 -*-
module Exchange
  
  module MRI210Patch
    
    # A patch for https://www.ruby-forum.com/topic/4419577
    # Since the division values are off for values < 1,
    # multiply the BigDecimal instance by its precision
    #
    def / other
      if other.is_a?(BigDecimal) && other < 1
        precision = 10 * precs.first
        (self * precision) / (other * precision)
      else
        super
      end
    end
    alias :div :/

  end
  
end

BigDecimal.prepend Exchange::MRI210Patch if Exchange::BROKEN_BIG_DECIMAL_DIVISION #safeguard again if someone includes this file by accident