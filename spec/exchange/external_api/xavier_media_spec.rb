require 'spec_helper'

describe "Exchange::ExternalAPI::XavierMedia" do
  before(:all) do
    Exchange.configuration = Exchange::Configuration.new { |c|
      c.cache = {
        :subclass => :no_cache
      }
    }
  end
  after(:all) do
    Exchange.configuration.reset
  end
  describe "updating rates" do
    subject { Exchange::ExternalAPI::XavierMedia.new }
    before(:each) do
      mock_api("http://api.finance.xaviermedia.com/api/#{Time.now.strftime("%Y/%m/%d")}.xml", fixture('api_responses/example_xml_api.xml'))
    end
    it "should call the api and yield a block with the result" do
      subject.update
      subject.base.should == :eur
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
      subject.convert(80, :eur, :usd).round(2).should == 107.94
    end
    it "should convert negative numbers right" do
      subject.convert(-70, :chf, :usd).round(2).should == BigDecimal.new("-77.01")
    end
    it "should convert when given symbols" do
      subject.convert(70, :sek, :usd).round(2).should == 10.35
    end
  end
  describe "historic conversion" do
    subject { Exchange::ExternalAPI::XavierMedia.new }
    it "should convert and be able to use history" do
      mock_api("http://api.finance.xaviermedia.com/api/2011/09/09.xml", fixture('api_responses/example_xml_api.xml'))
      subject.convert(70, :eur, :usd, :at => Time.gm(2011,9,9)).round(2).should == 94.44
    end
    it "should convert negative numbers right" do
      mock_api("http://api.finance.xaviermedia.com/api/2011/09/09.xml", fixture('api_responses/example_xml_api.xml'))
      subject.convert(-70, :chf, :usd, :at => Time.gm(2011,9,9)).round(2).should == BigDecimal.new("-77.01")
    end
    it "should convert when given symbols" do
      mock_api("http://api.finance.xaviermedia.com/api/2011/09/09.xml", fixture('api_responses/example_xml_api.xml'))
      subject.convert(70, :sek, :usd, :at => Time.gm(2011,9,9)).round(2).should == 10.35
    end
    it "should convert right when the year is the same, but the yearday is not" do
      mock_api("http://api.finance.xaviermedia.com/api/#{Time.now.year}/0#{Time.now.month > 9 ? Time.now.month - 1 : Time.now.month + 1}/01.xml", fixture('api_responses/example_xml_api.xml'))
      subject.convert(70, :sek, :usd, :at => Time.gm(Time.now.year,Time.now.month > 9 ? Time.now.month - 1 : Time.now.month + 1,1)).round(2).should == 10.35
    end
    it "should convert right when the yearday is the same, but the year is not" do
      mock_api("http://api.finance.xaviermedia.com/api/#{Time.now.year-1}/03/01.xml", fixture('api_responses/example_xml_api.xml'))
      subject.convert(70, :sek, :usd, :at => Time.gm(Time.now.year - 1,3,1)).round(2).should == 10.35
    end
  end
end