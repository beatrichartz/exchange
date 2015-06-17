# -*- encoding : utf-8 -*-

require 'spec_helper'

describe "Exchange::ISO" do
  let(:subject) { Exchange::ISO }
  describe "self.definitions" do
    it "should be a hash of exactly the ISO standard definitions loaded from the yaml file" do
      expect(subject.definitions).to be === {
        :nio=>{:minor_unit=>2, :currency=>"Cordoba Oro", :symbol=>"C$"}, 
        :lak=>{:minor_unit=>2, :currency=>"Kip", :symbol=>"₭"}, 
        :sar=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Saudi Riyal", :symbol=>"﷼"}, 
        :nok=>{:separators=>{:major=>".", :minor=>","}, :minor_unit=>2, :currency=>"Norwegian Krone", :symbol=>"kr"}, 
        :usd=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"US Dollar", :symbol=>"$"}, 
        :rub=>{:separators=>{:major=>".", :minor=>","}, :minor_unit=>2, :currency=>"Russian Ruble", :symbol=>"руб"}, 
        :xcd=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"East Caribbean Dollar", :symbol=>"$"}, 
        :omr=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>3, :currency=>"Rial Omani", :symbol=>"﷼"}, 
        :amd=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Armenian Dram", :symbol=>nil}, 
        :cdf=>{:minor_unit=>2, :currency=>"Congolese Franc", :symbol=>nil}, 
        :kpw=>{:minor_unit=>2, :currency=>"North Korean Won", :symbol=>"₩"}, 
        :cny=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Yuan Renminbi", :symbol=>"¥"}, 
        :kes=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Kenyan Shilling", :symbol=>nil}, 
        :khr=>{:minor_unit=>2, :currency=>"Riel", :symbol=>"៛"}, 
        :pln=>{:separators=>{:major=>" ", :minor=>","}, :minor_unit=>2, :currency=>"Zloty", :symbol=>"zł"}, 
        :mvr=>{:minor_unit=>2, :currency=>"Rufiyaa", :symbol=>nil}, 
        :gtq=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Quetzal", :symbol=>"Q"}, 
        :clp=>{:separators=>{:major=>"."}, :minor_unit=>0, :currency=>"Chilean Peso", :symbol=>"$"}, 
        :inr=>{:separators=>{:major=>",", :minor=>"."}, :format=>"#,##,###.##", :minor_unit=>2, :currency=>"Indian Rupee", :symbol=>""}, 
        :bzd=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Belize Dollar", :symbol=>"BZ$"}, 
        :myr=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Malaysian Ringgit", :symbol=>"RM"}, 
        :hkd=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Hong Kong Dollar", :symbol=>"$"}, 
        :cop=>{:separators=>{:major=>".", :minor=>","}, :minor_unit=>2, :currency=>"Colombian Peso", :symbol=>"$"}, 
        :dkk=>{:separators=>{:major=>".", :minor=>","}, :minor_unit=>2, :currency=>"Danish Krone", :symbol=>"kr"}, 
        :sek=>{:separators=>{:major=>".", :minor=>","}, :minor_unit=>2, :currency=>"Swedish Krona", :symbol=>"kr"}, 
        :byr=>{:minor_unit=>0, :currency=>"Belarussian Ruble", :symbol=>"p."}, 
        :lyd=>{:minor_unit=>3, :currency=>"Libyan Dinar", :symbol=>nil}, 
        :ron=>{:separators=>{:major=>".", :minor=>","}, :minor_unit=>2, :currency=>"New Romanian Leu", :symbol=>"lei"}, 
        :dzd=>{:minor_unit=>2, :currency=>"Algerian Dinar", :symbol=>nil}, :bif=>{:minor_unit=>0, :currency=>"Burundi Franc", :symbol=>nil}, 
        :ars=>{:separators=>{:major=>".", :minor=>","}, :minor_unit=>2, :currency=>"Argentine Peso", :symbol=>"$"}, 
        :gip=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Gibraltar Pound", :symbol=>"£"}, 
        :uyi=>{:minor_unit=>0, :currency=>"Uruguay Peso en Unidades Indexadas (URUIURUI)", :symbol=>nil}, 
        :bob=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Boliviano", :symbol=>"$b"}, 
        :ssp=>{:minor_unit=>2, :currency=>"South Sudanese Pound", :symbol=>nil}, 
        :ngn=>{:minor_unit=>2, :currency=>"Naira", :symbol=>"₦"}, 
        :pgk=>{:minor_unit=>2, :currency=>"Kina", :symbol=>nil}, 
        :std=>{:minor_unit=>2, :currency=>"Dobra", :symbol=>nil}, 
        :xof=>{:minor_unit=>0, :currency=>"CFA Franc BCEAO", :symbol=>nil}, 
        :aed=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"UAE Dirham", :symbol=>nil}, 
        :ern=>{:minor_unit=>2, :currency=>"Nakfa", :symbol=>nil}, :mwk=>{:minor_unit=>2, :currency=>"Kwacha", :symbol=>nil}, 
        :cup=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Cuban Peso", :symbol=>"₱"}, 
        :usn=>{:minor_unit=>2, :currency=>"US Dollar (Next day)", :symbol=>nil}, 
        :gmd=>{:minor_unit=>2, :currency=>"Dalasi", :symbol=>nil}, 
        :cve=>{:minor_unit=>2, :currency=>"Cape Verde Escudo", :symbol=>nil}, 
        :tzs=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Tanzanian Shilling", :symbol=>nil}, 
        :cou=>{:minor_unit=>2, :currency=>"Unidad de Valor Real", :symbol=>nil}, 
        :btn=>{:minor_unit=>2, :currency=>"Ngultrum", :symbol=>nil},
        :zwl=>{:minor_unit=>2, :currency=>"Zimbabwe Dollar", :symbol=>nil}, 
        :ugx=>{:minor_unit=>2, :currency=>"Uganda Shilling", :symbol=>nil}, 
        :syp=>{:minor_unit=>2, :currency=>"Syrian Pound", :symbol=>"£"}, 
        :mad=>{:minor_unit=>2, :currency=>"Moroccan Dirham", :symbol=>nil}, 
        :mnt=>{:minor_unit=>2, :currency=>"Tugrik", :symbol=>"₮"}, 
        :lsl=>{:minor_unit=>2, :currency=>"Loti", :symbol=>nil}, 
        :xaf=>{:minor_unit=>0, :currency=>"CFA Franc BEAC", :symbol=>nil}, 
        :shp=>{:minor_unit=>2, :currency=>"Saint Helena Pound", :symbol=>"£"}, 
        :htg=>{:minor_unit=>2, :currency=>"Gourde", :symbol=>nil}, 
        :rsd=>{:minor_unit=>2, :currency=>"Serbian Dinar", :symbol=>"Дин."}, 
        :mga=>{:minor_unit=>2, :currency=>"Malagasy Ariary", :symbol=>nil},
        :top=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Pa’anga", :symbol=>nil}, 
        :mzn=>{:minor_unit=>2, :currency=>"Mozambique Metical", :symbol=>"MT"}, 
        :lvl=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Latvian Lats", :symbol=>"Ls"}, 
        :fkp=>{:minor_unit=>2, :currency=>"Falkland Islands Pound", :symbol=>"£"}, 
        :uss=>{:minor_unit=>2, :currency=>"US Dollar (Same day)", :symbol=>nil}, 
        :bwp=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Pula", :symbol=>"P"}, 
        :hnl=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Lempira", :symbol=>"L"}, 
        :eur=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Euro", :symbol=>"€"}, 
        :egp=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Egyptian Pound", :symbol=>"£"}, 
        :chf=>{:separators=>{:major=>"'", :minor=>"."}, :minor_unit=>2, :currency=>"Swiss Franc"}, 
        :ils=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"New Israeli Sheqel", :symbol=>"₪"}, 
        :pyg=>{:minor_unit=>0, :currency=>"Guarani", :symbol=>"Gs"}, 
        :lbp=>{:separators=>{:major=>" ", :minor=>"."}, :minor_unit=>2, :currency=>"Lebanese Pound", :symbol=>"£"}, 
        :ang=>{:separators=>{:major=>".", :minor=>","}, :minor_unit=>2, :currency=>"Netherlands Antillean Guilder", :symbol=>"ƒ"}, 
        :kzt=>{:minor_unit=>2, :currency=>"Tenge", :symbol=>"лв"}, 
        :gyd=>{:minor_unit=>2, :currency=>"Guyana Dollar", :symbol=>"$"}, 
        :wst=>{:minor_unit=>2, :currency=>"Tala", :symbol=>nil}, 
        :npr=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Nepalese Rupee", :symbol=>"₨"}, 
        :kmf=>{:minor_unit=>0, :currency=>"Comoro Franc", :symbol=>nil}, 
        :thb=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Baht", :symbol=>"฿"}, 
        :irr=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Iranian Rial", :symbol=>"﷼"}, 
        :srd=>{:minor_unit=>2, :currency=>"Surinam Dollar", :symbol=>"$"}, 
        :jpy=>{:separators=>{:major=>","}, :minor_unit=>0, :currency=>"Yen", :symbol=>"¥"}, 
        :brl=>{:separators=>{:major=>".", :minor=>","}, :minor_unit=>2, :currency=>"Brazilian Real", :symbol=>"R$"}, 
        :uyu=>{:separators=>{:major=>".", :minor=>","}, :minor_unit=>2, :currency=>"Peso Uruguayo", :symbol=>"$U"}, 
        :mop=>{:minor_unit=>2, :currency=>"Pataca", :symbol=>nil}, 
        :bmd=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Bermudian Dollar", :symbol=>"$"}, 
        :szl=>{:separators=>{:major=>", ", :minor=>"."}, :minor_unit=>2, :currency=>"Lilangeni", :symbol=>nil}, 
        :etb=>{:minor_unit=>2, :currency=>"Ethiopian Birr", :symbol=>nil}, 
        :jod=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>3, :currency=>"Jordanian Dinar", :symbol=>nil},
        :idr=>{:separators=>{:major=>".", :minor=>","}, :minor_unit=>2, :currency=>"Rupiah", :symbol=>"Rp"}, 
        :mdl=>{:minor_unit=>2, :currency=>"Moldovan Leu", :symbol=>nil}, 
        :xpf=>{:minor_unit=>0, :currency=>"CFP Franc", :symbol=>nil}, 
        :mro=>{:minor_unit=>2, :currency=>"Ouguiya", :symbol=>nil}, 
        :yer=>{:minor_unit=>2, :currency=>"Yemeni Rial", :symbol=>"﷼"}, 
        :bam=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Convertible Mark", :symbol=>"KM"}, 
        :awg=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Aruban Florin", :symbol=>"ƒ"}, 
        :nzd=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"New Zealand Dollar", :symbol=>"$"}, 
        :pen=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Nuevo Sol", :symbol=>"S/."}, 
        :aoa=>{:minor_unit=>2, :currency=>"Kwanza", :symbol=>nil}, 
        :kyd=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Cayman Islands Dollar", :symbol=>"$"}, 
        :sll=>{:minor_unit=>2, :currency=>"Leone", :symbol=>nil}, 
        :try=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Turkish Lira", :symbol=>""}, 
        :vef=>{:separators=>{:major=>".", :minor=>","}, :minor_unit=>2, :currency=>"Bolivar Fuerte", :symbol=>"Bs"}, 
        :isk=>{:format=>"#.###", :minor_unit=>0, :currency=>"Iceland Krona", :symbol=>"kr"}, 
        :gnf=>{:minor_unit=>0, :currency=>"Guinea Franc", :symbol=>nil}, 
        :bsd=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Bahamian Dollar", :symbol=>"$"}, 
        :djf=>{:minor_unit=>0, :currency=>"Djibouti Franc", :symbol=>nil}, 
        :huf=>{:separators=>{:major=>".", :minor=>"."}, :minor_unit=>2, :currency=>"Forint", :symbol=>"Ft"}, 
        :ltl=>{:separators=>{:major=>" ", :minor=>","}, :minor_unit=>2, :currency=>"Lithuanian Litas", :symbol=>"Lt"}, 
        :mxn=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Mexican Peso", :symbol=>"$"}, 
        :scr=>{:minor_unit=>2, :currency=>"Seychelles Rupee", :symbol=>"₨"}, 
        :sgd=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Singapore Dollar", :symbol=>"$"}, 
        :lkr=>{:minor_unit=>2, :currency=>"Sri Lanka Rupee", :symbol=>"₨"}, 
        :tjs=>{:minor_unit=>2, :currency=>"Somoni", :symbol=>nil}, 
        :tnd=>{:minor_unit=>3, :currency=>"Tunisian Dinar", :symbol=>nil}, 
        :dop=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Dominican Peso", :symbol=>"RD$"}, 
        :fjd=>{:minor_unit=>2, :currency=>"Fiji Dollar", :symbol=>"$"}, 
        :gel=>{:minor_unit=>2, :currency=>"Lari", :symbol=>nil}, :sdg=>{:minor_unit=>2, :currency=>"Sudanese Pound", :symbol=>nil}, 
        :vuv=>{:separators=>{:major=>","}, :minor_unit=>0, :currency=>"Vatu", :symbol=>nil}, 
        :bbd=>{:minor_unit=>2, :currency=>"Barbados Dollar", :symbol=>"$"}, 
        :lrd=>{:minor_unit=>2, :currency=>"Liberian Dollar", :symbol=>"$"}, 
        :krw=>{:separators=>{:major=>","}, :minor_unit=>0, :currency=>"Won", :symbol=>"₩"}, 
        :mmk=>{:minor_unit=>2, :currency=>"Kyat", :symbol=>nil}, 
        :mur=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Mauritius Rupee", :symbol=>"₨"}, 
        :php=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Philippine Peso", :symbol=>"₱"}, 
        :zar=>{:separators=>{:major=>" ", :minor=>"."}, :minor_unit=>2, :currency=>"Rand", :symbol=>"R"}, 
        :kgs=>{:minor_unit=>2, :currency=>"Som", :symbol=>"лв"}, 
        :gbp=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Pound Sterling", :symbol=>"£"}, 
        :bgn=>{:minor_unit=>2, :currency=>"Bulgarian Lev", :symbol=>"лв"}, 
        :iqd=>{:minor_unit=>3, :currency=>"Iraqi Dinar", :symbol=>nil}, 
        :tmt=>{:minor_unit=>2, :currency=>"Turkmenistan New Manat", :symbol=>nil}, 
        :uah=>{:separators=>{:major=>" ", :minor=>","}, :minor_unit=>2, :currency=>"Hryvnia", :symbol=>"₴"}, 
        :vnd=>{:separators=>{:major=>"."}, :minor_unit=>0, :currency=>"Dong", :symbol=>"₫"}, 
        :zmk=>{:minor_unit=>2, :currency=>"Zambian Kwacha", :symbol=>nil}, 
        :bov=>{:minor_unit=>2, :currency=>"Mvdol", :symbol=>nil}, 
        :hrk=>{:separators=>{:major=>".", :minor=>","}, :minor_unit=>2, :currency=>"Croatian Kuna", :symbol=>"kn"}, 
        :ttd=>{:minor_unit=>2, :currency=>"Trinidad and Tobago Dollar", :symbol=>"TT$"}, 
        :bhd=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>3, :currency=>"Bahraini Dinar", :symbol=>nil}, 
        :clf=>{:minor_unit=>0, :currency=>"Unidades de fomento", :symbol=>nil}, 
        :rwf=>{:minor_unit=>0, :currency=>"Rwanda Franc", :symbol=>nil}, 
        :mkd=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Denar", :symbol=>"ден"}, 
        :aud=>{:separators=>{:major=>" ", :minor=>"."}, :minor_unit=>2, :currency=>"Australian Dollar", :symbol=>"$"}, 
        :crc=>{:separators=>{:major=>".", :minor=>","}, :minor_unit=>2, :currency=>"Costa Rican Colon", :symbol=>"₡"},
        :pkr=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Pakistan Rupee", :symbol=>"₨"}, 
        :twd=>{:minor_unit=>2, :currency=>"New Taiwan Dollar", :symbol=>"NT$"}, 
        :uzs=>{:minor_unit=>2, :currency=>"Uzbekistan Sum", :symbol=>"лв"}, 
        :czk=>{:separators=>{:major=>".", :minor=>","}, :minor_unit=>2, :currency=>"Czech Koruna", :symbol=>"Kč"}, 
        :azn=>{:minor_unit=>2, :currency=>"Azerbaijanian Manat", :symbol=>"ман"}, 
        :bdt=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Taka", :symbol=>nil}, 
        :nad=>{:minor_unit=>2, :currency=>"Namibia Dollar", :symbol=>"$"}, 
        :afn=>{:minor_unit=>2, :currency=>"Afghani", :symbol=>"؋"}, 
        :mxv=>{:minor_unit=>2, :currency=>"Mexican Unidad de Inversion (UDI)", :symbol=>nil}, 
        :cuc=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Peso Convertible", :symbol=>nil}, 
        :pab=>{:minor_unit=>2, :currency=>"Balboa", :symbol=>"B/."}, 
        :qar=>{:minor_unit=>2, :currency=>"Qatari Rial", :symbol=>"﷼"}, 
        :sos=>{:minor_unit=>2, :currency=>"Somali Shilling", :symbol=>"S"}, 
        :chw=>{:minor_unit=>2, :currency=>"WIR Franc", :symbol=>nil}, 
        :cad=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Canadian Dollar", :symbol=>"$"}, 
        :jmd=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Jamaican Dollar", :symbol=>"J$"}, 
        :bnd=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"Brunei Dollar", :symbol=>"$"}, 
        :all=>{:minor_unit=>2, :currency=>"Lek", :symbol=>"Lek"}, 
        :svc=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>2, :currency=>"El Salvador Colon", :symbol=>"$"}, 
        :sbd=>{:minor_unit=>2, :currency=>"Solomon Islands Dollar", :symbol=>"$"}, 
        :ghs=>{:minor_unit=>2, :currency=>"Ghana Cedi", :symbol=>nil}, 
        :kwd=>{:separators=>{:major=>",", :minor=>"."}, :minor_unit=>3, :currency=>"Kuwaiti Dinar", :symbol=>nil}}
    end
  end
  describe "self.country_map" do
    it "should deliver a complete map of country abbreviations to currencies" do
      expect(subject.country_map).to eq({
        :af=>:afn,
        :afg=>:afn,
        :ax=>:eur,
        :ala=>:eur,
        :al=>:all,
        :alb=>:all,
        :dz=>:dzd,
        :dza=>:dzd,
        :as=>:usd,
        :asm=>:usd,
        :ad=>:eur,
        :and=>:eur,
        :ao=>:aoa,
        :ago=>:aoa,
        :ai=>:xcd,
        :aia=>:xcd,
        :ag=>:xcd,
        :atg=>:xcd,
        :ar=>:ars,
        :arg=>:ars,
        :am=>:amd,
        :arm=>:amd,
        :aw=>:awg,
        :abw=>:awg,
        :au=>:aud,
        :aus=>:aud,
        :at=>:eur,
        :aut=>:eur,
        :az=>:azn,
        :aze=>:azn,
        :bs=>:bsd,
        :bhs=>:bsd,
        :bh=>:bhd,
        :bhr=>:bhd,
        :bd=>:bdt,
        :bgd=>:bdt,
        :bb=>:bbd,
        :brb=>:bbd,
        :by=>:byr,
        :blr=>:byr,
        :be=>:eur,
        :bel=>:eur,
        :bz=>:bzd,
        :blz=>:bzd,
        :bj=>:xof,
        :ben=>:xof,
        :bm=>:bmd,
        :bmu=>:bmd,
        :bt=>:btn,
        :btn=>:btn,
        :bo=>:bob,
        :bol=>:bob,
        :bq=>:usd,
        :bes=>:usd,
        :ba=>:bam,
        :bih=>:bam,
        :bw=>:bwp,
        :bwa=>:bwp,
        :bv=>:nok,
        :bvt=>:nok,
        :br=>:brl,
        :bra=>:brl,
        :io=>:usd,
        :iot=>:usd,
        :um=>:usd,
        :umi=>:usd,
        :vg=>:usd,
        :vgb=>:usd,
        :bn=>:bnd,
        :brn=>:bnd,
        :bg=>:bgn,
        :bgr=>:bgn,
        :bf=>:xof,
        :bfa=>:xof,
        :bi=>:bif,
        :bdi=>:bif,
        :kh=>:khr,
        :khm=>:khr,
        :cm=>:xaf,
        :cmr=>:xaf,
        :ca=>:cad,
        :can=>:cad,
        :cv=>:cve,
        :cpv=>:cve,
        :ky=>:kyd,
        :cym=>:kyd,
        :cf=>:xaf,
        :caf=>:xaf,
        :td=>:xaf,
        :tcd=>:xaf,
        :cl=>:clp,
        :chl=>:clp,
        :cn=>:cny,
        :chn=>:cny,
        :cx=>:aud,
        :cxr=>:aud,
        :cc=>:aud,
        :cck=>:aud,
        :co=>:cop,
        :col=>:cop,
        :km=>:kmf,
        :com=>:kmf,
        :cg=>:xaf,
        :cog=>:xaf,
        :cd=>:cdf,
        :cod=>:cdf,
        :ck=>:nzd,
        :cok=>:nzd,
        :cr=>:crc,
        :cri=>:crc,
        :hr=>:hrk,
        :hrv=>:hrk,
        :cu=>:cuc,
        :cub=>:cuc,
        :cw=>:ang,
        :cuw=>:ang,
        :cy=>:eur,
        :cyp=>:eur,
        :cz=>:czk,
        :cze=>:czk,
        :dk=>:dkk,
        :dnk=>:dkk,
        :dj=>:djf,
        :dji=>:djf,
        :dm=>:xcd,
        :dma=>:xcd,
        :do=>:dop,
        :dom=>:dop,
        :ec=>:usd,
        :ecu=>:usd,
        :eg=>:egp,
        :egy=>:egp,
        :sv=>:usd,
        :slv=>:usd,
        :gq=>:xaf,
        :gnq=>:xaf,
        :er=>:ern,
        :eri=>:ern,
        :ee=>:eur,
        :est=>:eur,
        :et=>:etb,
        :eth=>:etb,
        :fk=>:fkp,
        :flk=>:fkp,
        :fo=>:dkk,
        :fro=>:dkk,
        :fj=>:fjd,
        :fji=>:fjd,
        :fi=>:eur,
        :fin=>:eur,
        :fr=>:eur,
        :fra=>:eur,
        :gf=>:eur,
        :guf=>:eur,
        :pf=>:xpf,
        :pyf=>:xpf,
        :tf=>:eur,
        :atf=>:eur,
        :ga=>:xaf,
        :gab=>:xaf,
        :gm=>:gmd,
        :gmb=>:gmd,
        :ge=>:gel,
        :geo=>:gel,
        :de=>:eur,
        :deu=>:eur,
        :gh=>:ghs,
        :gha=>:ghs,
        :gi=>:gip,
        :gib=>:gip,
        :gr=>:eur,
        :grc=>:eur,
        :gl=>:dkk,
        :grl=>:dkk,
        :gd=>:xcd,
        :grd=>:xcd,
        :gp=>:eur,
        :glp=>:eur,
        :gu=>:usd,
        :gum=>:usd,
        :gt=>:gtq,
        :gtm=>:gtq,
        :gg=>:gbp,
        :ggy=>:gbp,
        :gn=>:gnf,
        :gin=>:gnf,
        :gw=>:xof,
        :gnb=>:xof,
        :gy=>:gyd,
        :guy=>:gyd,
        :ht=>:htg,
        :hti=>:htg,
        :hm=>:aud,
        :hmd=>:aud,
        :hn=>:hnl,
        :hnd=>:hnl,
        :hk=>:hkd,
        :hkg=>:hkd,
        :hu=>:huf,
        :hun=>:huf,
        :is=>:isk,
        :isl=>:isk,
        :in=>:inr,
        :ind=>:inr,
        :id=>:idr,
        :idn=>:idr,
        :ci=>:xof,
        :civ=>:xof,
        :ir=>:irr,
        :irn=>:irr,
        :iq=>:iqd,
        :irq=>:iqd,
        :ie=>:eur,
        :irl=>:eur,
        :im=>:gbp,
        :imn=>:gbp,
        :il=>:ils,
        :isr=>:ils,
        :it=>:eur,
        :ita=>:eur,
        :jm=>:jmd,
        :jam=>:jmd,
        :jp=>:jpy,
        :jpn=>:jpy,
        :je=>:gbp,
        :jey=>:gbp,
        :jo=>:jod,
        :jor=>:jod,
        :kz=>:kzt,
        :kaz=>:kzt,
        :ke=>:kes,
        :ken=>:kes,
        :ki=>:aud,
        :kir=>:aud,
        :kw=>:kwd,
        :kwt=>:kwd,
        :kg=>:kgs,
        :kgz=>:kgs,
        :la=>:lak,
        :lao=>:lak,
        :lv=>:eur,
        :lva=>:eur,
        :lb=>:lbp,
        :lbn=>:lbp,
        :ls=>:lsl,
        :lso=>:lsl,
        :lr=>:lrd,
        :lbr=>:lrd,
        :ly=>:lyd,
        :lby=>:lyd,
        :li=>:chf,
        :lie=>:chf,
        :lt=>:eur,
        :ltu=>:eur,
        :lu=>:eur,
        :lux=>:eur,
        :mo=>:mop,
        :mac=>:mop,
        :mk=>:mkd,
        :mkd=>:mkd,
        :mg=>:mga,
        :mdg=>:mga,
        :mw=>:mwk,
        :mwi=>:mwk,
        :my=>:myr,
        :mys=>:myr,
        :mv=>:mvr,
        :mdv=>:mvr,
        :ml=>:xof,
        :mli=>:xof,
        :mt=>:eur,
        :mlt=>:eur,
        :mh=>:usd,
        :mhl=>:usd,
        :mq=>:eur,
        :mtq=>:eur,
        :mr=>:mro,
        :mrt=>:mro,
        :mu=>:mur,
        :mus=>:mur,
        :yt=>:eur,
        :myt=>:eur,
        :mx=>:mxn,
        :mex=>:mxn,
        :fm=>:usd,
        :fsm=>:usd,
        :md=>:mdl,
        :mda=>:mdl,
        :mc=>:eur,
        :mco=>:eur,
        :mn=>:mnt,
        :mng=>:mnt,
        :me=>:eur,
        :mne=>:eur,
        :ms=>:xcd,
        :msr=>:xcd,
        :ma=>:mad,
        :mar=>:mad,
        :mz=>:mzn,
        :moz=>:mzn,
        :mm=>:mmk,
        :mmr=>:mmk,
        :na=>:nad,
        :nam=>:nad,
        :nr=>:aud,
        :nru=>:aud,
        :np=>:npr,
        :npl=>:npr,
        :nl=>:eur,
        :nld=>:eur,
        :nc=>:xpf,
        :ncl=>:xpf,
        :nz=>:nzd,
        :nzl=>:nzd,
        :ni=>:nio,
        :nic=>:nio,
        :ne=>:xof,
        :ner=>:xof,
        :ng=>:ngn,
        :nga=>:ngn,
        :nu=>:nzd,
        :niu=>:nzd,
        :nf=>:aud,
        :nfk=>:aud,
        :kp=>:kpw,
        :prk=>:kpw,
        :mp=>:usd,
        :mnp=>:usd,
        :no=>:nok,
        :nor=>:nok,
        :om=>:omr,
        :omn=>:omr,
        :pk=>:pkr,
        :pak=>:pkr,
        :pw=>:usd,
        :plw=>:usd,
        :ps=>:ils,
        :pse=>:ils,
        :pa=>:pab,
        :pan=>:pab,
        :pg=>:pgk,
        :png=>:pgk,
        :py=>:pyg,
        :pry=>:pyg,
        :pe=>:pen,
        :per=>:pen,
        :ph=>:php,
        :phl=>:php,
        :pn=>:nzd,
        :pcn=>:nzd,
        :pl=>:pln,
        :pol=>:pln,
        :pt=>:eur,
        :prt=>:eur,
        :pr=>:usd,
        :pri=>:usd,
        :qa=>:qar,
        :qat=>:qar,
        :xk=>:eur,
        :kos=>:eur,
        :re=>:eur,
        :reu=>:eur,
        :ro=>:ron,
        :rou=>:ron,
        :ru=>:rub,
        :rus=>:rub,
        :rw=>:rwf,
        :rwa=>:rwf,
        :bl=>:eur,
        :blm=>:eur,
        :sh=>:shp,
        :shn=>:shp,
        :kn=>:xcd,
        :kna=>:xcd,
        :lc=>:xcd,
        :lca=>:xcd,
        :mf=>:eur,
        :maf=>:eur,
        :pm=>:eur,
        :spm=>:eur,
        :vc=>:xcd,
        :vct=>:xcd,
        :ws=>:wst,
        :wsm=>:wst,
        :sm=>:eur,
        :smr=>:eur,
        :st=>:std,
        :stp=>:std,
        :sa=>:sar,
        :sau=>:sar,
        :sn=>:xof,
        :sen=>:xof,
        :rs=>:rsd,
        :srb=>:rsd,
        :sc=>:scr,
        :syc=>:scr,
        :sl=>:sll,
        :sle=>:sll,
        :sg=>:sgd,
        :sgp=>:sgd,
        :sx=>:ang,
        :sxm=>:ang,
        :sk=>:eur,
        :svk=>:eur,
        :si=>:eur,
        :svn=>:eur,
        :sb=>:sbd,
        :slb=>:sbd,
        :so=>:sos,
        :som=>:sos,
        :za=>:zar,
        :zaf=>:zar,
        :gs=>:gbp,
        :sgs=>:gbp,
        :kr=>:krw,
        :kor=>:krw,
        :ss=>:ssp,
        :ssd=>:ssp,
        :es=>:eur,
        :esp=>:eur,
        :lk=>:lkr,
        :lka=>:lkr,
        :sd=>:sdg,
        :sdn=>:sdg,
        :sr=>:srd,
        :sur=>:srd,
        :sj=>:nok,
        :sjm=>:nok,
        :sz=>:szl,
        :swz=>:szl,
        :se=>:sek,
        :swe=>:sek,
        :ch=>:chf,
        :che=>:chf,
        :sy=>:syp,
        :syr=>:syp,
        :tw=>:twd,
        :twn=>:twd,
        :tj=>:tjs,
        :tjk=>:tjs,
        :tz=>:tzs,
        :tza=>:tzs,
        :th=>:thb,
        :tha=>:thb,
        :tl=>:usd,
        :tls=>:usd,
        :tg=>:xof,
        :tgo=>:xof,
        :tk=>:nzd,
        :tkl=>:nzd,
        :to=>:top,
        :ton=>:top,
        :tt=>:ttd,
        :tto=>:ttd,
        :tn=>:tnd,
        :tun=>:tnd,
        :tr=>:try,
        :tur=>:try,
        :tm=>:tmt,
        :tkm=>:tmt,
        :tc=>:usd,
        :tca=>:usd,
        :tv=>:aud,
        :tuv=>:aud,
        :ug=>:ugx,
        :uga=>:ugx,
        :ua=>:uah,
        :ukr=>:uah,
        :ae=>:aed,
        :are=>:aed,
        :gb=>:gbp,
        :gbr=>:gbp,
        :us=>:usd,
        :usa=>:usd,
        :uy=>:uyu,
        :ury=>:uyu,
        :uz=>:uzs,
        :uzb=>:uzs,
        :vu=>:vuv,
        :vut=>:vuv,
        :ve=>:vef,
        :ven=>:vef,
        :vn=>:vnd,
        :vnm=>:vnd,
        :wf=>:xpf,
        :wlf=>:xpf,
        :eh=>:mad,
        :esh=>:mad,
        :ye=>:yer,
        :yem=>:yer,
        :zm=>:zmk,
        :zmb=>:zmk,
        :zw=>:usd,
        :zwe=>:usd
      })
    end
  end
  describe "self.currencies" do
    it "should be an array of currency symbols" do
      expect(subject.currencies).to eq(%W(nio lak sar nok usd rub xcd omr amd cdf kpw cny kes khr pln mvr gtq clp inr bzd myr hkd cop dkk sek byr lyd ron dzd bif ars gip uyi bob ssp ngn pgk std xof aed ern mwk cup usn gmd cve tzs cou btn zwl ugx syp mad mnt lsl xaf shp htg rsd mga top mzn lvl fkp uss bwp hnl eur egp chf ils pyg lbp ang kzt gyd wst npr kmf thb irr srd jpy brl uyu mop bmd szl etb jod idr mdl xpf mro yer bam awg nzd pen aoa kyd sll try vef isk gnf bsd djf huf ltl mxn scr sgd lkr tjs tnd dop fjd gel sdg vuv bbd lrd krw mmk mur php zar kgs gbp bgn iqd tmt uah vnd zmk bov hrk ttd bhd clf rwf mkd aud crc pkr twd uzs czk azn bdt nad afn mxv cuc pab qar sos chw cad jmd bnd all svc sbd ghs kwd).sort.map(&:to_sym))
    end
  end
  describe "self.defines?" do
    context "with a defined currency" do
      it "should return true" do
        subject.currencies.each do |curr|
          expect(subject).to be_defines(curr)
        end
      end
    end
    context "with a defined country" do
      it "should return true" do
        subject.country_map.each do |country, currency|
          expect(subject).to be_defines(country)
        end
      end
    end
    context "with an undefined currency" do
      it "should return false" do
        expect(subject).not_to be_defines(:xxx)
      end
    end
  end
  describe "self.assert_currency" do
    context "with a currency" do
      it "should return the currency itself" do
        expect(subject.assert_currency!(:eur)).to eq(:eur)
      end
    end
    context "with a country" do
      it "should return the matching currency for the country" do
        expect(subject.assert_currency!(:de)).to eq(:eur)
      end
    end
    context "with a non-currency" do
      it "should raise an error" do
        expect { subject.assert_currency!(:xxx) }.to raise_error(Exchange::NoCurrencyError, "xxx is not a currency nor a country code matchable to a currency")
      end
    end
  end
  describe "self.instantiate" do
    context "given a float or an integer" do
      context "with bigger precision than the definition" do
        it "should instantiate a big decimal with the given precision" do
          expect(BigDecimal).to receive(:new).with('23.2345', 6).and_return('INSTANCE')
          expect(subject.instantiate(23.2345, :tnd)).to eq('INSTANCE')
          expect(BigDecimal).to receive(:new).with('22223.2323444', 12).and_return('INSTANCE')
          expect(subject.instantiate(22223.2323444, :sar)).to eq('INSTANCE')
          expect(BigDecimal).to receive(:new).with('23.23', 4).and_return('INSTANCE')
          expect(subject.instantiate(23.23, :clp)).to eq('INSTANCE')
        end
      end
      context "with smaller precision than the definition" do
        it "should instantiate a big decimal with the defined precision" do
          expect(BigDecimal).to receive(:new).with('23382343.1',11).and_return('INSTANCE')
          expect(subject.instantiate(23382343.1, :tnd)).to eq('INSTANCE')
          expect(BigDecimal).to receive(:new).with('23',4).and_return('INSTANCE')
          expect(subject.instantiate(23, :sar)).to eq('INSTANCE')
          expect(BigDecimal).to receive(:new).with('23.2',5).and_return('INSTANCE')
          expect(subject.instantiate(23.2, :omr)).to eq('INSTANCE')
        end
      end
    end
    context "given a float with scientific notation" do
      context "with bigger precision than the definition" do
        it "should instantiate a big decimal with the given precision" do
          expect(BigDecimal).to receive(:new).with("6.0e-05",6).and_return('INSTANCE')
          expect(subject.instantiate(6.0e-05, :tnd)).to eq('INSTANCE')
          expect(BigDecimal).to receive(:new).with("600000.0",8).and_return('INSTANCE')
          expect(subject.instantiate(6.0e05, :sar)).to eq('INSTANCE')
          expect(BigDecimal).to receive(:new).with("1.456e-08",12).and_return('INSTANCE')
          expect(subject.instantiate(1.456e-08, :omr)).to eq('INSTANCE')
          expect(BigDecimal).to receive(:new).with("145600000.0",12).and_return('INSTANCE')
          expect(subject.instantiate(1.456e08, :omr)).to eq('INSTANCE')
        end
      end
      context "with smaller precision than the definition" do
        it "should instantiate a big decimal with the defined precision" do
          expect(BigDecimal).to receive(:new).with("0.6",4).and_return('INSTANCE')
          expect(subject.instantiate(6.0e-01, :tnd)).to eq('INSTANCE')
          expect(BigDecimal).to receive(:new).with("60.0",4).and_return('INSTANCE')
          expect(subject.instantiate(6.0e01, :sar)).to eq('INSTANCE')
          expect(BigDecimal).to receive(:new).with("0.14",4).and_return('INSTANCE')
          expect(subject.instantiate(1.4e-01, :omr)).to eq('INSTANCE')
          expect(BigDecimal).to receive(:new).with("14.56",5).and_return('INSTANCE')
          expect(subject.instantiate(1.456e01, :omr)).to eq('INSTANCE')
        end
      end
    end
    context "given a big decimal" do
      let!(:bigdecimal) { BigDecimal.new("23.23") }
      it "should instantiate a big decimal according to the iso standards" do
        expect(BigDecimal).to receive(:new).never
        expect(subject.instantiate(bigdecimal, :tnd)).to eq(bigdecimal)
      end
    end
  end
  describe "self.round" do
    it "should round a currency according to ISO 4217 Definitions" do
      expect(subject.round(BigDecimal.new("23.232524"), :tnd)).to eq(BigDecimal.new("23.233"))
      expect(subject.round(BigDecimal.new("23.232524"), :sar)).to eq(BigDecimal.new("23.23"))
      expect(subject.round(BigDecimal.new("23.232524"), :clp)).to eq(BigDecimal.new("23"))
    end
    it "should round psychologically if asked" do
      expect(subject.round(BigDecimal.new("23.232524"), :tnd, nil, {:psych => true})).to eq(BigDecimal.new("22.999"))
      expect(subject.round(BigDecimal.new("23.232524"), :sar, nil, {:psych => true})).to eq(BigDecimal.new("22.99"))
      expect(subject.round(BigDecimal.new("23.232524"), :clp, nil, {:psych => true})).to eq(BigDecimal.new("19"))
    end
  end
  describe "self.ceil" do
    it "should ceil a currency according to ISO 4217 Definitions" do
      expect(subject.ceil(BigDecimal.new("23.232524"), :tnd)).to eq(BigDecimal.new("23.233"))
      expect(subject.ceil(BigDecimal.new("23.232524"), :sar)).to eq(BigDecimal.new("23.24"))
      expect(subject.ceil(BigDecimal.new("23.232524"), :clp)).to eq(BigDecimal.new("24"))
    end
    it "should ceil psychologically if asked" do
      expect(subject.ceil(BigDecimal.new("23.232524"), :tnd, nil, {:psych => true})).to eq(BigDecimal.new("23.999"))
      expect(subject.ceil(BigDecimal.new("23.232524"), :sar, nil, {:psych => true})).to eq(BigDecimal.new("23.99"))
      expect(subject.ceil(BigDecimal.new("23.232524"), :clp, nil, {:psych => true})).to eq(BigDecimal.new("29"))
    end
  end
  describe "self.floor" do
    it "should floor a currency according to ISO 4217 Definitions" do
      expect(subject.floor(BigDecimal.new("23.232524"), :tnd)).to eq(BigDecimal.new("23.232"))
      expect(subject.floor(BigDecimal.new("23.232524"), :sar)).to eq(BigDecimal.new("23.23"))
      expect(subject.floor(BigDecimal.new("23.232524"), :clp)).to eq(BigDecimal.new("23"))
    end
    it "should floor psychologically if asked" do
      expect(subject.floor(BigDecimal.new("23.232524"), :tnd, nil, {:psych => true})).to eq(BigDecimal.new("22.999"))
      expect(subject.floor(BigDecimal.new("23.232524"), :sar, nil, {:psych => true})).to eq(BigDecimal.new("22.99"))
      expect(subject.floor(BigDecimal.new("23.232524"), :clp, nil, {:psych => true})).to eq(BigDecimal.new("19"))
    end
  end
  describe "self.symbol" do
    context "with a symbol present" do
      it "should return the symbol" do
        expect(subject.symbol(:usd)).to eq('$')
        expect(subject.symbol(:gbp)).to eq('£')
        expect(subject.symbol(:eur)).to eq('€')
      end
    end
    context "with no symbol present" do
      it "should return nil" do
        expect(subject.symbol(:chf)).to be_nil
        expect(subject.symbol(:etb)).to be_nil
        expect(subject.symbol(:tnd)).to be_nil
      end
    end
  end
  describe "self.stringify" do
    it "should stringify a currency according to ISO 4217 Definitions" do
      expect(subject.stringify(BigDecimal.new("23234234.232524"), :tnd)).to eq("TND 23234234.233")
      expect(subject.stringify(BigDecimal.new("23234234.232524"), :sar)).to eq("SAR 23,234,234.23")
      expect(subject.stringify(BigDecimal.new("2323434223.232524"), :clp)).to eq("CLP 2.323.434.223")
      expect(subject.stringify(BigDecimal.new("232344.2"), :tnd)).to eq("TND 232344.200")
      expect(subject.stringify(BigDecimal.new("233432434.4"), :sar)).to eq("SAR 233,432,434.40")
      expect(subject.stringify(BigDecimal.new("23234234.0"), :clp)).to eq("CLP 23.234.234")
    end
    context "amount only" do
      it "should not render the currency" do
        expect(subject.stringify(BigDecimal.new("23.232524"), :tnd, :format => :amount)).to eq("23.233")
        expect(subject.stringify(BigDecimal.new("223423432343.232524"), :chf, :format => :amount)).to eq("223'423'432'343.23")
        expect(subject.stringify(BigDecimal.new("23.232524"), :clp, :format => :amount)).to eq("23")
        expect(subject.stringify(BigDecimal.new("23.2"), :tnd, :format => :amount)).to eq("23.200")
        expect(subject.stringify(BigDecimal.new("25645645663.4"), :sar, :format => :amount)).to eq("25,645,645,663.40")
        expect(subject.stringify(BigDecimal.new("23.0"), :clp, :format => :amount)).to eq("23")
      end
    end
    context "plain amount" do
      it "should not render the currency or separators" do
        expect(subject.stringify(BigDecimal.new("23.232524"), :tnd, :format => :plain)).to eq("23.233")
        expect(subject.stringify(BigDecimal.new("223423432343.232524"), :chf, :format => :plain)).to eq("223423432343.23")
        expect(subject.stringify(BigDecimal.new("23.232524"), :clp, :format => :plain)).to eq("23")
        expect(subject.stringify(BigDecimal.new("23.2"), :tnd, :format => :plain)).to eq("23.200")
        expect(subject.stringify(BigDecimal.new("25645645663.4"), :sar, :format => :plain)).to eq("25645645663.40")
        expect(subject.stringify(BigDecimal.new("23.0"), :clp, :format => :plain)).to eq("23")
      end
    end
    context "symbol" do
      context "with a symbol present" do
        it "should render a symbol for the currency" do
          expect(subject.stringify(BigDecimal.new("23.232524"), :usd, :format => :symbol)).to eq("$23.23")
          expect(subject.stringify(BigDecimal.new("23.232524"), :irr, :format => :symbol)).to eq("﷼23.23")
          expect(subject.stringify(BigDecimal.new("345543453453.232524"), :gbp, :format => :symbol)).to eq("£345,543,453,453.23")
          expect(subject.stringify(BigDecimal.new("23.232524"), :eur, :format => :symbol)).to eq("€23.23")
        end
      end
      context "without a symbol present" do
        it "should render the currency abbreviation" do
          expect(subject.stringify(BigDecimal.new("32741393.232524"), :chf, :format => :symbol)).to eq("CHF 32'741'393.23")
          expect(subject.stringify(BigDecimal.new("23.232524"), :etb, :format => :symbol)).to eq("ETB 23.23")
        end
      end
    end
  end
end
