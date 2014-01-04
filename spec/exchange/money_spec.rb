# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::Money" do
  subject { Exchange::Money.new(40, :usd) }
  before(:all) do
    Exchange.configuration = Exchange::Configuration.new do |c|
      c.api = {
        :subclass => :open_exchange_rates,
        :fallback => [:xavier_media, :ecb]
      }
      c.cache = {
        :subclass => :no_cache
      }
      c.implicit_conversions = true
    end
  end
  after(:all) do
    Exchange.configuration.reset
  end
  it "should initialize with a number and a currency" do
    subject.value.should == 40
    subject.currency.should == :usd
  end
  it "should initialize with a number and a country code" do
    from_country_code = Exchange::Money.new(50, :de)
    from_country_code.value.should == 50
    from_country_code.currency.should == :eur
  end
  describe "initializing with a block" do
    it "should be possible" do
      currency = Exchange::Money.new(40) do |c|
        c.currency = :usd
        c.time     = Time.gm(2012,9,9)
      end
      
      currency.value.should == 40
      currency.currency.should == :usd
      currency.time.should == Time.gm(2012,9,9)
    end
  end
  describe "to" do
    context "with a currency" do
      it "should be able to convert itself to other currencies" do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 3)
        subject.to(:chf).value.round(2).should == 36.5
        subject.to(:chf).currency.should == :chf
        subject.to(:chf).should be_kind_of Exchange::Money
      end
    end
    context "with a country argument" do
      it "should be able to convert itself to the currency of the country" do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 3)
        subject.to(:ch).value.round(2).should == 36.5
        subject.to(:ch).currency.should == :chf
        subject.to(:ch).should be_kind_of Exchange::Money
      end
    end
    context "when an api is not reachable" do
      context "and a fallback api is" do
        it "should use the fallback " do
          URI.should_receive(:parse).with("http://openexchangerates.org/api/latest.json?app_id=").once.and_raise Exchange::ExternalAPI::APIError
          mock_api("http://api.finance.xaviermedia.com/api/#{Time.now.strftime("%Y/%m/%d")}.xml", fixture('api_responses/example_xml_api.xml'), 3)
          subject.to(:ch).value.round(2).should == 36.36
          subject.to(:ch).currency.should == :chf
          subject.to(:ch).should be_kind_of Exchange::Money
        end
      end
      context "and no fallback api is" do
        it "should raise the api error" do
          URI.should_receive(:parse).with("http://openexchangerates.org/api/latest.json?app_id=").once.and_raise Exchange::ExternalAPI::APIError
          URI.should_receive(:parse).with("http://api.finance.xaviermedia.com/api/#{Time.now.strftime("%Y/%m/%d")}.xml").once.and_raise Exchange::ExternalAPI::APIError
          URI.should_receive(:parse).with("http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml").once.and_raise Exchange::ExternalAPI::APIError
          lambda { subject.to(:ch) }.should raise_error Exchange::ExternalAPI::APIError
        end
      end
    end
    context "with a 'from' currency not provided by the given api" do
      subject { Exchange::Money.new(36.36, :chf) }
      context "but provided by a fallback api" do
        it "should use the fallback" do
          subject.api::CURRENCIES.should_receive(:include?).with(:usd).and_return true
          subject.api::CURRENCIES.should_receive(:include?).with(:chf).and_return true
          URI.should_receive(:parse).with("http://openexchangerates.org/api/latest.json?app_id=").once.and_raise Exchange::ExternalAPI::APIError
          mock_api("http://api.finance.xaviermedia.com/api/#{Time.now.strftime("%Y/%m/%d")}.xml", fixture('api_responses/example_xml_api.xml'), 3)
          subject.to(:usd).value.round(2).should == 40.00
          subject.to(:usd).currency.should == :usd
          subject.to(:usd).should be_kind_of Exchange::Money
        end
      end
    end
    context "with a 'to' currency not provided by the given api" do
      context "but provided by a fallback api" do
        it "should use the fallback" do
          subject.api::CURRENCIES.stub :include? => false
          mock_api("http://api.finance.xaviermedia.com/api/#{Time.now.strftime("%Y/%m/%d")}.xml", fixture('api_responses/example_xml_api.xml'), 3)
          subject.to(:chf).value.round(2).should == 36.36
          subject.to(:chf).currency.should == :chf
          subject.to(:chf).should be_kind_of Exchange::Money
        end
      end
      context "but not provided by any fallback api" do
        it "should raise the no rate error" do
          Exchange::ExternalAPI::OpenExchangeRates::CURRENCIES.stub :include? => false
          Exchange::ExternalAPI::XavierMedia::CURRENCIES.stub :include? => false
          Exchange::ExternalAPI::Ecb::CURRENCIES.stub :include? => false
          lambda { subject.to(:xaf) }.should raise_error Exchange::NoRateError
        end
      end
    end
  end
  describe "revert!" do
    context "with information needed to revert" do
      it "should revert to the old values" do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 3)
        subject.to(:chf).revert!.should == subject
      end
    end
    context "with no information" do
      it "should throw a custom error" do
        lambda { subject.revert! }.should raise_error(Exchange::ImpossibleReversionError, "Can not revert currency to a previous state because information is missing")
      end
    end
  end
  describe "operations" do
    after(:each) do
      Exchange.configuration.implicit_conversions = true
    end
    describe "+ other" do
      it "should be able to add an integer" do
        (subject + 40).value.should == 80
      end
      it "should be able to add a float" do
        (subject + 40.5).value.should == 80.5
      end
      context "with a big decimal" do
        subject { Exchange::Money.new(0.82, :omr) }
        it "should be able to add a big decimal below zero" do
          (subject + BigDecimal.new("0.45454545")).value.round(8).should == BigDecimal.new("0.127454545E1")
        end
        it "should be able to add a big decimal above zero" do
          (subject + BigDecimal.new("12.455")).round(2).value.should == BigDecimal.new("0.1328E2")
        end
      end
      it "should not modify the base value" do
        (subject + 40.5).value.should == 80.5
        subject.value.should == 40.0
      end
      it "should be able to add another currency value" do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        (subject + Exchange::Money.new(30, :chf)).value.round(2).should == 72.87
        (subject + Exchange::Money.new(30, :sek)).currency.should == :usd
        subject.value.round(2).should == 40
        subject.currency.should == :usd
      end
      it "should raise when currencies get mixed and the configuration does not allow it" do
        Exchange.configuration.implicit_conversions = false
        lambda { subject + Exchange::Money.new(30, :chf) }.should raise_error(Exchange::ImplicitConversionError)
      end
      it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
        Exchange.configuration.implicit_conversions = false
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        lambda { subject + Exchange::Money.new(30, :usd) }.should_not raise_error
      end
      context "modifying the base value" do
        before(:each) do
          # subject does not eval correctly when used with modifiers
          @instantiated = subject
        end
        it "should be able to add an integer" do
          (@instantiated += 40).value.should == 80
        end
        it "should be able to add a float" do
          (@instantiated += 40.5).value.should == 80.5
        end
        it "should modify the base value" do
          (@instantiated += 40.5).value.should == 80.5
          @instantiated.value.should == 80.5
        end
        it "should be able to add another currency value" do
          mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
          added = (@instantiated += Exchange::Money.new(30, :chf))
          added.value.round(2).should == 72.87
          added.currency.should == :usd
          @instantiated.value.round(2).should == 72.87
          @instantiated.currency.should == :usd
        end
        it "should raise when currencies get mixed and the configuration does not allow it" do
          Exchange.configuration.implicit_conversions = false
          lambda { @instantiated += Exchange::Money.new(30, :chf) }.should raise_error(Exchange::ImplicitConversionError)
          Exchange.configuration.implicit_conversions = true
        end
        it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
          Exchange.configuration.implicit_conversions = false
          mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
          lambda { @instantiated += Exchange::Money.new(30, :usd) }.should_not raise_error
          Exchange.configuration.implicit_conversions = true
        end
      end
    end
    describe "- other" do
      after(:each) do
        Exchange.configuration.implicit_conversions = true
      end
      it "should be able to subtract an integer" do
        (subject - 40).value.should == 0
      end
      it "should be able to subtract a float" do
        (subject - 40.5).value.should == -0.5
      end
      context "with a big decimal" do
        subject { Exchange::Money.new(1829.82, :omr) }
        it "should be able to subtract a big decimal below zero" do
          (subject - BigDecimal.new("0.45454545")).value.round(8).should == BigDecimal.new("0.182936545455E4")
        end
        it "should be able to subtract a big decimal above zero" do
          (subject - BigDecimal.new("12.455")).round(2).value.should == BigDecimal.new("0.181737E4")
        end
      end
      it "should not modify the base value" do
        (subject - 40).value.should == 0
        subject.value.should == 40.0
      end
      it "should be able to subtract another currency value" do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        Exchange.configuration.implicit_conversions = true
        (subject - Exchange::Money.new(10, :chf)).value.round(2).should == 29.04
        (subject - Exchange::Money.new(23.3, :eur)).currency.should == :usd
      end
      it "should raise when currencies get mixed and the configuration does not allow it" do
        Exchange.configuration.implicit_conversions = false
        lambda { subject - Exchange::Money.new(30, :chf) }.should raise_error(Exchange::ImplicitConversionError)
      end
      it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
        Exchange.configuration.implicit_conversions = false
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        lambda { subject - Exchange::Money.new(30, :usd) }.should_not raise_error
      end
      context "modifying the base value" do
        before(:each) do
          # subject does not eval correctly when used with modifiers
          @instantiated = subject
        end
        it "should be able to subtract an integer" do
          (@instantiated -= 40).value.should == 0
        end
        it "should be able to subtract a float" do
          (@instantiated -= 40.5).value.should == -0.5
        end
        it "should modify the base value" do
          (@instantiated -= 40.5).value.should == -0.5
          @instantiated.value.should == -0.5
        end
        it "should be able to subtract another currency value" do
          mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
          Exchange.configuration.implicit_conversions = true
          added = (@instantiated -= Exchange::Money.new(10, :chf))
          added.value.round(2).should == 29.04
          added.currency.should == :usd
          @instantiated.value.round(2).should == 29.04
          @instantiated.currency.should == :usd
        end
        it "should raise when currencies get mixed and the configuration does not allow it" do
          Exchange.configuration.implicit_conversions = false
          lambda { @instantiated -= Exchange::Money.new(30, :chf) }.should raise_error(Exchange::ImplicitConversionError)
          Exchange.configuration.implicit_conversions = true
        end
        it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
          Exchange.configuration.implicit_conversions = false
          mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
          lambda { @instantiated -= Exchange::Money.new(30, :usd) }.should_not raise_error
          Exchange.configuration.implicit_conversions = true
        end
      end
    end
    describe "* other" do
      after(:each) do
        Exchange.configuration.implicit_conversions = true
      end
      it "should be able to multiply by an integer" do
        (subject * 40).value.should == 1600
      end
      context "with a float" do
        subject { Exchange::Money.new(50, :usd) }
        it "should be able to multiply a float" do
          (subject * 40.5).value.should == 2025
        end
        it "should not fall for rounding errors" do
          (subject * 0.29).round(0).value.should == 15
        end
      end
      context "with a big decimal" do
        subject { Exchange::Money.new(1829.82, :omr) }
        it "should be able to multiply by a big decimal below zero" do
          (subject * BigDecimal.new("0.45454545")).value.round(8).should == BigDecimal.new("0.83173635532E3")
        end
        it "should be able to multiply by a big decimal above zero" do
          (subject * BigDecimal.new("12.455")).round(2).value.should == BigDecimal.new("0.2279041E5")
        end
      end
      it "should not fall for float rounding errors" do
        (subject * 40.5)
      end
      it "should be able to multiply by another currency value" do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        Exchange.configuration.implicit_conversions = true
        (subject * Exchange::Money.new(10, :chf)).value.round(1).should == 438.3
        (subject * Exchange::Money.new(23.3, :eur)).currency.should == :usd
      end
      it "should raise when currencies get mixed and the configuration does not allow it" do
        Exchange.configuration.implicit_conversions = false
        lambda { subject * Exchange::Money.new(30, :chf) }.should raise_error(Exchange::ImplicitConversionError)
      end
      it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
        Exchange.configuration.implicit_conversions = false
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        lambda { subject * Exchange::Money.new(30, :usd) }.should_not raise_error
      end
      context "modifying the base value" do
        before(:each) do
          # subject does not eval correctly when used with modifiers
          @instantiated = subject
        end
        it "should be able to multiply by an integer" do
          (@instantiated *= 40).value.should == 1600
        end
        it "should be able to multiply a float" do
          (@instantiated *= 40.5).value.should == 1620
        end
        it "should modify the base value" do
          (@instantiated *= 40.5).value.should == 1620
          @instantiated.value.should == 1620
        end
        it "should be able to multiply by another currency value" do
          mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
          Exchange.configuration.implicit_conversions = true
          added = (@instantiated *= Exchange::Money.new(9, :chf))
          added.value.round(1).should == 394.50
          added.currency.should == :usd
          @instantiated.value.round(1).should == 394.50
          @instantiated.currency.should == :usd
        end
        it "should raise when currencies get mixed and the configuration does not allow it" do
          Exchange.configuration.implicit_conversions = false
          lambda { @instantiated *= Exchange::Money.new(30, :chf) }.should raise_error(Exchange::ImplicitConversionError)
          Exchange.configuration.implicit_conversions = true
        end
        it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
          Exchange.configuration.implicit_conversions = false
          mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
          lambda { @instantiated *= Exchange::Money.new(30, :usd) }.should_not raise_error
          Exchange.configuration.implicit_conversions = true
        end
      end
    end
    describe "% other" do
      after(:each) do
        Exchange.configuration.implicit_conversions = true
      end
      it "should be able to multiply by an integer" do
        (subject % 40).value.should == 0
      end
      context "with a float" do
        subject { Exchange::Money.new(50, :usd) }
        it "should be able to multiply a float" do
          (subject % 40.5).value.should == 9.5
        end
        it "should not fall for rounding errors" do
          (subject % 0.29).round(2).value.should == 0.12
        end
      end
      it "should be able to multiply by another currency value" do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        Exchange.configuration.implicit_conversions = true
        (subject % Exchange::Money.new(10, :chf)).value.round(1).should == 7.1
        (subject % Exchange::Money.new(23.3, :eur)).currency.should == :usd
      end
      it "should raise when currencies get mixed and the configuration does not allow it" do
        Exchange.configuration.implicit_conversions = false
        lambda { subject % Exchange::Money.new(30, :chf) }.should raise_error(Exchange::ImplicitConversionError)
      end
      it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
        Exchange.configuration.implicit_conversions = false
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        lambda { subject % Exchange::Money.new(30, :usd) }.should_not raise_error
      end
    end
    describe "/ other" do
      after(:each) do
        Exchange.configuration.implicit_conversions = true
      end
      it "should be able to divide by an integer" do
        (subject / 40).value.should == 1
      end
      context "with a float" do
        subject { Exchange::Money.new(1829.82, :omr) }
        it "should be able to divide by a float" do
          (subject / 40.5).value.round(4).should == 45.1807
        end
        it "should not fall for floating point errors" do
          (subject / 12.0).round(2).value.should == 152.49
        end
      end
      context "with a big decimal" do
        subject { Exchange::Money.new(1829.82, :omr) }
        it "should be able to divide by a big decimal below zero" do
          (subject / BigDecimal.new("0.45454545")).value.round(8).should == BigDecimal.new("0.402560404026E4")
        end
        it "should be able to divide by a big decimal above zero" do
          (subject / BigDecimal.new("12.455")).round(2).value.should == BigDecimal.new("0.14691E3")
        end
      end
      it "should not modify the base value" do
        (subject / 40).value.should == 1
        subject.value.should == 40.0
      end
      it "should modify the base value if the operator is used with =" do
        instantiated = subject
        (instantiated /= 40).value.should == 1
        instantiated.value.should == 1
      end
      it "should be able to divide by another currency value" do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        Exchange.configuration.implicit_conversions = true
        (subject / Exchange::Money.new(10, :chf)).value.round(2).should == BigDecimal.new("3.65")
        (subject / Exchange::Money.new(23.3, :eur)).currency.should == :usd
      end
      it "should raise when currencies get mixed and the configuration does not allow it" do
        Exchange.configuration.implicit_conversions = false
        lambda { subject / Exchange::Money.new(30, :chf) }.should raise_error(Exchange::ImplicitConversionError)
      end
      it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
        Exchange.configuration.implicit_conversions = false
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        lambda { subject / Exchange::Money.new(30, :usd) }.should_not raise_error
      end
      context "modifying the base value" do
        before(:each) do
          # subject does not eval correctly when used with modifiers
          @instantiated = subject
        end
        it "should be able to add an integer" do
          (@instantiated /= 40).value.should == 1
        end
        it "should be able to multiply a float" do
          (@instantiated /= 13.3).value.round(2).should == 3.01
        end
        it "should modify the base value" do
          (@instantiated /= 13.3).value.round(2).should == 3.01
          @instantiated.value.round(2).should == 3.01
        end
        it "should be able to divide by another currency value" do
          mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
          Exchange.configuration.implicit_conversions = true
          added = (@instantiated /= Exchange::Money.new(10, :chf))
          added.value.round(2).should == 3.65
          added.currency.should == :usd
          @instantiated.value.round(2).should == 3.65
          @instantiated.currency.should == :usd
        end
        it "should raise when currencies get mixed and the configuration does not allow it" do
          Exchange.configuration.implicit_conversions = false
          lambda { @instantiated /= Exchange::Money.new(30, :chf) }.should raise_error(Exchange::ImplicitConversionError)
          Exchange.configuration.implicit_conversions = true
        end
        it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
          Exchange.configuration.implicit_conversions = false
          mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
          lambda { @instantiated /= Exchange::Money.new(30, :usd) }.should_not raise_error
          Exchange.configuration.implicit_conversions = true
        end
      end
      describe "split" do
        it "should split a currency evenly without losing fractional amounts" do
          mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 200)
          
          Exchange::Money.new(1, :chf).split(3).should == [Exchange::Money.new(0.34, :chf), Exchange::Money.new(0.33, :chf), Exchange::Money.new(0.33, :chf)]
          Exchange::Money.new(1.001, :omr).split(3).should == [Exchange::Money.new(0.334, :omr), Exchange::Money.new(0.334, :omr), Exchange::Money.new(0.333, :omr)]
          Exchange::Money.new(100, :jpy).split(3).should == [Exchange::Money.new(34, :jpy), Exchange::Money.new(33, :jpy), Exchange::Money.new(33, :jpy)]
          Exchange::Money.new(3, :usd).split(4).should == 4.times.map { Exchange::Money.new(0.75, :usd) }
          Exchange::Money.new(1, :usd).split(6).should == 4.times.map { Exchange::Money.new(0.17, :usd) } + 2.times.map { Exchange::Money.new(0.16, :usd) }
          Exchange::Money.new(0.998, :omr).split(13).should == 10.times.map { Exchange::Money.new(0.077, :omr) } + 3.times.map { Exchange::Money.new(0.076, :omr) }
        end
      end
    end
    describe "comparison" do
      subject { Exchange::Money.new(40.123, :usd) }
      let(:comp1) { Exchange::Money.new(40.123, :usd) }
      let(:comp2) { Exchange::Money.new(40, :usd) }
      let(:comp3) { Exchange::Money.new(50, :eur) }
      let(:comp4) { Exchange::Money.new(45, :eur) }
      let(:comp5) { Exchange::Money.new(50, :eur).to(:usd) }
      let(:comp6) { Exchange::Money.new(66.1, :usd, :at => Time.gm(2011,1,1)) }
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
        context "with implicit conversion turned off" do
          before(:each) do
            Exchange.configuration.implicit_conversions = false
          end
          after(:each) do
            Exchange.configuration.implicit_conversions = true
          end
          it "should raise an error" do
            lambda { comp3 == comp5 }.should raise_error(Exchange::ImplicitConversionError)
          end
        end
      end
    end
    describe "sorting" do
      subject { Exchange::Money.new(40.123, :usd) }
      let(:comp1) { Exchange::Money.new(40.123, :usd) }
      let(:comp2) { Exchange::Money.new(40, :usd) }
      let(:comp3) { Exchange::Money.new(50, :eur) }
      let(:comp4) { Exchange::Money.new(45, :eur) }
      before(:each) do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 6)
      end
      it "should sort and by doing conversions" do
        [subject, comp1, comp2, comp3, comp4].sort.should == [comp2, subject, comp1, comp4, comp3]
      end
      context "with implicit conversion turned off" do
        before(:each) do
          Exchange.configuration.implicit_conversions = false
        end
        after(:each) do
          Exchange.configuration.implicit_conversions = true
        end
        it "should raise an error" do
          lambda { [subject, comp1, comp2, comp3, comp4].sort }.should raise_error(Exchange::ImplicitConversionError)
        end
      end
    end
    describe "round" do
      subject { Exchange::Money.new(40.123, :usd) }
      context "without arguments" do
        it "should apply it to its number in the iso certified format" do
          subject.round.value.should == 40.12
          subject.round.currency.should == :usd
          subject.round.should be_kind_of Exchange::Money
        end
        it "should not modify the base value" do
          subject.round.value.should == 40.12
          subject.value.should == 40.123
        end
      end
      context "with arguments" do
        it "should apply it to its number" do
          subject.round(0).value.should == 40
          subject.round(0).currency.should == :usd
          subject.round(0).should be_kind_of Exchange::Money
        end
        it "should allow to round to whatever number of decimals" do
          subject.round(2).value.should == 40.12
          subject.round(2).currency.should == :usd
          subject.round(2).should be_kind_of Exchange::Money
        end
        it "should allow for psychological rounding" do
          subject.round(:psych).value.should == 39.99
          subject.round(:psych).currency.should == :usd
          subject.round(:psych).should be_kind_of Exchange::Money
        end
      end
    end
    describe "ceil" do
      subject { Exchange::Money.new(40.1236, :omr) }
      context "without arguments" do
        it "should apply it to its number in the iso certified format" do
          subject.ceil.value.should == 40.124
          subject.ceil.currency.should == :omr
          subject.ceil.should be_kind_of Exchange::Money
        end
        it "should not modify the base value" do
          subject.ceil.value.should == 40.124
          subject.value.should == 40.1236
        end
      end
      context "with arguments" do
        it "should apply it to its number" do
          subject.ceil(0).value.should == 41
          subject.ceil(0).currency.should == :omr
          subject.ceil(0).should be_kind_of Exchange::Money
        end
        it "should allow to round to whatever number of decimals" do
          subject.ceil(2).value.should == 40.13
          subject.ceil(2).currency.should == :omr
          subject.ceil(2).should be_kind_of Exchange::Money
        end
        it "should allow for psychological ceiling" do
          subject.ceil(:psych).value.should == 40.999
          subject.ceil(:psych).currency.should == :omr
          subject.ceil(:psych).should be_kind_of Exchange::Money
        end
      end
    end
    describe "floor" do
      subject { Exchange::Money.new(40.723, :jpy) }
      context "without arguments" do
        it "should apply it to its number in the iso certified format" do
          subject.floor.value.should == 40
          subject.floor.currency.should == :jpy
          subject.floor.should be_kind_of Exchange::Money
        end
        it "should not modify the base value" do
          subject.floor.value.should == 40
          subject.value.should == 40.723
        end
      end
      context "with arguments" do
        it "should apply it to its number" do
          subject.floor(1).value.should == 40.7
          subject.floor(1).currency.should == :jpy
          subject.floor(1).should be_kind_of Exchange::Money
        end
        it "should allow to round to whatever number of decimals" do
          subject.floor(2).value.should == 40.72
          subject.floor(2).currency.should == :jpy
          subject.floor(2).should be_kind_of Exchange::Money
        end
        it "should allow for psychological flooring" do
          subject.floor(:psych).value.should == 39
          subject.floor(:psych).currency.should == :jpy
          subject.floor(:psych).should be_kind_of Exchange::Money
        end
      end
    end
  end
  describe "to_s" do
    it "should render the currency according to ISO 4217 Definitions" do
      Exchange::Money.new(23.232524, :tnd).to_s.should == "TND 23.233"
      Exchange::Money.new(23.23252423, :sar).to_s.should == "SAR 23.23"
      Exchange::Money.new(23.23252423, :clp).to_s.should == "CLP 23"
      Exchange::Money.new(23.2, :tnd).to_s.should == "TND 23.200"
      Exchange::Money.new(23.4, :sar).to_s.should == "SAR 23.40"
      Exchange::Money.new(23.0, :clp).to_s.should == "CLP 23"
    end
    it "should render only the currency amount if the argument amount is passed" do
      Exchange::Money.new(23.232524, :tnd).to_s(:amount).should == "23.233"
      Exchange::Money.new(23.23252423, :sar).to_s(:amount).should == "23.23"
      Exchange::Money.new(23.23252423, :clp).to_s(:amount).should == "23"
      Exchange::Money.new(23.2, :tnd).to_s(:amount).should == "23.200"
      Exchange::Money.new(23.4, :sar).to_s(:amount).should == "23.40"
      Exchange::Money.new(23.0, :clp).to_s(:amount).should == "23"
    end
    it "should render only the currency amount and no separators if the argument amount is passed" do
      Exchange::Money.new(2323.232524, :tnd).to_s(:plain).should == "2323.233"
      Exchange::Money.new(2323.23252423, :sar).to_s(:plain).should == "2323.23"
      Exchange::Money.new(2323.23252423, :clp).to_s(:plain).should == "2323"
      Exchange::Money.new(23.2, :tnd).to_s(:plain).should == "23.200"
      Exchange::Money.new(23.4, :sar).to_s(:plain).should == "23.40"
      Exchange::Money.new(23.0, :clp).to_s(:plain).should == "23"
    end
    it "should render the currency with a symbol according to ISO 4217 Definitions" do
      Exchange::Money.new(23.232524, :tnd).to_s(:symbol).should == "TND 23.233"
      Exchange::Money.new(23.23252423, :sar).to_s(:symbol).should == "﷼23.23"
      Exchange::Money.new(23.23252423, :clp).to_s(:symbol).should == "$23"
      Exchange::Money.new(23.2, :tnd).to_s(:symbol).should == "TND 23.200"
      Exchange::Money.new(23.4, :sar).to_s(:symbol).should == "﷼23.40"
      Exchange::Money.new(23.0, :clp).to_s(:symbol).should == "$23"
    end
  end
  describe "to_html" do
    it "should render the currency into HTML according to ISO 4217 Definitions" do
      Exchange::Money.new(23.232524, :tnd).to_html.should == '<span class="currency tnd">TND</span><span class="amount tnd">23.233</span>'
      Exchange::Money.new(23.23252423, :sar).to_html.should == '<span class="currency sar">SAR</span><span class="amount sar">23.23</span>'
      Exchange::Money.new(23.23252423, :clp).to_html.should == '<span class="currency clp">CLP</span><span class="amount clp">23</span>'
      Exchange::Money.new(23.2, :tnd).to_html.should == '<span class="currency tnd">TND</span><span class="amount tnd">23.200</span>'
      Exchange::Money.new(23.4, :sar).to_html.should == '<span class="currency sar">SAR</span><span class="amount sar">23.40</span>'
      Exchange::Money.new(23.0, :clp).to_html.should == '<span class="currency clp">CLP</span><span class="amount clp">23</span>'
    end
    it "should render only the currency amount if the argument amount is passed" do
      Exchange::Money.new(23.232524, :tnd).to_html(:amount).should == '<span class="amount tnd">23.233</span>'
      Exchange::Money.new(23.23252423, :sar).to_html(:amount).should == '<span class="amount sar">23.23</span>'
      Exchange::Money.new(23.23252423, :clp).to_html(:amount).should == '<span class="amount clp">23</span>'
      Exchange::Money.new(23.2, :tnd).to_html(:amount).should == '<span class="amount tnd">23.200</span>'
      Exchange::Money.new(23.4, :sar).to_html(:amount).should == '<span class="amount sar">23.40</span>'
      Exchange::Money.new(23.0, :clp).to_html(:amount).should == '<span class="amount clp">23</span>'
    end
    it "should render only the currency amount and no separators if the argument amount is passed" do
      Exchange::Money.new(2323.232524, :tnd).to_html(:plain).should == '<span class="amount plain tnd">2323.233</span>'
      Exchange::Money.new(2323.23252423, :sar).to_html(:plain).should == '<span class="amount plain sar">2323.23</span>'
      Exchange::Money.new(2323.23252423, :clp).to_html(:plain).should == '<span class="amount plain clp">2323</span>'
      Exchange::Money.new(23.2, :tnd).to_html(:plain).should == '<span class="amount plain tnd">23.200</span>'
      Exchange::Money.new(23.4, :sar).to_html(:plain).should == '<span class="amount plain sar">23.40</span>'
      Exchange::Money.new(23.0, :clp).to_html(:plain).should == '<span class="amount plain clp">23</span>'
    end
    it "should render the currency with a symbol according to ISO 4217 Definitions" do
      Exchange::Money.new(23.232524, :tnd).to_html(:symbol).should == '<span class="currency symbol tnd">TND</span><span class="amount tnd">23.233</span>'
      Exchange::Money.new(23.23252423, :sar).to_html(:symbol).should == '<span class="currency symbol sar">﷼</span><span class="amount sar">23.23</span>'
      Exchange::Money.new(23.23252423, :clp).to_html(:symbol).should == '<span class="currency symbol clp">$</span><span class="amount clp">23</span>'
      Exchange::Money.new(23.2, :tnd).to_html(:symbol).should == '<span class="currency symbol tnd">TND</span><span class="amount tnd">23.200</span>'
      Exchange::Money.new(23.4, :sar).to_html(:symbol).should == '<span class="currency symbol sar">﷼</span><span class="amount sar">23.40</span>'
      Exchange::Money.new(23.0, :clp).to_html(:symbol).should == '<span class="currency symbol clp">$</span><span class="amount clp">23</span>'
    end
    it "should render only the currency amount and no separators if symbol format is passed and the argument option is plain" do
      Exchange::Money.new(2323.232524, :tnd).to_html(:symbol, :amount => :plain).should == '<span class="currency symbol tnd">TND</span><span class="amount plain tnd">2323.233</span>'
      Exchange::Money.new(2323.23252423, :sar).to_html(:symbol, :amount => :plain).should == '<span class="currency symbol sar">﷼</span><span class="amount plain sar">2323.23</span>'
      Exchange::Money.new(2323.23252423, :clp).to_html(:symbol, :amount => :plain).should == '<span class="currency symbol clp">$</span><span class="amount plain clp">2323</span>'
      Exchange::Money.new(23.2, :tnd).to_html(:symbol, :amount => :plain).should == '<span class="currency symbol tnd">TND</span><span class="amount plain tnd">23.200</span>'
      Exchange::Money.new(23.4, :sar).to_html(:symbol, :amount => :plain).should == '<span class="currency symbol sar">﷼</span><span class="amount plain sar">23.40</span>'
      Exchange::Money.new(23.0, :clp).to_html(:symbol, :amount => :plain).should == '<span class="currency symbol clp">$</span><span class="amount plain clp">23</span>'
    end
    it "should render an empty tag with the icon class if the icon format is used" do
      Exchange::Money.new(2323.232524, :tnd).to_html(:icon, :amount => :plain).should == '<span class="currency icon tnd"></span><span class="amount plain tnd">2323.233</span>'
      Exchange::Money.new(2323.23252423, :sar).to_html(:icon, :amount => :plain).should == '<span class="currency icon sar"></span><span class="amount plain sar">2323.23</span>'
      Exchange::Money.new(2323.23252423, :clp).to_html(:icon, :amount => :plain).should == '<span class="currency icon clp"></span><span class="amount plain clp">2323</span>'
      Exchange::Money.new(23.2, :tnd).to_html(:icon, :amount => :plain).should == '<span class="currency icon tnd"></span><span class="amount plain tnd">23.200</span>'
      Exchange::Money.new(23.4, :sar).to_html(:icon, :amount => :plain).should == '<span class="currency icon sar"></span><span class="amount plain sar">23.40</span>'
      Exchange::Money.new(23.0, :clp).to_html(:icon, :amount => :plain).should == '<span class="currency icon clp"></span><span class="amount plain clp">23</span>'
    end
    it "should render div tags if the tag type is optioned to div" do
      Exchange::Money.new(2323.232524, :tnd).to_html(:plain, :tag => :div).should == '<div class="amount plain tnd">2323.233</div>'
      Exchange::Money.new(2323.23252423, :sar).to_html(:plain, :tag => :div).should == '<div class="amount plain sar">2323.23</div>'
      Exchange::Money.new(2323.23252423, :clp).to_html(:plain, :tag => :div).should == '<div class="amount plain clp">2323</div>'
      Exchange::Money.new(23.2, :tnd).to_html(:plain, :tag => :div).should == '<div class="amount plain tnd">23.200</div>'
      Exchange::Money.new(23.4, :sar).to_html(:plain, :tag => :div).should == '<div class="amount plain sar">23.40</div>'
      Exchange::Money.new(23.0, :clp).to_html(:plain, :tag => :div).should == '<div class="amount plain clp">23</div>'
    end
    it "should wrap the two currency tags if a wrapping tag is defined in options" do
      Exchange::Money.new(2323.232524, :tnd).to_html(:tag => :li, :wrap => :ol).should == '<ol class="currency tnd"><li class="currency tnd">TND</li><li class="amount tnd">2323.233</li></ol>'
      Exchange::Money.new(2323.23252423, :sar).to_html(:tag => :li, :wrap => :ol).should == '<ol class="currency sar"><li class="currency sar">SAR</li><li class="amount sar">2,323.23</li></ol>'
      Exchange::Money.new(2323.23252423, :clp).to_html(:tag => :li, :wrap => :ol).should == '<ol class="currency clp"><li class="currency clp">CLP</li><li class="amount clp">2.323</li></ol>'
      Exchange::Money.new(23.2, :tnd).to_html(:tag => :li, :wrap => :ol).should == '<ol class="currency tnd"><li class="currency tnd">TND</li><li class="amount tnd">23.200</li></ol>'
      Exchange::Money.new(23.4, :sar).to_html(:tag => :li, :wrap => :ol).should == '<ol class="currency sar"><li class="currency sar">SAR</li><li class="amount sar">23.40</li></ol>'
      Exchange::Money.new(23.0, :clp).to_html(:tag => :li, :wrap => :ol).should == '<ol class="currency clp"><li class="currency clp">CLP</li><li class="amount clp">23</li></ol>'
    end
  end
  describe "symbol" do
    context "with a symbol" do
      it "should return the currency symbol" do
        Exchange::Money.new(3.5, :gbp).symbol.should == '£'
        Exchange::Money.new(3.5, :eur).symbol.should == '€'
      end
    end
    context "without a symbol" do
      it "should return nil" do
        Exchange::Money.new(3.5, :chf).symbol.should be_nil
        Exchange::Money.new(3.5, :xaf).symbol.should be_nil
      end
    end
  end
  describe "iso_code" do
    it "should return the currency ISO 4217 code as an uppercase string" do
      Exchange::Money.new(3.5, :chf).iso_code.should == 'CHF'
      Exchange::Money.new(3.5, :omr).iso_code.should == 'OMR'
    end
  end
  describe "methods via method missing" do
    it "should be able to convert via to_currency to other currencies" do
      mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 6)
      {:chf => 36.5, :usd => 40.0, :dkk => 225.12, :sek => 269.85, :nok => 232.06, :rub => 1205.24}.each do |currency, value|
        c = subject.to(currency)
        c.value.round(2).should == value
        c.currency.should == currency
      end
    end
    it "should be able to convert via to_currency to other currencies and use historic data" do
      mock_api("http://openexchangerates.org/api/historical/2011-10-09.json?app_id=", fixture('api_responses/example_json_api.json'), 6)
      {:chf => 36.5, :usd => 40.0, :dkk => 225.12, :sek => 269.85, :nok => 232.06, :rub => 1205.24}.each do |currency, value|
        c = subject.to(currency, :at => Time.gm(2011,10,9))
        c.value.round(2).should == value
        c.currency.should == currency
      end
    end
    it "should use the own time if defined as historic to convert" do
      mock_api("http://openexchangerates.org/api/historical/2011-01-01.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
      5.in(:eur, :at => Time.gm(2011,1,1)).to(:usd).value.should == 5.in(:eur).to(:usd, :at => Time.gm(2011,1,1)).value
    end
    it "should raise errors for currency conversions it does not have rates for" do
      lambda { subject.to(:ssp) }.should raise_error(Exchange::NoRateError)
    end
    it "should pass on methods it does not understand to its number" do
      subject.to_f.should == 40
      lambda { subject.to_hell }.should raise_error(NoMethodError)
    end
  end
end
