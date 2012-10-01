require 'spec_helper'

describe "Exchange::ExternalAPI::CurrencyBot" do
  before(:all) do
    Exchange.configuration = Exchange::Configuration.new{|c|
      c.cache = {
        :subclass => :no_cache
      }
    }
  end
  describe "updating rates" do
    subject { Exchange::ExternalAPI::CurrencyBot.new }
    before(:each) do
      mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'))
    end
    it "should call the api and yield a block with the result" do
      subject.update
      subject.base.should == 'USD'
    end
    it "should set a unix timestamp from the api file" do
      subject.update
      subject.timestamp.should == 1327748496
    end
  end
  describe "conversion" do
    subject { Exchange::ExternalAPI::CurrencyBot.new }
    before(:each) do
      mock_api("http://openexchangerates.org/api/latest.json?app_id=", fixture('api_responses/example_json_api.json'))
    end
    it "should convert right" do
      subject.convert(78, 'eur', 'usd').round(2).should == BigDecimal.new("103.12")
    end
    it "should convert negative numbers right" do
      subject.convert(-70, 'chf', 'usd').round(2).should == BigDecimal.new("-76.71")
    end
    it "should convert when given symbols" do
      subject.convert(70, :sek, :usd).round(2).should == 10.38
    end
  end
  describe "historic conversion" do
    subject { Exchange::ExternalAPI::CurrencyBot.new }
    it "should convert and be able to use history" do
      mock_api("http://openexchangerates.org/api/historical/2011-09-09.json?app_id=", fixture('api_responses/example_json_api.json'))
      subject.convert(72, 'eur', 'usd', :at => Time.gm(2011,9,9)).round(2).should == BigDecimal.new("95.19")
    end
    it "should convert negative numbers right" do
      mock_api("http://openexchangerates.org/api/historical/2011-09-09.json?app_id=", fixture('api_responses/example_json_api.json'))
      subject.convert(-70, 'chf', 'usd', :at => Time.gm(2011,9,9)).round(2).should == BigDecimal.new("-76.71")
    end
    it "should convert when given symbols" do
      mock_api("http://openexchangerates.org/api/historical/2011-09-09.json?app_id=", fixture('api_responses/example_json_api.json'))
      subject.convert(70, :sek, :usd, :at => Time.gm(2011,9,9)).round(2).should == 10.38
    end
    it "should convert right when the year is the same, but the yearday is not" do
      mock_api("http://openexchangerates.org/api/historical/#{Time.now.year}-0#{Time.now.month > 9 ? Time.now.month - 1 : Time.now.month + 1}-01.json?app_id=", fixture('api_responses/example_json_api.json'))
      subject.convert(70, :sek, :usd, :at => Time.gm(Time.now.year,Time.now.month > 9 ? Time.now.month - 1 : Time.now.month + 1,1)).round(2).should == 10.38
    end
    it "should convert right when the yearday is the same, but the year is not" do
      mock_api("http://openexchangerates.org/api/historical/#{Time.now.year-1}-03-01.json?app_id=", fixture('api_responses/example_json_api.json'))
      subject.convert(70, :sek, :usd, :at => Time.gm(Time.now.year - 1,3,1)).round(2).should == 10.38
    end
  end
end