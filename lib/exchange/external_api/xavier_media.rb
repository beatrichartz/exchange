module Exchange
  module ExternalAPI    
    class XavierMedia < Base
      API_URL              = "http://api.finance.xaviermedia.com/api"
      CURRENCIES           = %W(eur usd jpy gbp cyp czk dkk eek huf ltl mtl pln sek sit skk chf isk nok bgn hrk rol ron rub trl aud cad cny hkd idr krw myr nzd php sgd thb zar)
      def update(opts={})
        time       = assure_time(opts[:at], :default => :now)
        api_url    = api_url(time)
        retry_urls = [api_url(time - 86400), api_url(time - 172800), api_url(time - 259200)]
        
        Call.new(api_url, :format => :xml, :at => time, :retry_with => retry_urls) do |result|
          self.base                 = result.css('basecurrency').children[0].to_s
          self.rates                = Hash[*result.css('fx currency_code').children.map(&:to_s).zip(result.css('fx rate').children.map{|c| c.to_s.to_f }).flatten]
          self.timestamp            = Time.gm(*result.css('fx_date').children[0].to_s.split('-')).to_i
        end
      end
      
      private
      
        def api_url(time)
          [API_URL, "#{time.strftime("%Y/%m/%d")}.xml"].join('/')
        end
        
    end
  end
end