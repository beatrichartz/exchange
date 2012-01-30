require 'spec_helper'

describe "Exchange::ExternalAPI::CurrencyBot" do
  before(:all) do
    Exchange::Configuration.cache = false
  end
  describe "updating rates" do
    subject { Exchange::ExternalAPI::CurrencyBot.new }
    before(:each) do
      mock_api("https://raw.github.com/currencybot/open-exchange-rates/master/latest.json", fixture('api_responses/example_json_api.json'))
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
      mock_api("https://raw.github.com/currencybot/open-exchange-rates/master/latest.json", fixture('api_responses/example_json_api.json'))
    end
    it "should convert right" do
      subject.convert(80, 'eur', 'usd').should == 105.76
    end
    it "should convert negative numbers right" do
      subject.convert(-70, 'chf', 'usd').should == -76.71
    end
    it "should convert when given symbols" do
      subject.convert(70, :sek, :usd).should == 10.38
    end
  end
end