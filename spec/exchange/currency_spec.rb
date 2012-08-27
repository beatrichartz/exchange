require 'spec_helper'

describe "Exchange::Currency" do
  subject { Exchange::Currency.new(40, :usd) }
  before(:all) do
    Exchange::Configuration.define do |c|
      c.api = :currency_bot
      c.cache = false
    end
  end
  after(:all) do
    Exchange::Configuration.cache = :memcached
  end
  it "should initialize with a number and a currency" do
    subject.value.should == 40
    subject.currency.should == :usd
  end
  describe "convert_to" do
    it "should be able to convert itself to other currencies" do
      mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 3)
      subject.convert_to(:chf).value.round(2).should == 36.5
      subject.convert_to(:chf).currency.should == :chf
      subject.convert_to(:chf).should be_kind_of Exchange::Currency
    end
  end
  describe "operations" do
    describe "+ other" do
      it "should be able to add an integer" do
        (subject + 40).value.should == 80
      end
      it "should be able to add a float" do
        (subject + 40.5).value.should == 80.5
      end
      it "should be able to add another currency value" do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        (subject + Exchange::Currency.new(30, :chf)).value.round(2).should == 72.87
        (subject + Exchange::Currency.new(30, :sek)).currency.should == :usd
      end
      it "should raise when currencies get mixed and the configuration does not allow it" do
        Exchange::Configuration.allow_mixed_operations = false
        lambda { subject + Exchange::Currency.new(30, :chf) }.should raise_error(Exchange::CurrencyMixError)
        Exchange::Configuration.allow_mixed_operations = true
      end
      it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
        Exchange::Configuration.allow_mixed_operations = false
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        lambda { subject + Exchange::Currency.new(30, :usd) }.should_not raise_error
        Exchange::Configuration.allow_mixed_operations = true
      end
    end
    describe "- other" do
      it "should be able to subtract an integer" do
        (subject + 40).value.should == 80
      end
      it "should be able to subtract a float" do
        (subject + 40.5).value.should == 80.5
      end
      it "should be able to subtract another currency value" do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        (subject + Exchange::Currency.new(10, :chf)).value.round(2).should == 50.96
        (subject + Exchange::Currency.new(23.3, :eur)).currency.should == :usd
      end
      it "should raise when currencies get mixed and the configuration does not allow it" do
        Exchange::Configuration.allow_mixed_operations = false
        lambda { subject - Exchange::Currency.new(30, :chf) }.should raise_error(Exchange::CurrencyMixError)
        Exchange::Configuration.allow_mixed_operations = true
      end
      it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
        Exchange::Configuration.allow_mixed_operations = false
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        lambda { subject - Exchange::Currency.new(30, :usd) }.should_not raise_error
        Exchange::Configuration.allow_mixed_operations = true
      end
    end
    describe "* other" do
      it "should be able to multiply by an integer" do
        (subject * 40).value.should == 1600
      end
      it "should be able to multiply a float" do
        (subject * 40.5).value.should == 1620
      end
      it "should be able to multiply by another currency value" do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        (subject * Exchange::Currency.new(10, :chf)).value.round(1).should == 438.3
        (subject * Exchange::Currency.new(23.3, :eur)).currency.should == :usd
      end
      it "should raise when currencies get mixed and the configuration does not allow it" do
        Exchange::Configuration.allow_mixed_operations = false
        lambda { subject * Exchange::Currency.new(30, :chf) }.should raise_error(Exchange::CurrencyMixError)
        Exchange::Configuration.allow_mixed_operations = true
      end
      it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
        Exchange::Configuration.allow_mixed_operations = false
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        lambda { subject * Exchange::Currency.new(30, :usd) }.should_not raise_error
        Exchange::Configuration.allow_mixed_operations = true
      end
    end
    describe "/ other" do
      it "should be able to multiply by an integer" do
        (subject / 40).value.should == 1
      end
      it "should be able to multiply a float" do
        BigDecimal.new((subject / 40.5).value.to_s).round(4).should == 0.9877
      end
      it "should be able to multiply by another currency value" do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        (subject / Exchange::Currency.new(10, :chf)).value.round(2).should == BigDecimal.new("3.65")
        (subject / Exchange::Currency.new(23.3, :eur)).currency.should == :usd
      end
      it "should raise when currencies get mixed and the configuration does not allow it" do
        Exchange::Configuration.allow_mixed_operations = false
        lambda { subject / Exchange::Currency.new(30, :chf) }.should raise_error(Exchange::CurrencyMixError)
        Exchange::Configuration.allow_mixed_operations = true
      end
      it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
        Exchange::Configuration.allow_mixed_operations = false
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        lambda { subject / Exchange::Currency.new(30, :usd) }.should_not raise_error
        Exchange::Configuration.allow_mixed_operations = true
      end
    end
    describe "comparison" do
      subject { Exchange::Currency.new(40.123, :usd) }
      let(:comp1) { Exchange::Currency.new(40.123, :usd) }
      let(:comp2) { Exchange::Currency.new(40, :usd) }
      let(:comp3) { Exchange::Currency.new(50, :eur) }
      let(:comp4) { Exchange::Currency.new(45, :eur) }
      let(:comp5) { Exchange::Currency.new(50, :eur).to_usd }
      let(:comp6) { Exchange::Currency.new(66.1, :usd, :at => Time.gm(2011,1,1)) }
      before(:each) do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
      end
      context "with identical currencies" do
        it "should be true if the currency and the value is the same" do
          (subject == comp1).should be_true
        end
        it "should be false if the value is different" do
          (subject == comp2).should be_false
        end
      end
      context "with different currencies" do
        it "should be true if the converted value is the same" do
          (comp3 == comp5).should be_true
        end
        it "should be false if the converted value is different" do
          (subject == comp4).should be_false
        end
        it "should be false if the currency is defined historic and the converted value is different" do
          mock_api("http://openexchangerates.org/api/historical/2011-01-01.json?app_id=", fixture('api_responses/example_historic_json.json'), 2)
          (comp3 == comp6).should be_false
        end
      end
    end
    describe "sorting" do
      subject { Exchange::Currency.new(40.123, :usd) }
      let(:comp1) { Exchange::Currency.new(40.123, :usd) }
      let(:comp2) { Exchange::Currency.new(40, :usd) }
      let(:comp3) { Exchange::Currency.new(50, :eur) }
      let(:comp4) { Exchange::Currency.new(45, :eur) }
      before(:each) do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 6)
      end
      it "should sort and by doing conversions" do
        [subject, comp1, comp2, comp3, comp4].sort.should == [comp2, subject, comp1, comp4, comp3]
      end
    end
    describe "round" do
      subject { Exchange::Currency.new(40.123, :usd) }
      context "without arguments" do
        it "should apply it to its number in the iso certified format" do
          subject.round.value.should == 40.12
          subject.round.currency.should == :usd
          subject.round.should be_kind_of Exchange::Currency
        end
      end
      context "with arguments" do
        it "should apply it to its number" do
          subject.round(0).value.should == 40
          subject.round(0).currency.should == :usd
          subject.round(0).should be_kind_of Exchange::Currency
        end
        it "should allow to round to whatever number of decimals" do
          subject.round(2).value.should == 40.12
          subject.round(2).currency.should == :usd
          subject.round(2).should be_kind_of Exchange::Currency
        end
      end
    end
    describe "ceil" do
      subject { Exchange::Currency.new(40.1236, :omr) }
      context "without arguments" do
        it "should apply it to its number in the iso certified format" do
          subject.ceil.value.should == 40.124
          subject.ceil.currency.should == :omr
          subject.ceil.should be_kind_of Exchange::Currency
        end
      end
      context "with arguments" do
        it "should apply it to its number" do
          subject.ceil(0).value.should == 41
          subject.ceil(0).currency.should == :omr
          subject.ceil(0).should be_kind_of Exchange::Currency
        end
        it "should allow to round to whatever number of decimals" do
          subject.ceil(2).value.should == 40.13
          subject.ceil(2).currency.should == :omr
          subject.ceil(2).should be_kind_of Exchange::Currency
        end
      end
    end
    describe "floor" do
      subject { Exchange::Currency.new(40.723, :jpy) }
      context "without arguments" do
        it "should apply it to its number in the iso certified format" do
          subject.floor.value.should == 40
          subject.floor.currency.should == :jpy
          subject.floor.should be_kind_of Exchange::Currency
        end
      end
      context "with arguments" do
        it "should apply it to its number" do
          subject.floor(1).value.should == 40.7
          subject.floor(1).currency.should == :jpy
          subject.floor(1).should be_kind_of Exchange::Currency
        end
        it "should allow to round to whatever number of decimals" do
          subject.floor(2).value.should == 40.72
          subject.floor(2).currency.should == :jpy
          subject.floor(2).should be_kind_of Exchange::Currency
        end
      end
    end
  end
  describe "to_s" do
    it "should render the currency according to ISO 4217 Definitions" do
      Exchange::Currency.new(23.232524, 'TND').to_s.should == "TND 23.233"
      Exchange::Currency.new(23.23252423, 'SAR').to_s.should == "SAR 23.23"
      Exchange::Currency.new(23.23252423, 'CLP').to_s.should == "CLP 23"
      Exchange::Currency.new(23.2, 'TND').to_s.should == "TND 23.200"
      Exchange::Currency.new(23.4, 'SAR').to_s.should == "SAR 23.40"
      Exchange::Currency.new(23.0, 'CLP').to_s.should == "CLP 23"
    end
    it "should render only the currency amount if the argument amount is passed" do
      Exchange::Currency.new(23.232524, 'TND').to_s(:amount).should == "23.233"
      Exchange::Currency.new(23.23252423, 'SAR').to_s(:amount).should == "23.23"
      Exchange::Currency.new(23.23252423, 'CLP').to_s(:amount).should == "23"
      Exchange::Currency.new(23.2, 'TND').to_s(:amount).should == "23.200"
      Exchange::Currency.new(23.4, 'SAR').to_s(:amount).should == "23.40"
      Exchange::Currency.new(23.0, 'CLP').to_s(:amount).should == "23"
    end
  end
  describe "methods via method missing" do
    it "should be able to convert via to_currency to other currencies" do
      mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 6)
      {'chf' => 36.5, 'usd' => 40.0, 'dkk' => 225.12, 'sek' => 269.85, 'nok' => 232.06, 'rub' => 1205.24}.each do |currency, value|
        c = subject.send(:"to_#{currency}")
        c.value.round(2).should == value
        c.currency.should == currency
      end
    end
    it "should be able to convert via to_currency to other currencies and use historic data" do
      mock_api("http://openexchangerates.org/api/historical/2011-10-09.json?app_id=", fixture('api_responses/example_json_api.json'), 6)
      {'chf' => 36.5, 'usd' => 40.0, 'dkk' => 225.12, 'sek' => 269.85, 'nok' => 232.06, 'rub' => 1205.24}.each do |currency, value|
        c = subject.send(:"to_#{currency}", :at => Time.gm(2011,10,9))
        c.value.round(2).should == value
        c.currency.should == currency
      end
    end
    it "should use the own time if defined as historic to convert" do
      mock_api("http://openexchangerates.org/api/historical/2011-01-01.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
      5.eur(:at => Time.gm(2011,1,1)).to_usd.value.should == 5.eur.to_usd(:at => Time.gm(2011,1,1)).value
    end
    it "should raise errors for currency conversions it does not have rates for" do
      lambda { subject.to_ssp }.should raise_error(NoRateError)
    end
    it "should pass on methods it does not understand to its number" do
      subject.to_f.should == 40
      lambda { subject.to_hell }.should raise_error(NoMethodError)
    end
  end
end