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
    subject.number.should == 40
    subject.currency.should == :usd
  end
  describe "convert_to" do
    it "should be able to convert itself to other currencies" do
      mock_api("https://raw.github.com/currencybot/open-exchange-rates/master/latest.json", fixture('api_responses/example_json_api.json'), 3)
      subject.convert_to(:chf).number.should == 36.5
      subject.convert_to(:chf).currency.should == :chf
      subject.convert_to(:chf).should be_kind_of Exchange::Currency
    end
  end
  describe "operations" do
    describe "+ other" do
      it "should be able to add an integer" do
        (subject + 40).number.should == 80
      end
      it "should be able to add a float" do
        (subject + 40.5).number.should == 80.5
      end
      it "should be able to add another currency value" do
        mock_api("https://raw.github.com/currencybot/open-exchange-rates/master/latest.json", fixture('api_responses/example_json_api.json'), 2)
        (subject + Exchange::Currency.new(30, :chf)).number.should == 72.87
        (subject + Exchange::Currency.new(30, :sek)).currency.should == :usd
      end
      it "should raise when currencies get mixed and the configuration does not allow it" do
        Exchange::Configuration.allow_mixed_operations = false
        lambda { subject + Exchange::Currency.new(30, :chf) }.should raise_error(Exchange::CurrencyMixError)
        Exchange::Configuration.allow_mixed_operations = true
      end
      it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
        Exchange::Configuration.allow_mixed_operations = false
        mock_api("https://raw.github.com/currencybot/open-exchange-rates/master/latest.json", fixture('api_responses/example_json_api.json'), 2)
        lambda { subject + Exchange::Currency.new(30, :usd) }.should_not raise_error
        Exchange::Configuration.allow_mixed_operations = true
      end
    end
    describe "- other" do
      it "should be able to subtract an integer" do
        (subject + 40).number.should == 80
      end
      it "should be able to subtract a float" do
        (subject + 40.5).number.should == 80.5
      end
      it "should be able to subtract another currency value" do
        mock_api("https://raw.github.com/currencybot/open-exchange-rates/master/latest.json", fixture('api_responses/example_json_api.json'), 2)
        (subject + Exchange::Currency.new(10, :chf)).number.should == 50.96
        (subject + Exchange::Currency.new(23.3, :eur)).currency.should == :usd
      end
      it "should raise when currencies get mixed and the configuration does not allow it" do
        Exchange::Configuration.allow_mixed_operations = false
        lambda { subject - Exchange::Currency.new(30, :chf) }.should raise_error(Exchange::CurrencyMixError)
        Exchange::Configuration.allow_mixed_operations = true
      end
      it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
        Exchange::Configuration.allow_mixed_operations = false
        mock_api("https://raw.github.com/currencybot/open-exchange-rates/master/latest.json", fixture('api_responses/example_json_api.json'), 2)
        lambda { subject - Exchange::Currency.new(30, :usd) }.should_not raise_error
        Exchange::Configuration.allow_mixed_operations = true
      end
    end
    describe "* other" do
      it "should be able to multiply by an integer" do
        (subject * 40).number.should == 1600
      end
      it "should be able to multiply a float" do
        (subject * 40.5).number.should == 1620
      end
      it "should be able to multiply by another currency value" do
        mock_api("https://raw.github.com/currencybot/open-exchange-rates/master/latest.json", fixture('api_responses/example_json_api.json'), 2)
        (((subject * Exchange::Currency.new(10, :chf)).number * 10000.0).round.to_f / 10000.0).should == 438.4
        (subject * Exchange::Currency.new(23.3, :eur)).currency.should == :usd
      end
      it "should raise when currencies get mixed and the configuration does not allow it" do
        Exchange::Configuration.allow_mixed_operations = false
        lambda { subject * Exchange::Currency.new(30, :chf) }.should raise_error(Exchange::CurrencyMixError)
        Exchange::Configuration.allow_mixed_operations = true
      end
      it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
        Exchange::Configuration.allow_mixed_operations = false
        mock_api("https://raw.github.com/currencybot/open-exchange-rates/master/latest.json", fixture('api_responses/example_json_api.json'), 2)
        lambda { subject * Exchange::Currency.new(30, :usd) }.should_not raise_error
        Exchange::Configuration.allow_mixed_operations = true
      end
    end
    describe "/ other" do
      it "should be able to multiply by an integer" do
        (subject / 40).number.should == 1
      end
      it "should be able to multiply a float" do
        (((subject / 40.5).number * 10000.0).round.to_f / 10000.0).should == 0.9877
      end
      it "should be able to multiply by another currency value" do
        mock_api("https://raw.github.com/currencybot/open-exchange-rates/master/latest.json", fixture('api_responses/example_json_api.json'), 2)
        (((subject / Exchange::Currency.new(10, :chf)).number * 10000.0).round.to_f / 10000.0).should == 3.6496
        (subject / Exchange::Currency.new(23.3, :eur)).currency.should == :usd
      end
      it "should raise when currencies get mixed and the configuration does not allow it" do
        Exchange::Configuration.allow_mixed_operations = false
        lambda { subject / Exchange::Currency.new(30, :chf) }.should raise_error(Exchange::CurrencyMixError)
        Exchange::Configuration.allow_mixed_operations = true
      end
      it "should not raise when currencies get mixed and the configuration does not allow if the other currency is the same" do
        Exchange::Configuration.allow_mixed_operations = false
        mock_api("https://raw.github.com/currencybot/open-exchange-rates/master/latest.json", fixture('api_responses/example_json_api.json'), 2)
        lambda { subject / Exchange::Currency.new(30, :usd) }.should_not raise_error
        Exchange::Configuration.allow_mixed_operations = true
      end
    end
    describe "round" do
      subject { Exchange::Currency.new(40.123, :usd) }
      it "should apply it to its number" do
        subject.round.number.should == 40
        subject.round.currency.should == :usd
        subject.round.should be_kind_of Exchange::Currency
      end
    end
    describe "ceil" do
      subject { Exchange::Currency.new(40.123, :usd) }
      it "should apply it to its number" do
        subject.ceil.number.should == 41
        subject.ceil.currency.should == :usd
        subject.ceil.should be_kind_of Exchange::Currency
      end
    end
    describe "floor" do
      subject { Exchange::Currency.new(40.723, :usd) }
      it "should apply it to its number" do
        subject.floor.number.should == 40
        subject.floor.currency.should == :usd
        subject.floor.should be_kind_of Exchange::Currency
      end
    end
  end
  describe "methods via method missing" do
    it "should be able to convert via to_currency to other currencies" do
      mock_api("https://raw.github.com/currencybot/open-exchange-rates/master/latest.json", fixture('api_responses/example_json_api.json'), 6)
      {'chf' => 36.5, 'usd' => 40.0, 'dkk' => 225.12, 'sek' => 269.85, 'nok' => 232.06, 'rub' => 1205.24}.each do |currency, value|
        c = subject.send(:"to_#{currency}")
        c.number.should == value
        c.currency.should == currency
      end
    end
    it "should be able to convert via to_currency to other currencies and use historic data" do
      mock_api("https://raw.github.com/currencybot/open-exchange-rates/master/historical/2011-10-09.json", fixture('api_responses/example_json_api.json'), 6)
      {'chf' => 36.5, 'usd' => 40.0, 'dkk' => 225.12, 'sek' => 269.85, 'nok' => 232.06, 'rub' => 1205.24}.each do |currency, value|
        c = subject.send(:"to_#{currency}", :at => Time.gm(2011,10,9))
        c.number.should == value
        c.currency.should == currency
      end
    end
    it "should pass on methods it does not understand to its number" do
      subject.to_f.should == 40
      lambda { subject.to_hell }.should raise_error(NoMethodError)
    end
  end
end