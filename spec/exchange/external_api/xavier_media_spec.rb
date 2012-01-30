require 'spec_helper'

describe "Exchange::ExternalAPI::XavierMedia" do
  before(:all) do
    Exchange::Configuration.cache = false
  end
  describe "updating rates" do
    subject { Exchange::ExternalAPI::XavierMedia.new }
    before(:each) do
      mock_api("http://api.finance.xaviermedia.com/api/#{Time.now.strftime("%Y/%m/%d")}.xml", fixture('api_responses/example_xml_api.xml'))
    end
    it "should call the api and yield a block with the result" do
      subject.update
      subject.base.should == 'EUR'
    end
    it "should set a unix timestamp from the api file" do
      subject.update
      subject.timestamp.should == 1322697600
    end
  end
  describe "conversion" do
    subject { Exchange::ExternalAPI::XavierMedia.new }
    before(:each) do
      mock_api("http://api.finance.xaviermedia.com/api/#{Time.now.strftime("%Y/%m/%d")}.xml", fixture('api_responses/example_xml_api.xml'))
    end
    it "should convert right" do
      subject.convert(80, 'eur', 'usd').should == 107.94
    end
    it "should convert negative numbers right" do
      subject.convert(-70, 'chf', 'usd').should == -77.01
    end
    it "should convert when given symbols" do
      subject.convert(70, :sek, :usd).should == 10.35
    end
  end
end