module Exchange
  module ExternalAPI
    # The Open Exchange Rates API class, handling communication with the Open Source Currency bot API
    # You can find further information on the Open Exchange Rates API here: http://openexchangerates.org
    # @author Beat Richartz
    # @version 0.1
    # @since 0.1
    #
    class OpenExchangeRates < Base
      
      # The base of the Open Exchange Rates exchange API
      #
      API_URL              = 'openexchangerates.org/api'
      
      # The currencies the Open Exchange Rates API can convert
      #
      CURRENCIES           = [:xcd, :usd, :sar, :rub, :nio, :lak, :nok, :omr, :amd, :cdf, :kpw, :cny, :kes, :zwd, :khr, :pln, :mvr, :gtq, :clp, :inr, :bzd, :myr, :hkd, :sek, :cop, :dkk, :byr, :lyd, :ron, :dzd, :bif, :ars, :gip, :bob, :xof, :std, :ngn, :pgk, :aed, :mwk, :cup, :gmd, :zwl, :tzs, :cve, :btn, :xaf, :ugx, :syp, :mad, :mnt, :lsl, :top, :shp, :rsd, :htg, :mga, :mzn, :lvl, :fkp, :bwp, :hnl, :eur, :egp, :chf, :ils, :pyg, :lbp, :ang, :kzt, :wst, :gyd, :thb, :npr, :kmf, :irr, :uyu, :srd, :jpy, :brl, :szl, :mop, :bmd, :xpf, :etb, :jod, :idr, :mdl, :mro, :yer, :bam, :awg, :nzd, :pen, :vef, :try, :sll, :aoa, :tnd, :tjs, :sgd, :scr, :lkr, :mxn, :ltl, :huf, :djf, :bsd, :gnf, :isk, :vuv, :sdg, :gel, :fjd, :dop, :xdr, :mur, :php, :mmk, :krw, :lrd, :bbd, :zmk, :zar, :vnd, :uah, :tmt, :iqd, :bgn, :gbp, :kgs, :ttd, :hrk, :rwf, :clf, :bhd, :uzs, :twd, :crc, :aud, :mkd, :pkr, :afn, :nad, :bdt, :azn, :czk, :sos, :iep, :pab, :qar, :svc, :sbd, :all, :jmd, :bnd, :cad, :kwd, :ghs]
      
      # Updates the rates by getting the information from Open Exchange Rates for today or a defined historical date
      # The call gets cached for a maximum of 24 hours.
      # @param [Hash] opts Options to define for the API Call
      # @option opts [Time, String] :at a historical date to get the exchange rates for
      # @example Update the Open Exchange Rates API to use the file of March 2, 2010
      #   Exchange::ExternalAPI::OpenExchangeRates.new.update(:at => Time.gm(3,2,2010))
      #
      def update(opts={})
        time = helper.assure_time(opts[:at])
        
        Call.new(api_url(time), :at => time) do |result|
          @base                 = result['base'].downcase.to_sym
          @rates                = extract_rates(result)
          @timestamp            = result['timestamp'].to_i
        end
      end
            
      private
      
        # Helper method to extract rates from the api call result
        # @param [JSON] parsed The parsed result
        # @return [Hash] A hash with rates
        # @since 0.7
        # @version 0.7
        #
        def extract_rates parsed
          to_hash! parsed['rates'].keys.map{|k| k.downcase.to_sym }.zip(parsed['rates'].values.map{|v| BigDecimal.new(v.to_s) }).flatten
        end
      
        # A helper function to build an api url for either a specific time or the latest available rates
        # @param [Time] time The time to build the api url for
        # @return [String] an api url for the time specified
        # @since 0.1
        # @version 0.2.6
        #
        def api_url(time=nil)
          today   = Time.now
          [ 
            "#{config.protocol}:/", 
            API_URL, 
            time && (time.year != today.year || time.yday != today.yday) ? "historical/#{time.strftime("%Y-%m-%d")}.json" : "latest.json"
          ].join('/') + "?app_id=#{config.app_id}"
        end
        
    end
  end
end