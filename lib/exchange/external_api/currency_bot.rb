module Exchange
  module ExternalAPI
    # The Currency Bot API class, handling communication with the Open Source Currency bot API
    # You can find further information on the currency bot API here: http://currencybot.github.com/
    # @author Beat Richartz
    # @version 0.1
    # @since 0.1
    
    class CurrencyBot < Base
      # The base of the Currency Bot exchange API
      API_URL              = 'https://raw.github.com/currencybot/open-exchange-rates/master'
      # The currencies the Currency Bot API can convert
      CURRENCIES           = %W(xcd usd sar rub nio lak nok omr amd cdf kpw cny kes zwd khr pln mvr gtq clp inr bzd myr hkd sek cop dkk byr lyd ron dzd bif ars gip bob xof std ngn pgk aed mwk cup gmd zwl tzs cve btn xaf ugx syp mad mnt lsl top shp rsd htg mga mzn lvl fkp bwp hnl eur egp chf ils pyg lbp ang kzt wst gyd thb npr kmf irr uyu srd jpy brl szl mop bmd xpf etb jod idr mdl mro yer bam awg nzd pen vef try sll aoa tnd tjs sgd scr lkr mxn ltl huf djf bsd gnf isk vuv sdg gel fjd dop xdr mur php mmk krw lrd bbd zmk zar vnd uah tmt iqd bgn gbp kgs ttd hrk rwf clf bhd uzs twd crc aud mkd pkr afn nad bdt azn czk sos iep pab qar svc sbd all jmd bnd cad kwd ghs)
      
      # Updates the rates by getting the information from Currency Bot for today or a defined historical date
      # The call gets cached for a maximum of 24 hours.
      # @param [Hash] opts Options to define for the API Call
      # @option opts [Time, String] :at a historical date to get the exchange rates for
      # @example Update the currency bot API to use the file of March 2, 2010
      #   Exchange::ExternalAPI::CurrencyBot.new.update(:at => Time.gm(3,2,2010))
      
      def update(opts={})
        time = Exchange::Helper.assure_time(opts[:at])
        
        Call.new(api_url(time), :at => time) do |result|
          @base                 = result['base']
          @rates                = Hash[*result['rates'].keys.zip(result['rates'].values.map{|v| BigDecimal.new(v.to_s) }).flatten]
          @timestamp            = result['timestamp'].to_i
        end
      end
            
      private
      
        # A helper function to build an api url for either a specific time or the latest available rates
        # @param [Time] time The time to build the api url for
        # @return [String] an api url for the time specified
        # @since 0.1
        # @version 0.2.6
      
        def api_url(time=nil)
          today = Time.now
          [API_URL, time && (time.year != today.year || time.yday != today.yday) ? "historical/#{time.strftime("%Y-%m-%d")}.json" : 'latest.json'].join('/')
        end
        
    end
  end
end