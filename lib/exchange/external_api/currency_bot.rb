module Exchange
  module ExternalAPI    
    class CurrencyBot < Base
      API_URL              = 'https://raw.github.com/currencybot/open-exchange-rates/master/latest.json'
      CURRENCIES           = %W(xcd usd sar rub nio lak nok omr amd cdf kpw cny kes zwd khr pln mvr gtq clp inr bzd myr hkd sek cop dkk byr lyd ron dzd bif ars gip bob xof std ngn pgk aed mwk cup gmd zwl tzs cve btn xaf ugx syp mad mnt lsl top shp rsd htg mga mzn lvl fkp bwp hnl eur egp chf ils pyg lbp ang kzt wst gyd thb npr kmf irr uyu srd jpy brl szl mop bmd xpf etb jod idr mdl mro yer bam awg nzd pen vef try sll aoa tnd tjs sgd scr lkr mxn ltl huf djf bsd gnf isk vuv sdg gel fjd dop xdr mur php mmk krw lrd bbd zmk zar vnd uah tmt iqd bgn gbp kgs ttd hrk rwf clf bhd uzs twd crc aud mkd pkr afn nad bdt azn czk sos iep pab qar svc sbd all jmd bnd cad kwd ghs)
      def update
        Call.new(API_URL) do |result|
          self.base                 = result['base']
          self.rates                = result['rates']
          self.timestamp            = result['timestamp'].to_i
        end
      end
    end
  end
end