require 'spec_helper'

describe "Exchange::ISO4217" do
  let(:subject) { Exchange::ISO4217 }
  describe "self.definitions" do
    it "should be a hash of exactly the ISO standard definitions loaded from the yaml file" do
      subject.definitions.should === { 
                                       :nio => { :minor_unit => 2, :currency => "Cordoba Oro" }, 
                                       :lak => { :minor_unit => 2, :currency => "Kip" }, 
                                       :sar => { :format => "#,###.##", :minor_unit => 2, :currency => "Saudi Riyal" }, 
                                       :nok => { :format => "#.###,##", :minor_unit => 2, :currency => "Norwegian Krone" }, 
                                       :usd => { :format=>"#,###.##", :minor_unit => 2, :currency => "US Dollar" }, 
                                       :rub => { :format=>"#.###,##", :minor_unit => 2, :currency => "Russian Ruble" }, 
                                       :xcd => { :format=>"#,###.##", :minor_unit => 2, :currency => "East Caribbean Dollar" }, 
                                       :omr => { :format=>"#,###.###", :minor_unit => 3, :currency => "Rial Omani" }, 
                                       :amd => { :format=>"#,###.##", :minor_unit => 2, :currency => "Armenian Dram" }, 
                                       :cdf => { :minor_unit => 2, :currency => "Congolese Franc" }, 
                                       :kpw => { :minor_unit => 2, :currency => "North Korean Won" }, 
                                       :cny => { :format=>"#,###.##", :minor_unit => 2, :currency => "Yuan Renminbi" }, 
                                       :kes => { :format=>"#,###.##", :minor_unit => 2, :currency => "Kenyan Shilling" }, 
                                       :khr => { :minor_unit => 2, :currency => "Riel" }, 
                                       :pln => { :format=>"# ###,##", :minor_unit => 2, :currency => "Zloty" }, 
                                       :mvr => { :minor_unit => 2, :currency => "Rufiyaa" }, 
                                       :gtq => { :format=>"#,###.##", :minor_unit => 2, :currency => "Quetzal" }, 
                                       :clp => { :format=>"#.###", :minor_unit => 0, :currency => "Chilean Peso" }, 
                                       :inr => { :format=>"#,##,###.##", :minor_unit => 2, :currency => "Indian Rupee" }, 
                                       :bzd => { :format=>"#,###.##", :minor_unit => 2, :currency => "Belize Dollar" }, 
                                       :myr => { :format=>"#,###.##", :minor_unit => 2, :currency => "Malaysian Ringgit" }, 
                                       :hkd => { :format=>"#,###.##", :minor_unit => 2, :currency => "Hong Kong Dollar" }, 
                                       :cop => { :format=>"#.###,##", :minor_unit => 2, :currency => "Colombian Peso" }, 
                                       :dkk => { :format=>"#.###,##", :minor_unit => 2, :currency => "Danish Krone" }, 
                                       :sek => { :format=>"#.###,##", :minor_unit => 2, :currency => "Swedish Krona" }, 
                                       :byr => { :minor_unit => 0, :currency => "Belarussian Ruble" }, 
                                       :lyd => { :minor_unit => 3, :currency => "Libyan Dinar" }, 
                                       :ron => { :format=>"#.###,##", :minor_unit => 2, :currency => "New Romanian Leu" }, 
                                       :dzd => { :minor_unit => 2, :currency => "Algerian Dinar" }, 
                                       :bif => { :minor_unit => 0, :currency => "Burundi Franc" }, 
                                       :ars => { :format=>"#.###,##", :minor_unit => 2, :currency => "Argentine Peso" }, 
                                       :gip => { :format=>"#,###.##", :minor_unit => 2, :currency => "Gibraltar Pound" }, 
                                       :uyi => { :minor_unit => 0, :currency => "Uruguay Peso en Unidades Indexadas (URUIURUI)" }, 
                                       :bob => { :format=>"#,###.##", :minor_unit => 2, :currency => "Boliviano" }, 
                                       :ssp => { :minor_unit => 2, :currency => "South Sudanese Pound" }, 
                                       :ngn => { :minor_unit => 2, :currency => "Naira" }, 
                                       :pgk => { :minor_unit => 2, :currency => "Kina" }, 
                                       :std => { :minor_unit => 2, :currency => "Dobra" }, 
                                       :xof => { :minor_unit => 0, :currency => "CFA Franc BCEAO" }, 
                                       :aed => { :format=>"#,###.##", :minor_unit => 2, :currency => "UAE Dirham" }, 
                                       :ern => { :minor_unit => 2, :currency => "Nakfa" }, 
                                       :mwk => { :minor_unit => 2, :currency => "Kwacha" }, 
                                       :cup => { :format=>"#,###.##", :minor_unit => 2, :currency => "Cuban Peso" }, 
                                       :usn => { :minor_unit => 2, :currency => "US Dollar (Next day)" }, 
                                       :gmd => { :minor_unit => 2, :currency => "Dalasi" }, 
                                       :cve => { :minor_unit => 2, :currency => "Cape Verde Escudo" }, 
                                       :tzs => { :format=>"#,###.##", :minor_unit => 2, :currency => "Tanzanian Shilling" }, 
                                       :cou => { :minor_unit => 2, :currency => "Unidad de Valor Real" }, 
                                       :btn => { :minor_unit => 2, :currency => "Ngultrum" }, 
                                       :zwl => { :minor_unit => 2, :currency => "Zimbabwe Dollar" }, 
                                       :ugx => { :minor_unit => 2, :currency => "Uganda Shilling" }, 
                                       :syp => { :minor_unit => 2, :currency => "Syrian Pound" }, 
                                       :mad => { :minor_unit => 2, :currency => "Moroccan Dirham" }, 
                                       :mnt => { :minor_unit => 2, :currency => "Tugrik" }, 
                                       :lsl => { :minor_unit => 2, :currency => "Loti" }, 
                                       :xaf => { :minor_unit => 0, :currency => "CFA Franc BEAC" }, 
                                       :shp => { :minor_unit => 2, :currency => "Saint Helena Pound" }, 
                                       :htg => { :minor_unit => 2, :currency => "Gourde" }, 
                                       :rsd => { :minor_unit => 2, :currency => "Serbian Dinar" }, 
                                       :mga => { :minor_unit => 2, :currency => "Malagasy Ariary" }, 
                                       :top => { :format=>"#,###.##", :minor_unit => 2, :currency => "Pa\xE2\x80\x99anga" }, 
                                       :mzn => { :minor_unit => 2, :currency => "Mozambique Metical" }, 
                                       :lvl => { :format=>"#,###.##", :minor_unit => 2, :currency => "Latvian Lats" }, 
                                       :fkp => { :minor_unit => 2, :currency => "Falkland Islands Pound" }, 
                                       :uss => { :minor_unit => 2, :currency => "US Dollar (Same day)" }, 
                                       :bwp => { :format=>"#,###.##", :minor_unit => 2, :currency => "Pula" }, 
                                       :hnl => { :format=>"#,###.##", :minor_unit => 2, :currency => "Lempira" }, 
                                       :che => { :minor_unit => 2, :currency => "WIR Euro" }, 
                                       :eur => { :format=>"#,###.##", :minor_unit => 2, :currency => "Euro" }, 
                                       :egp => { :format=>"#,###.##", :minor_unit => 2, :currency => "Egyptian Pound" }, 
                                       :chf => { :format=>"#'###.##", :minor_unit => 2, :currency => "Swiss Franc" }, 
                                       :ils => { :format=>"#,###.##", :minor_unit => 2, :currency => "New Israeli Sheqel" }, 
                                       :pyg => { :minor_unit => 0, :currency => "Guarani" }, 
                                       :lbp => { :format=>"# ###", :minor_unit => 2, :currency => "Lebanese Pound" }, 
                                       :ang => { :format=>"#.###,##", :minor_unit => 2, :currency => "Netherlands Antillean Guilder" }, 
                                       :kzt => { :minor_unit => 2, :currency => "Tenge" }, 
                                       :gyd => { :minor_unit => 2, :currency => "Guyana Dollar" }, 
                                       :wst => { :minor_unit => 2, :currency => "Tala" }, 
                                       :npr => { :format=>"#,###.##", :minor_unit => 2, :currency => "Nepalese Rupee" }, 
                                       :kmf => { :minor_unit => 0, :currency => "Comoro Franc" }, 
                                       :thb => { :format=>"#,###.##", :minor_unit => 2, :currency => "Baht" }, 
                                       :irr => { :format=>"#,###.##", :minor_unit => 2, :currency => "Iranian Rial" }, 
                                       :srd => { :minor_unit => 2, :currency => "Surinam Dollar" }, 
                                       :jpy => { :format=>"#,###", :minor_unit => 0, :currency => "Yen" }, 
                                       :brl => { :format=>"#.###,##", :minor_unit => 2, :currency => "Brazilian Real" }, 
                                       :uyu => { :format=>"#.###,##", :minor_unit => 2, :currency => "Peso Uruguayo" }, 
                                       :mop => { :minor_unit => 2, :currency => "Pataca" }, 
                                       :bmd => { :format=>"#,###.##", :minor_unit => 2, :currency => "Bermudian Dollar" }, 
                                       :szl => { :format=>"#, ###.##", :minor_unit => 2, :currency => "Lilangeni" }, 
                                       :etb => { :minor_unit => 2, :currency => "Ethiopian Birr" }, 
                                       :jod => { :format=>"#,###.###", :minor_unit => 3, :currency => "Jordanian Dinar" }, 
                                       :idr => { :format=>"#.###,##", :minor_unit => 2, :currency => "Rupiah" }, 
                                       :mdl => { :minor_unit => 2, :currency => "Moldovan Leu" }, 
                                       :xpf => { :minor_unit => 0, :currency => "CFP Franc" }, 
                                       :mro => { :minor_unit => 2, :currency => "Ouguiya" }, 
                                       :yer => { :minor_unit => 2, :currency => "Yemeni Rial" }, 
                                       :bam => { :format=>"#,###.##", :minor_unit => 2, :currency => "Convertible Mark" }, 
                                       :awg => { :format=>"#,###.##", :minor_unit => 2, :currency => "Aruban Florin" }, 
                                       :nzd => { :format=>"#,###.##", :minor_unit => 2, :currency => "New Zealand Dollar" }, 
                                       :pen => { :format=>"#,###.##", :minor_unit => 2, :currency => "Nuevo Sol" }, 
                                       :aoa => { :minor_unit => 2, :currency => "Kwanza" }, 
                                       :kyd => { :format=>"#,###.##", :minor_unit => 2, :currency => "Cayman Islands Dollar" }, 
                                       :sll => { :minor_unit => 2, :currency => "Leone" }, 
                                       :try => { :format=>"#,###.##", :minor_unit => 2, :currency => "Turkish Lira" }, 
                                       :vef => { :format=>"#.###,##", :minor_unit => 2, :currency => "Bolivar Fuerte" }, 
                                       :isk => { :format=>"#.###", :minor_unit => 0, :currency => "Iceland Krona" }, 
                                       :gnf => { :minor_unit => 0, :currency => "Guinea Franc" }, 
                                       :bsd => { :format=>"#,###.##", :minor_unit => 2, :currency => "Bahamian Dollar" }, 
                                       :djf => { :minor_unit => 0, :currency => "Djibouti Franc" }, 
                                       :huf => { :format=>"#.###", :minor_unit => 2, :currency => "Forint" }, 
                                       :ltl => { :format=>"# ###,##", :minor_unit => 2, :currency => "Lithuanian Litas" }, 
                                       :mxn => { :format=>"#,###.##", :minor_unit => 2, :currency => "Mexican Peso" }, 
                                       :scr => { :minor_unit => 2, :currency => "Seychelles Rupee" }, 
                                       :sgd => { :format=>"#,###.##", :minor_unit => 2, :currency => "Singapore Dollar" }, 
                                       :lkr => { :minor_unit => 2, :currency => "Sri Lanka Rupee" }, 
                                       :tjs => { :minor_unit => 2, :currency => "Somoni" }, 
                                       :tnd => { :minor_unit => 3, :currency => "Tunisian Dinar" }, 
                                       :dop => { :format=>"#,###.##", :minor_unit => 2, :currency => "Dominican Peso" }, 
                                       :fjd => { :minor_unit => 2, :currency => "Fiji Dollar" }, 
                                       :gel => { :minor_unit => 2, :currency => "Lari" }, 
                                       :sdg => { :minor_unit => 2, :currency => "Sudanese Pound" }, 
                                       :vuv => { :format=>"#,###", :minor_unit => 0, :currency => "Vatu" }, 
                                       :bbd => { :minor_unit => 2, :currency => "Barbados Dollar" }, 
                                       :lrd => { :minor_unit => 2, :currency => "Liberian Dollar" }, 
                                       :krw => { :format=>"#,###", :minor_unit => 0, :currency => "Won" }, 
                                       :mmk => { :minor_unit => 2, :currency => "Kyat" }, 
                                       :mur => { :format=>"#,###", :minor_unit => 2, :currency => "Mauritius Rupee" }, 
                                       :php => { :format=>"#,###.##", :minor_unit => 2, :currency => "Philippine Peso" }, 
                                       :zar => { :format=>"# ###.##", :minor_unit => 2, :currency => "Rand" }, 
                                       :kgs => { :minor_unit => 2, :currency => "Som" }, 
                                       :gbp => { :format=>"#,###.##", :minor_unit => 2, :currency => "Pound Sterling" }, 
                                       :bgn => { :minor_unit => 2, :currency => "Bulgarian Lev" }, 
                                       :iqd => { :minor_unit => 3, :currency => "Iraqi Dinar" }, 
                                       :tmt => { :minor_unit => 2, :currency => "Turkmenistan New Manat" }, 
                                       :uah => { :format=>"# ###,##", :minor_unit => 2, :currency => "Hryvnia" }, 
                                       :vnd => { :format=>"#.###", :minor_unit => 0, :currency => "Dong" }, 
                                       :zmk => { :minor_unit => 2, :currency => "Zambian Kwacha" }, 
                                       :bov => { :minor_unit => 2, :currency => "Mvdol" }, 
                                       :hrk => { :format=>"#.###,##", :minor_unit => 2, :currency => "Croatian Kuna" }, 
                                       :ttd => { :minor_unit => 2, :currency => "Trinidad and Tobago Dollar" }, 
                                       :bhd => { :format=>"#,###.###", :minor_unit => 3, :currency => "Bahraini Dinar" }, 
                                       :clf => { :minor_unit => 0, :currency => "Unidades de fomento" }, 
                                       :rwf => { :minor_unit => 0, :currency => "Rwanda Franc" }, 
                                       :mkd => { :format=>"#,###.##", :minor_unit => 2, :currency => "Denar" }, 
                                       :aud => { :format=>"# ###.##", :minor_unit => 2, :currency => "Australian Dollar" }, 
                                       :crc => { :format=>"#.###,##", :minor_unit => 2, :currency => "Costa Rican Colon" }, 
                                       :pkr => { :format=>"#,###.##", :minor_unit => 2, :currency => "Pakistan Rupee" }, 
                                       :twd => { :minor_unit => 2, :currency => "New Taiwan Dollar" }, 
                                       :uzs => { :minor_unit => 2, :currency => "Uzbekistan Sum" }, 
                                       :czk => { :format=>"#.###,##", :minor_unit => 2, :currency => "Czech Koruna" }, 
                                       :azn => { :minor_unit => 2, :currency => "Azerbaijanian Manat" }, 
                                       :bdt => { :format=>"#,###.##", :minor_unit => 2, :currency => "Taka" }, 
                                       :nad => { :minor_unit => 2, :currency => "Namibia Dollar" }, 
                                       :afn => { :minor_unit => 2, :currency => "Afghani" }, 
                                       :mxv => { :minor_unit => 2, :currency => "Mexican Unidad de Inversion (UDI)" }, 
                                       :cuc => { :format=>"#,###.##", :minor_unit => 2, :currency => "Peso Convertible" }, 
                                       :pab => { :minor_unit => 2, :currency => "Balboa" }, 
                                       :qar => { :minor_unit => 2, :currency => "Qatari Rial" }, 
                                       :sos => { :minor_unit => 2, :currency => "Somali Shilling" }, 
                                       :chw => { :minor_unit => 2, :currency => "WIR Franc" }, 
                                       :cad => { :format=>"#,###.##", :minor_unit => 2, :currency => "Canadian Dollar" }, 
                                       :jmd => { :format=>"#,###.##", :minor_unit => 2, :currency => "Jamaican Dollar" }, 
                                       :bnd => { :format=>"#,###.##", :minor_unit => 2, :currency => "Brunei Dollar" }, 
                                       :all => { :minor_unit => 2, :currency => "Lek" }, 
                                       :svc => { :format=>"#,###.##", :minor_unit => 2, :currency => "El Salvador Colon" }, 
                                       :sbd => { :minor_unit => 2, :currency => "Solomon Islands Dollar" }, 
                                       :ghs => { :minor_unit => 2, :currency => "Ghana Cedi" }, 
                                       :kwd => { :format=>"#,###.###", :minor_unit => 3, :currency => "Kuwaiti Dinar" }
                                      }
    end
  end
  describe "self.currencies" do
    it "should be an array of currency symbols" do
      subject.currencies.should == [:nio, :lak, :sar, :nok, :usd, :rub, :xcd, :omr, :amd, :cdf, :kpw, :cny, :kes, :khr, :pln, :mvr, :gtq, :clp, :inr, :bzd, :myr, :hkd, :cop, :dkk, :sek, :byr, :lyd, :ron, :dzd, :bif, :ars, :gip, :uyi, :bob, :ssp, :ngn, :pgk, :std, :xof, :aed, :ern, :mwk, :cup, :usn, :gmd, :cve, :tzs, :cou, :btn, :zwl, :ugx, :syp, :mad, :mnt, :lsl, :xaf, :shp, :htg, :rsd, :mga, :top, :mzn, :lvl, :fkp, :uss, :bwp, :hnl, :che, :eur, :egp, :chf, :ils, :pyg, :lbp, :ang, :kzt, :gyd, :wst, :npr, :kmf, :thb, :irr, :srd, :jpy, :brl, :uyu, :mop, :bmd, :szl, :etb, :jod, :idr, :mdl, :xpf, :mro, :yer, :bam, :awg, :nzd, :pen, :aoa, :kyd, :sll, :try, :vef, :isk, :gnf, :bsd, :djf, :huf, :ltl, :mxn, :scr, :sgd, :lkr, :tjs, :tnd, :dop, :fjd, :gel, :sdg, :vuv, :bbd, :lrd, :krw, :mmk, :mur, :php, :zar, :kgs, :gbp, :bgn, :iqd, :tmt, :uah, :vnd, :zmk, :bov, :hrk, :ttd, :bhd, :clf, :rwf, :mkd, :aud, :crc, :pkr, :twd, :uzs, :czk, :azn, :bdt, :nad, :afn, :mxv, :cuc, :pab, :qar, :sos, :chw, :cad, :jmd, :bnd, :all, :svc, :sbd, :ghs, :kwd]
    end
  end
  describe "self.defines?" do
    context "with a defined currency" do
      it "should return true" do
        subject.currencies.each do |curr|
          subject.should be_defines(curr)
        end
      end
    end
    context "with an undefined currency" do
      it "should return false" do
        subject.should_not be_defines(:xxx)
      end
    end
  end
  describe "self.instantiate" do
    it "should instantiate a big decimal according to the iso standards" do
      BigDecimal.should_receive(:new).with('23.23', 3).and_return('INSTANCE')
      subject.instantiate(23.23, :tnd).should == 'INSTANCE'
      BigDecimal.should_receive(:new).with('23.23', 2).and_return('INSTANCE')
      subject.instantiate(23.23, :sar).should == 'INSTANCE'
      BigDecimal.should_receive(:new).with('23.23', 0).and_return('INSTANCE')
      subject.instantiate(23.23, :clp).should == 'INSTANCE'
    end
  end
  describe "self.round" do
    it "should round a currency according to ISO 4217 Definitions" do
      subject.round(BigDecimal.new("23.232524"), :tnd).should == BigDecimal.new("23.233")
      subject.round(BigDecimal.new("23.232524"), :sar).should == BigDecimal.new("23.23")
      subject.round(BigDecimal.new("23.232524"), :clp).should == BigDecimal.new("23")
    end
  end
  describe "self.stringify" do
    it "should stringify a currency according to ISO 4217 Definitions" do
      subject.stringify(BigDecimal.new("23.232524"), :tnd).should == "TND 23.233"
      subject.stringify(BigDecimal.new("23.232524"), :sar).should == "SAR 23.23"
      subject.stringify(BigDecimal.new("23.232524"), :clp).should == "CLP 23"
      subject.stringify(BigDecimal.new("23.2"), :tnd).should == "TND 23.200"
      subject.stringify(BigDecimal.new("23.4"), :sar).should == "SAR 23.40"
      subject.stringify(BigDecimal.new("23.0"), :clp).should == "CLP 23"
    end
    it "should not render the currency if only the amount is wished for" do
      subject.stringify(BigDecimal.new("23.232524"), :tnd, :amount_only => true).should == "23.233"
      subject.stringify(BigDecimal.new("23.232524"), :sar, :amount_only => true).should == "23.23"
      subject.stringify(BigDecimal.new("23.232524"), :clp, :amount_only => true).should == "23"
      subject.stringify(BigDecimal.new("23.2"), :tnd, :amount_only => true).should == "23.200"
      subject.stringify(BigDecimal.new("23.4"), :sar, :amount_only => true).should == "23.40"
      subject.stringify(BigDecimal.new("23.0"), :clp, :amount_only => true).should == "23"
    end
  end
end