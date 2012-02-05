module Exchange
  module ExternalAPI
    
    # The ECB class, handling communication with the European Central Bank XML File API
    # You can find further information on the European Central Bank XML API API here: http://www.ecb.int/stats/exchange/eurofxref/html/index.en.html
    # @author Beat Richartz
    # @version 0.3
    # @since 0.3
    
    class ECB < Base
      # The base of the ECB API URL
      API_URL              = "http://www.ecb.europa.eu/stats/eurofxref"
      # The currencies the ECB API URL can handle
      CURRENCIES           = %W(eur usd jpy bgn czk dkk gbp huf ltl lvl pln ron sek chf nok hrk rub try aud brl cad cny hkd idr ils inr krw mxn myr nzd php sgd thb zar)
      
      attr_accessor :callresult
      
      # Updates the rates by getting the information from ECB API for today or a defined historical date
      # The call gets cached for a maximum of 24 hours. Getting history from ECB is a bit special, since they do not seem to have
      # any smaller portion history than an epic 4MB XML history file and a 90 day recent history file. We get each of that once and cache it in smaller portions.
      # @param [Hash] opts Options to define for the API Call
      # @option opts [Time, String] :at a historical date to get the exchange rates for
      # @example Update the currency bot API to use the file of March 2, 2010
      #   Exchange::ExternalAPI::XavierMedia.new.update(:at => Time.gm(3,2,2010))
      
      def update(opts={})
        time          = Exchange::Helper.assure_time(opts[:at], :default => :now)
        api_url       = api_url(time)
        times         = Exchange::Configuration.retries.times.map{ |i| time - 86400 * (i+1) }
        
        Kernel.warn "WARNING: Using the ECB API without caching can be very, very slow." unless Configuration.cache
        
        Configuration.cache_class.cached(self.class, :at => time) do
          Call.new(api_url, :format => :xml, :at => time, :cache => :file, :cache_period => time >= Time.now - 90 * 86400 ? :daily : :monthly) do |result|
            t = time
            while (r = result.css("Cube[time=\"#{t.strftime("%Y-%m-%d")}\"]")).empty? && !times.empty?
              t = times.shift
            end
            @callresult = r.to_s
          end
        end

        parsed = Nokogiri.parse(self.callresult)
        
        @base                 = 'EUR' # We just have to assume, since it's the ECB
        @rates                = Hash[*(['EUR', BigDecimal.new("1")] + parsed.children.children.map {|c| c.attributes.values.map{|v| v.value.match(/\d/) ? BigDecimal.new(v.value) : v.value }.sort_by(&:to_s).reverse unless c.attributes.values.empty? }.compact.flatten)]
        @timestamp            = time.to_i
      end
      
      private
      
        # A helper function which build a valid api url for the specified time
        # If the date is today, get the small daily file. If it is less than 90 days ago, get the 90 days file. 
        # If it is more than 90 days ago, get the big file
        # @param [Time] time The exchange rate date for which the URL should be built
        # @return [String] An ECB API URL to get the xml from
      
        def api_url(time)
          border = Time.now - 90 * 86400
          [
            API_URL, 
            border <= time ? 'eurofxref-hist-90d.xml' : 'eurofxref-hist.xml'
          ].join('/')
        end
        
    end
  end
end