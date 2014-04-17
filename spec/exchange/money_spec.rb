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
    expect(subject.value).to eq(40)
    expect(subject.currency).to eq(:usd)
  end
  it "should initialize with a number and a country code" do
    from_country_code = Exchange::Money.new(50, :de)
    expect(from_country_code.value).to eq(50)
    expect(from_country_code.currency).to eq(:eur)
  end
  describe "initializing with a block" do
    it "should be possible" do
      currency = Exchange::Money.new(40) do |c|
        c.currency = :usd
        c.time     = Time.gm(2012,9,9)
      end
      
      expect(currency.value).to eq(40)
      expect(currency.currency).to eq(:usd)
      expect(currency.time).to eq(Time.gm(2012,9,9))
    end
  end
  describe "to" do
    context "with a currency" do
      it "should be able to convert itself to other currencies" do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 3)
        expect(subject.to(:chf).value.round(2)).to eq(36.5)
        expect(subject.to(:chf).currency).to eq(:chf)
        expect(subject.to(:chf)).to be_kind_of Exchange::Money
      end
    end
    context "with a country argument" do
      it "should be able to convert itself to the currency of the country" do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 3)
        expect(subject.to(:ch).value.round(2)).to eq(36.5)
        expect(subject.to(:ch).currency).to eq(:chf)
        expect(subject.to(:ch)).to be_kind_of Exchange::Money
      end
    end
    context "when an api is not reachable" do
      context "and a fallback api is" do
        it "should use the fallback " do
          expect(URI).to receive(:parse).with("http://openexchangerates.org/api/latest.json?app_id=").once.and_raise Exchange::ExternalAPI::APIError
          mock_api("http://api.finance.xaviermedia.com/api/#{Time.now.strftime("%Y/%m/%d")}.xml", fixture('api_responses/example_xml_api.xml'), 3)
          expect(subject.to(:ch).value.round(2)).to eq(36.36)
          expect(subject.to(:ch).currency).to eq(:chf)
          expect(subject.to(:ch)).to be_kind_of Exchange::Money
        end
      end
      context "and no fallback api is" do
        it "should raise the api error" do
          expect(URI).to receive(:parse).with("http://openexchangerates.org/api/latest.json?app_id=").once.and_raise Exchange::ExternalAPI::APIError
          expect(URI).to receive(:parse).with("http://api.finance.xaviermedia.com/api/#{Time.now.strftime("%Y/%m/%d")}.xml").once.and_raise Exchange::ExternalAPI::APIError
          expect(URI).to receive(:parse).with("http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml").once.and_raise Exchange::ExternalAPI::APIError
          expect { subject.to(:ch) }.to raise_error Exchange::ExternalAPI::APIError
        end
      end
    end
    context "with a 'from' currency not provided by the given api" do
      subject { Exchange::Money.new(36.36, :chf) }
      context "but provided by a fallback api" do
        it "should use the fallback" do
          expect(subject.api::CURRENCIES).to receive(:include?).with(:usd).and_return true
          expect(subject.api::CURRENCIES).to receive(:include?).with(:chf).and_return true
          expect(URI).to receive(:parse).with("http://openexchangerates.org/api/latest.json?app_id=").once.and_raise Exchange::ExternalAPI::APIError
          mock_api("http://api.finance.xaviermedia.com/api/#{Time.now.strftime("%Y/%m/%d")}.xml", fixture('api_responses/example_xml_api.xml'), 3)
          expect(subject.to(:usd).value.round(2)).to eq(40.00)
          expect(subject.to(:usd).currency).to eq(:usd)
          expect(subject.to(:usd)).to be_kind_of Exchange::Money
        end
      end
    end
    context "with a 'to' currency not provided by the given api" do
      context "but provided by a fallback api" do
        it "should use the fallback" do
          subject.api::CURRENCIES.stub :include? => false
          mock_api("http://api.finance.xaviermedia.com/api/#{Time.now.strftime("%Y/%m/%d")}.xml", fixture('api_responses/example_xml_api.xml'), 3)
          expect(subject.to(:chf).value.round(2)).to eq(36.36)
          expect(subject.to(:chf).currency).to eq(:chf)
          expect(subject.to(:chf)).to be_kind_of Exchange::Money
        end
      end
      context "but not provided by any fallback api" do
        it "should raise the no rate error" do
          Exchange::ExternalAPI::OpenExchangeRates::CURRENCIES.stub :include? => false
          Exchange::ExternalAPI::XavierMedia::CURRENCIES.stub :include? => false
          Exchange::ExternalAPI::Ecb::CURRENCIES.stub :include? => false
          expect { subject.to(:xaf) }.to raise_error Exchange::NoRateError
        end
      end
    end
  end
  describe "operations" do
    after(:each) do
      Exchange.configuration.implicit_conversions = true
    end
    describe "+ other" do
      it "should be able to add an integer" do
        expect((subject + 40).value).to eq(80)
      end
      it "should be able to add a float" do
        expect((subject + 40.5).value).to eq(80.5)
      end
      context "with a big decimal" do
        subject { Exchange::Money.new(0.82, :omr) }
        it "should be able to add a big decimal below zero" do
          expect((subject + BigDecimal.new("0.45454545")).value.round(8)).to eq(BigDecimal.new("0.127454545E1"))
        end
        it "should be able to add a big decimal above zero" do
          expect((subject + BigDecimal.new("12.455")).round(2).value).to eq(BigDecimal.new("0.1328E2"))
        end
      end
      it "should not modify the base value" do
        expect((subject + 40.5).value).to eq(80.5)
        expect(subject.value).to eq(40.0)
      end
      it "should be able to add another currency value" do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        expect((subject + Exchange::Money.new(30, :chf)).value.round(2)).to eq(72.87)
        expect((subject + Exchange::Money.new(30, :sek)).currency).to eq(:usd)
        expect(subject.value.round(2)).to eq(40)
        expect(subject.currency).to eq(:usd)
      end
      it "should raise when currencies get mixed and the configuration does not allow it" do
        Exchange.configuration.implicit_conversions = false
        expect { subject + Exchange::Money.new(30, :chf) }.to raise_error(Exchange::ImplicitConversionError)
      end
      it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
        Exchange.configuration.implicit_conversions = false
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        expect { subject + Exchange::Money.new(30, :usd) }.not_to raise_error
      end
      context "modifying the base value" do
        before(:each) do
          # subject does not eval correctly when used with modifiers
          @instantiated = subject
        end
        it "should be able to add an integer" do
          expect((@instantiated += 40).value).to eq(80)
        end
        it "should be able to add a float" do
          expect((@instantiated += 40.5).value).to eq(80.5)
        end
        it "should modify the base value" do
          expect((@instantiated += 40.5).value).to eq(80.5)
          expect(@instantiated.value).to eq(80.5)
        end
        it "should be able to add another currency value" do
          mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
          added = (@instantiated += Exchange::Money.new(30, :chf))
          expect(added.value.round(2)).to eq(72.87)
          expect(added.currency).to eq(:usd)
          expect(@instantiated.value.round(2)).to eq(72.87)
          expect(@instantiated.currency).to eq(:usd)
        end
        it "should raise when currencies get mixed and the configuration does not allow it" do
          Exchange.configuration.implicit_conversions = false
          expect { @instantiated += Exchange::Money.new(30, :chf) }.to raise_error(Exchange::ImplicitConversionError)
          Exchange.configuration.implicit_conversions = true
        end
        it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
          Exchange.configuration.implicit_conversions = false
          mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
          expect { @instantiated += Exchange::Money.new(30, :usd) }.not_to raise_error
          Exchange.configuration.implicit_conversions = true
        end
      end
    end
    describe "- other" do
      after(:each) do
        Exchange.configuration.implicit_conversions = true
      end
      it "should be able to subtract an integer" do
        expect((subject - 40).value).to eq(0)
      end
      it "should be able to subtract a float" do
        expect((subject - 40.5).value).to eq(-0.5)
      end
      context "with a big decimal" do
        subject { Exchange::Money.new(1829.82, :omr) }
        it "should be able to subtract a big decimal below zero" do
          expect((subject - BigDecimal.new("0.45454545")).value.round(8)).to eq(BigDecimal.new("0.182936545455E4"))
        end
        it "should be able to subtract a big decimal above zero" do
          expect((subject - BigDecimal.new("12.455")).round(2).value).to eq(BigDecimal.new("0.181737E4"))
        end
      end
      it "should not modify the base value" do
        expect((subject - 40).value).to eq(0)
        expect(subject.value).to eq(40.0)
      end
      it "should be able to subtract another currency value" do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        Exchange.configuration.implicit_conversions = true
        expect((subject - Exchange::Money.new(10, :chf)).value.round(2)).to eq(29.04)
        expect((subject - Exchange::Money.new(23.3, :eur)).currency).to eq(:usd)
      end
      it "should raise when currencies get mixed and the configuration does not allow it" do
        Exchange.configuration.implicit_conversions = false
        expect { subject - Exchange::Money.new(30, :chf) }.to raise_error(Exchange::ImplicitConversionError)
      end
      it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
        Exchange.configuration.implicit_conversions = false
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        expect { subject - Exchange::Money.new(30, :usd) }.not_to raise_error
      end
      context "modifying the base value" do
        before(:each) do
          # subject does not eval correctly when used with modifiers
          @instantiated = subject
        end
        it "should be able to subtract an integer" do
          expect((@instantiated -= 40).value).to eq(0)
        end
        it "should be able to subtract a float" do
          expect((@instantiated -= 40.5).value).to eq(-0.5)
        end
        it "should modify the base value" do
          expect((@instantiated -= 40.5).value).to eq(-0.5)
          expect(@instantiated.value).to eq(-0.5)
        end
        it "should be able to subtract another currency value" do
          mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
          Exchange.configuration.implicit_conversions = true
          added = (@instantiated -= Exchange::Money.new(10, :chf))
          expect(added.value.round(2)).to eq(29.04)
          expect(added.currency).to eq(:usd)
          expect(@instantiated.value.round(2)).to eq(29.04)
          expect(@instantiated.currency).to eq(:usd)
        end
        it "should raise when currencies get mixed and the configuration does not allow it" do
          Exchange.configuration.implicit_conversions = false
          expect { @instantiated -= Exchange::Money.new(30, :chf) }.to raise_error(Exchange::ImplicitConversionError)
          Exchange.configuration.implicit_conversions = true
        end
        it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
          Exchange.configuration.implicit_conversions = false
          mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
          expect { @instantiated -= Exchange::Money.new(30, :usd) }.not_to raise_error
          Exchange.configuration.implicit_conversions = true
        end
      end
    end
    describe "* other" do
      after(:each) do
        Exchange.configuration.implicit_conversions = true
      end
      it "should be able to multiply by an integer" do
        expect((subject * 40).value).to eq(1600)
      end
      context "with a float" do
        subject { Exchange::Money.new(50, :usd) }
        it "should be able to multiply a float" do
          expect((subject * 40.5).value).to eq(2025)
        end
        it "should not fall for rounding errors" do
          expect((subject * 0.29).round(0).value).to eq(15)
        end
      end
      context "with a big decimal" do
        subject { Exchange::Money.new(1829.82, :omr) }
        it "should be able to multiply by a big decimal below zero" do
          expect((subject * BigDecimal.new("0.45454545")).value.round(8)).to eq(BigDecimal.new("0.83173635532E3"))
        end
        it "should be able to multiply by a big decimal above zero" do
          expect((subject * BigDecimal.new("12.455")).round(2).value).to eq(BigDecimal.new("0.2279041E5"))
        end
      end
      it "should not fall for float rounding errors" do
        (subject * 40.5)
      end
      it "should be able to multiply by another currency value" do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        Exchange.configuration.implicit_conversions = true
        expect((subject * Exchange::Money.new(10, :chf)).value.round(1)).to eq(438.3)
        expect((subject * Exchange::Money.new(23.3, :eur)).currency).to eq(:usd)
      end
      it "should raise when currencies get mixed and the configuration does not allow it" do
        Exchange.configuration.implicit_conversions = false
        expect { subject * Exchange::Money.new(30, :chf) }.to raise_error(Exchange::ImplicitConversionError)
      end
      it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
        Exchange.configuration.implicit_conversions = false
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        expect { subject * Exchange::Money.new(30, :usd) }.not_to raise_error
      end
      context "modifying the base value" do
        before(:each) do
          # subject does not eval correctly when used with modifiers
          @instantiated = subject
        end
        it "should be able to multiply by an integer" do
          expect((@instantiated *= 40).value).to eq(1600)
        end
        it "should be able to multiply a float" do
          expect((@instantiated *= 40.5).value).to eq(1620)
        end
        it "should modify the base value" do
          expect((@instantiated *= 40.5).value).to eq(1620)
          expect(@instantiated.value).to eq(1620)
        end
        it "should be able to multiply by another currency value" do
          mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
          Exchange.configuration.implicit_conversions = true
          added = (@instantiated *= Exchange::Money.new(9, :chf))
          expect(added.value.round(1)).to eq(394.50)
          expect(added.currency).to eq(:usd)
          expect(@instantiated.value.round(1)).to eq(394.50)
          expect(@instantiated.currency).to eq(:usd)
        end
        it "should raise when currencies get mixed and the configuration does not allow it" do
          Exchange.configuration.implicit_conversions = false
          expect { @instantiated *= Exchange::Money.new(30, :chf) }.to raise_error(Exchange::ImplicitConversionError)
          Exchange.configuration.implicit_conversions = true
        end
        it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
          Exchange.configuration.implicit_conversions = false
          mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
          expect { @instantiated *= Exchange::Money.new(30, :usd) }.not_to raise_error
          Exchange.configuration.implicit_conversions = true
        end
      end
    end
    describe "/ other" do
      after(:each) do
        Exchange.configuration.implicit_conversions = true
      end
      it "should be able to divide by an integer" do
        expect((subject / 40).value).to eq(1)
      end
      context "with a float" do
        subject { Exchange::Money.new(1829.82, :omr) }
        it "should be able to divide by a float" do
          expect((subject / 40.5).value.round(4)).to eq(45.1807)
        end
        it "should not fall for floating point errors" do
          expect((subject / 12.0).round(2).value).to eq(152.49)
        end
      end
      context "with a big decimal" do
        subject { Exchange::Money.new(1829.82, :omr) }
        it "should be able to divide by a big decimal below zero" do
          expect((subject / BigDecimal.new("0.45454545")).value.round(8)).to eq(BigDecimal.new("0.402560404026E4"))
        end
        it "should be able to divide by a big decimal above zero" do
          expect((subject / BigDecimal.new("12.455")).round(2).value).to eq(BigDecimal.new("0.14691E3"))
        end
      end
      it "should not modify the base value" do
        expect((subject / 40).value).to eq(1)
        expect(subject.value).to eq(40.0)
      end
      it "should modify the base value if the operator is used with =" do
        instantiated = subject
        expect((instantiated /= 40).value).to eq(1)
        expect(instantiated.value).to eq(1)
      end
      it "should be able to divide by another currency value" do
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        Exchange.configuration.implicit_conversions = true
        expect((subject / Exchange::Money.new(10, :chf)).value.round(2)).to eq(BigDecimal.new("3.65"))
        expect((subject / Exchange::Money.new(23.3, :eur)).currency).to eq(:usd)
      end
      it "should raise when currencies get mixed and the configuration does not allow it" do
        Exchange.configuration.implicit_conversions = false
        expect { subject / Exchange::Money.new(30, :chf) }.to raise_error(Exchange::ImplicitConversionError)
      end
      it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
        Exchange.configuration.implicit_conversions = false
        mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
        expect { subject / Exchange::Money.new(30, :usd) }.not_to raise_error
      end
      context "modifying the base value" do
        before(:each) do
          # subject does not eval correctly when used with modifiers
          @instantiated = subject
        end
        it "should be able to add an integer" do
          expect((@instantiated /= 40).value).to eq(1)
        end
        it "should be able to multiply a float" do
          expect((@instantiated /= 13.3).value.round(2)).to eq(3.01)
        end
        it "should modify the base value" do
          expect((@instantiated /= 13.3).value.round(2)).to eq(3.01)
          expect(@instantiated.value.round(2)).to eq(3.01)
        end
        it "should be able to divide by another currency value" do
          mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
          Exchange.configuration.implicit_conversions = true
          added = (@instantiated /= Exchange::Money.new(10, :chf))
          expect(added.value.round(2)).to eq(3.65)
          expect(added.currency).to eq(:usd)
          expect(@instantiated.value.round(2)).to eq(3.65)
          expect(@instantiated.currency).to eq(:usd)
        end
        it "should raise when currencies get mixed and the configuration does not allow it" do
          Exchange.configuration.implicit_conversions = false
          expect { @instantiated /= Exchange::Money.new(30, :chf) }.to raise_error(Exchange::ImplicitConversionError)
          Exchange.configuration.implicit_conversions = true
        end
        it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
          Exchange.configuration.implicit_conversions = false
          mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
          expect { @instantiated /= Exchange::Money.new(30, :usd) }.not_to raise_error
          Exchange.configuration.implicit_conversions = true
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
          expect(subject == comp1).to be_true
        end
        it "should be false if the value is different" do
          expect(subject == comp2).to be_false
        end
      end
      context "with different currencies" do
        it "should be true if the converted value is the same" do
          expect(comp3 == comp5).to be_true
        end
        it "should be false if the converted value is different" do
          expect(subject == comp4).to be_false
        end
        it "should be false if the currency is defined historic and the converted value is different" do
          mock_api("http://openexchangerates.org/api/historical/2011-01-01.json?app_id=", fixture('api_responses/example_historic_json.json'), 2)
          expect(comp3 == comp6).to be_false
        end
        context "with implicit conversion turned off" do
          before(:each) do
            Exchange.configuration.implicit_conversions = false
          end
          after(:each) do
            Exchange.configuration.implicit_conversions = true
          end
          it "should raise an error" do
            expect { comp3 == comp5 }.to raise_error(Exchange::ImplicitConversionError)
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
        expect([subject, comp1, comp2, comp3, comp4].sort).to eq([comp2, subject, comp1, comp4, comp3])
      end
      context "with implicit conversion turned off" do
        before(:each) do
          Exchange.configuration.implicit_conversions = false
        end
        after(:each) do
          Exchange.configuration.implicit_conversions = true
        end
        it "should raise an error" do
          expect { [subject, comp1, comp2, comp3, comp4].sort }.to raise_error(Exchange::ImplicitConversionError)
        end
      end
    end
    describe "round" do
      subject { Exchange::Money.new(40.123, :usd) }
      context "without arguments" do
        it "should apply it to its number in the iso certified format" do
          expect(subject.round.value).to eq(40.12)
          expect(subject.round.currency).to eq(:usd)
          expect(subject.round).to be_kind_of Exchange::Money
        end
        it "should not modify the base value" do
          expect(subject.round.value).to eq(40.12)
          expect(subject.value).to eq(40.123)
        end
      end
      context "with arguments" do
        it "should apply it to its number" do
          expect(subject.round(0).value).to eq(40)
          expect(subject.round(0).currency).to eq(:usd)
          expect(subject.round(0)).to be_kind_of Exchange::Money
        end
        it "should allow to round to whatever number of decimals" do
          expect(subject.round(2).value).to eq(40.12)
          expect(subject.round(2).currency).to eq(:usd)
          expect(subject.round(2)).to be_kind_of Exchange::Money
        end
        it "should allow for psychological rounding" do
          expect(subject.round(:psych).value).to eq(39.99)
          expect(subject.round(:psych).currency).to eq(:usd)
          expect(subject.round(:psych)).to be_kind_of Exchange::Money
        end
      end
    end
    describe "ceil" do
      subject { Exchange::Money.new(40.1236, :omr) }
      context "without arguments" do
        it "should apply it to its number in the iso certified format" do
          expect(subject.ceil.value).to eq(40.124)
          expect(subject.ceil.currency).to eq(:omr)
          expect(subject.ceil).to be_kind_of Exchange::Money
        end
        it "should not modify the base value" do
          expect(subject.ceil.value).to eq(40.124)
          expect(subject.value).to eq(40.1236)
        end
      end
      context "with arguments" do
        it "should apply it to its number" do
          expect(subject.ceil(0).value).to eq(41)
          expect(subject.ceil(0).currency).to eq(:omr)
          expect(subject.ceil(0)).to be_kind_of Exchange::Money
        end
        it "should allow to round to whatever number of decimals" do
          expect(subject.ceil(2).value).to eq(40.13)
          expect(subject.ceil(2).currency).to eq(:omr)
          expect(subject.ceil(2)).to be_kind_of Exchange::Money
        end
        it "should allow for psychological ceiling" do
          expect(subject.ceil(:psych).value).to eq(40.999)
          expect(subject.ceil(:psych).currency).to eq(:omr)
          expect(subject.ceil(:psych)).to be_kind_of Exchange::Money
        end
      end
    end
    describe "floor" do
      subject { Exchange::Money.new(40.723, :jpy) }
      context "without arguments" do
        it "should apply it to its number in the iso certified format" do
          expect(subject.floor.value).to eq(40)
          expect(subject.floor.currency).to eq(:jpy)
          expect(subject.floor).to be_kind_of Exchange::Money
        end
        it "should not modify the base value" do
          expect(subject.floor.value).to eq(40)
          expect(subject.value).to eq(40.723)
        end
      end
      context "with arguments" do
        it "should apply it to its number" do
          expect(subject.floor(1).value).to eq(40.7)
          expect(subject.floor(1).currency).to eq(:jpy)
          expect(subject.floor(1)).to be_kind_of Exchange::Money
        end
        it "should allow to round to whatever number of decimals" do
          expect(subject.floor(2).value).to eq(40.72)
          expect(subject.floor(2).currency).to eq(:jpy)
          expect(subject.floor(2)).to be_kind_of Exchange::Money
        end
        it "should allow for psychological flooring" do
          expect(subject.floor(:psych).value).to eq(39)
          expect(subject.floor(:psych).currency).to eq(:jpy)
          expect(subject.floor(:psych)).to be_kind_of Exchange::Money
        end
      end
    end
  end
  describe "to_s" do
    it "should render the currency according to ISO 4217 Definitions" do
      expect(Exchange::Money.new(23.232524, :tnd).to_s).to eq("TND 23.233")
      expect(Exchange::Money.new(23.23252423, :sar).to_s).to eq("SAR 23.23")
      expect(Exchange::Money.new(23.23252423, :clp).to_s).to eq("CLP 23")
      expect(Exchange::Money.new(23.2, :tnd).to_s).to eq("TND 23.200")
      expect(Exchange::Money.new(23.4, :sar).to_s).to eq("SAR 23.40")
      expect(Exchange::Money.new(23.0, :clp).to_s).to eq("CLP 23")
    end
    it "should render only the currency amount if the argument amount is passed" do
      expect(Exchange::Money.new(23.232524, :tnd).to_s(:amount)).to eq("23.233")
      expect(Exchange::Money.new(23.23252423, :sar).to_s(:amount)).to eq("23.23")
      expect(Exchange::Money.new(23.23252423, :clp).to_s(:amount)).to eq("23")
      expect(Exchange::Money.new(23.2, :tnd).to_s(:amount)).to eq("23.200")
      expect(Exchange::Money.new(23.4, :sar).to_s(:amount)).to eq("23.40")
      expect(Exchange::Money.new(23.0, :clp).to_s(:amount)).to eq("23")
    end
    it "should render only the currency amount and no separators if the argument amount is passed" do
      expect(Exchange::Money.new(2323.232524, :tnd).to_s(:plain)).to eq("2323.233")
      expect(Exchange::Money.new(2323.23252423, :sar).to_s(:plain)).to eq("2323.23")
      expect(Exchange::Money.new(2323.23252423, :clp).to_s(:plain)).to eq("2323")
      expect(Exchange::Money.new(23.2, :tnd).to_s(:plain)).to eq("23.200")
      expect(Exchange::Money.new(23.4, :sar).to_s(:plain)).to eq("23.40")
      expect(Exchange::Money.new(23.0, :clp).to_s(:plain)).to eq("23")
    end
    it "should render the currency with a symbol according to ISO 4217 Definitions" do
      expect(Exchange::Money.new(23.232524, :tnd).to_s(:symbol)).to eq("TND 23.233")
      expect(Exchange::Money.new(23.23252423, :sar).to_s(:symbol)).to eq("﷼23.23")
      expect(Exchange::Money.new(23.23252423, :clp).to_s(:symbol)).to eq("$23")
      expect(Exchange::Money.new(23.2, :tnd).to_s(:symbol)).to eq("TND 23.200")
      expect(Exchange::Money.new(23.4, :sar).to_s(:symbol)).to eq("﷼23.40")
      expect(Exchange::Money.new(23.0, :clp).to_s(:symbol)).to eq("$23")
    end
  end
  describe "methods via method missing" do
    it "should be able to convert via to_currency to other currencies" do
      mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'), 6)
      {:chf => 36.5, :usd => 40.0, :dkk => 225.12, :sek => 269.85, :nok => 232.06, :rub => 1205.24}.each do |currency, value|
        c = subject.to(currency)
        expect(c.value.round(2)).to eq(value)
        expect(c.currency).to eq(currency)
      end
    end
    it "should be able to convert via to_currency to other currencies and use historic data" do
      mock_api("http://openexchangerates.org/api/historical/2011-10-09.json?app_id=", fixture('api_responses/example_json_api.json'), 6)
      {:chf => 36.5, :usd => 40.0, :dkk => 225.12, :sek => 269.85, :nok => 232.06, :rub => 1205.24}.each do |currency, value|
        c = subject.to(currency, :at => Time.gm(2011,10,9))
        expect(c.value.round(2)).to eq(value)
        expect(c.currency).to eq(currency)
      end
    end
    it "should use the own time if defined as historic to convert" do
      mock_api("http://openexchangerates.org/api/historical/2011-01-01.json?app_id=", fixture('api_responses/example_json_api.json'), 2)
      expect(5.in(:eur, :at => Time.gm(2011,1,1)).to(:usd).value).to eq(5.in(:eur).to(:usd, :at => Time.gm(2011,1,1)).value)
    end
    it "should raise errors for currency conversions it does not have rates for" do
      expect { subject.to(:ssp) }.to raise_error(Exchange::NoRateError)
    end
    it "should pass on methods it does not understand to its number" do
      expect(subject.to_f).to eq(40)
      expect { subject.to_hell }.to raise_error(NoMethodError)
    end
  end
end
