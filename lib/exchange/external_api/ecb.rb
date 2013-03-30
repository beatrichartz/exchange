# -*- encoding : utf-8 -*-
module Exchange
  module ExternalAPI
    
    # The ECB class, handling communication with the European Central Bank XML File API
    # You can find further information on the European Central Bank XML API API here: http://www.ecb.int/stats/exchange/eurofxref/html/index.en.html
    # @author Beat Richartz
    # @version 0.7
    # @since 0.3
    #
    class Ecb < XML
      
      # The base of the ECB API URL
      #
      API_URL              = "www.ecb.europa.eu/stats/eurofxref"
      
      # The currencies the ECB API URL can handle
      #
      CURRENCIES           = [:eur, :usd, :jpy, :bgn, :czk, :dkk, :gbp, :huf, :ltl, :lvl, :pln, :ron, :sek, :chf, :nok, :hrk, :rub, :try, :aud, :brl, :cad, :cny, :hkd, :idr, :ils, :inr, :krw, :mxn, :myr, :nzd, :php, :sgd, :thb, :zar] 
      
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
      # @since 0.1
      # @version 0.7
      #
      def update(opts={})
        time          = helper.assure_time(opts[:at], :default => :now)
        times         = map_retry_times time
        
        Call.new(api_url(time), call_opts(time)) do |result|
          t = time
          
          # Weekends do not have rates present
          #
          t = times.shift while (r = find_rate!(result, t)).empty? && !times.empty?
                    
          @base                 = :eur # We just have to assume, since it's the ECB
          @rates                = extract_rates(r.children)
          @timestamp            = time.to_i
        end
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
          [ "#{config.protocol}:/", 
            API_URL, 
            border <= time ? 'eurofxref-hist-90d.xml' : 'eurofxref-hist.xml'
          ].join('/')
        end
        
        # A helper method to find rates from the callresult given a certain time
        # ECB packs the rates in «Cubes», so we try to find the cube appropriate to the time
        # @param [Nokogiri::XML] parsed The parsed callresult
        # @param [Time] time The time to parse for
        # @return [Nokogiri::XML, NilClass] the rate, hopefully
        # @since 0.7
        # @version 0.7
        #
        def find_rate! parsed, time
          parsed.css("Cube[time=\"#{time.strftime("%Y-%m-%d")}\"]")
        end
        
        # A helper method to extract rates from the callresult
        # @param [Nokogiri::XML] parsed the parsed api data
        # @return [Hash] a hash with rates
        # @since 0.7
        # @version 0.7
        #
        def extract_rates parsed
          rate_array = parsed.map { |c| 
            map_to_currency_or_rate c
          }.compact.flatten
          
          to_hash!([:eur, BigDecimal.new("1")] + rate_array)
        end
        
        # a helper method to map a key value pair to either currency or rate
        # @param [Nokogiri::XML] xml a parsed xml part of the document
        # @return [Array] An array with the following structure [currency, value, currency, value]
        # @since 0.7
        # @version 0.7
        #
        def map_to_currency_or_rate xml
          unless (values = xml.attributes.values).empty?
            values.map { |v|
              val = v.value
              val.match(/\d+/) ? BigDecimal.new(val) : val.downcase.to_sym
            }.sort_by(&:to_s).reverse 
          end
        end
        
        # Helper method to map retry times
        # @param [Time] time The time to start with
        # @return [Array] An array of times to retry api operation with
        # @since 0.7
        # @version 0.7
        #
        def map_retry_times time
          config.retries.times.map{ |i| time - 86400 * (i+1) }
        end
        
        # a wrapper for the call options, since the cache period is quite complex
        # @param [Time] time The date of the exchange rate
        # @return [Hash] a hash with the call options
        # @since 0.6
        # @version 0.6
        #
        def call_opts time
          {:format => :xml, :at => time, :cache => :file, :cache_period => time >= Time.now - 90 * 86400 ? :daily : :monthly}
        end
        
    end
  end
end
