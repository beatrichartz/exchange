module Exchange
  module ExternalAPI
    
    # The ECB class, handling communication with the European Central Bank XML File API
    # You can find further information on the European Central Bank XML API API here: http://www.ecb.int/stats/exchange/eurofxref/html/index.en.html
    # @author Beat Richartz
    # @version 0.3
    # @since 0.3
    #
    class Ecb < XML
      
      # The base of the ECB API URL
      #
      API_URL              = "http://www.ecb.europa.eu/stats/eurofxref"
      
      # The currencies the ECB API URL can handle
      #
      CURRENCIES           = %W(eur usd jpy bgn czk dkk gbp huf ltl lvl pln ron sek chf nok hrk rub try aud brl cad cny hkd idr ils inr krw mxn myr nzd php sgd thb zar)
      
      # The result of the api call to the Central bank
      attr_accessor :callresult
      
      # Updates the rates by getting the information from ECB API for today or a defined historical date
      # The call gets cached for a maximum of 24 hours. Getting history from ECB is a bit special, since they do not seem to have
      # any smaller portion history than an epic 4MB XML history file and a 90 day recent history file. We get each of that once and cache it in smaller portions.
      # @param [Hash] opts Options to define for the API Call
      # @option opts [Time, String] :at a historical date to get the exchange rates for
      # @example Update the ecb API to use the file of March 2, 2010
      #   Exchange::ExternalAPI::Ecb.new.update(:at => Time.gm(3,2,2010))
      #
      def update(opts={})
        time          = Exchange::Helper.assure_time(opts[:at], :default => :now)
        times         = Exchange.configuration.api.retries.times.map{ |i| time - 86400 * (i+1) }
        
        # Since the Ecb File retrieved can be very large (> 5MB for the history file) and parsing takes a fair amount of time,
        # caching is doubled on this API
        # 
        Exchange.configuration.cache.subclass.cached(self.class, :at => time) do
          Call.new(api_url(time), call_opts(time)) do |result|
            t = time
            
            # Weekends do not have rates present
            #
            t = times.shift while (r = find_rate!(result, t)).empty? && !times.empty?
            
            @callresult = r.to_s
          end
        end

        parsed = Nokogiri.parse(self.callresult)
        
        @base                 = 'EUR' # We just have to assume, since it's the ECB
        @rates                = extract_rates(parsed.children.children)
        @timestamp            = time.to_i
      end
      
      private
      
        # A helper function which build a valid api url for the specified time
        # If the date is today, get the small daily file. If it is less than 90 days ago, get the 90 days file. 
        # If it is more than 90 days ago, get the big file
        # @param [Time] time The exchange rate date for which the URL should be built
        # @return [String] An ECB API URL to get the xml from
        #
        def api_url(time)
          border = Time.now - 90 * 86400
          [
            API_URL, 
            border <= time ? 'eurofxref-hist-90d.xml' : 'eurofxref-hist.xml'
          ].join('/')
        end
        
        # A helper method to find rates from the callresult given a certain time
        # ECB packs the rates in «Cubes», so we try to find the cube appropriate to the time
        # @param [Nokogiri::XML] parsed The parsed callresult
        # @param [Time] time The time to parse for
        # @return [Nokogiri::XML, NilClass] the rate, hopefully
        def find_rate! parsed, time
          parsed.css("Cube[time=\"#{time.strftime("%Y-%m-%d")}\"]")
        end
        
        # A helper method to extract rates from the callresult
        # @param [Nokogiri::XML] parsed the parsed api data
        # @return [Hash] a hash with rates
        #
        def extract_rates parsed
          rate_array = parsed.map { |c| 
            c.attributes.values.map{ |v| 
              v.value.match(/\d+/) ? BigDecimal.new(v.value) : v.value 
            }.sort_by(&:to_s).reverse unless c.attributes.values.empty? 
          }.compact.flatten
          
          to_hash!(['EUR', BigDecimal.new("1")] + rate_array)
        end
        
        # a wrapper for the call options, since the cache period is quite complex
        # @param [Time] time The date of the exchange rate
        # @return [Hash] a hash with the call options
        #
        def call_opts time
          {:format => :xml, :at => time, :cache => :file, :cache_period => time >= Time.now - 90 * 86400 ? :daily : :monthly}
        end
        
    end
  end
end