# -*- encoding : utf-8 -*-
module Exchange
  module Cachify
    
    # Use cachify as an alias for Marshal dumping
    #
    def cachify
      Marshal.dump self
    end
    
  end
  
  module Decachify
    
    # Use cachify as an alias for Marshal loading
    #
    def decachify
      Marshal.load self
    end
    
  end
end

Numeric.send  :include, Exchange::Cachify
String.send   :include, Exchange::Cachify
Symbol.send   :include, Exchange::Cachify
String.send   :include, Exchange::Decachify
Hash.send     :include, Exchange::Cachify
Array.send    :include, Exchange::Cachify
NilClass.send :include, Exchange::Cachify
