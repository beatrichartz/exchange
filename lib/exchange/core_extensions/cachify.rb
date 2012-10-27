module Exchange
  module Cachify
    
    def cachify
      Marshal.dump self
    end
    
  end
  
  module Decachify
    
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