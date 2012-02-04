require 'spec_helper'

describe "Exchange::ExternalAPI::ECB" do
  before(:all) do
    Exchange::Configuration.cache = false
  end
  before(:each) do
    time = Time.gm(2012,2,3)
    Time.stub! :now => time
  end
  describe "updating rates" do
    subject { Exchange::ExternalAPI::ECB.new }
    before(:each) do
      mock_api("http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml", fixture('api_responses/example_ecb_xml_90d.xml'))
    end
    it "should call the api and yield a block with the result" do
      subject.update
      subject.base.should == 'EUR'
    end
    it "should set a unix timestamp from the api file" do
      subject.update
      subject.timestamp.should == 1328227200
    end
  end
  describe "conversion" do
    subject { Exchange::ExternalAPI::ECB.new }
    before(:each) do
      mock_api("http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml", fixture('api_responses/example_ecb_xml_90d.xml'))
    end
    it "should convert right" do
      subject.convert(80, 'eur', 'usd').should == 105.28
    end
    it "should convert negative numbers right" do
      subject.convert(-70, 'chf', 'usd').should == -76.45
    end
    it "should convert when given symbols" do
      subject.convert(70, :sek, :usd).should == 10.41
    end
  end
  describe "historic conversion" do
    subject { Exchange::ExternalAPI::ECB.new }
    before(:each) do
      mock_api("http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.xml", fixture('api_responses/example_ecb_xml_history.xml'))
    end
    it "should convert and be able to use history" do
      subject.convert(70, 'eur', 'usd', :at => Time.gm(2011,9,9)).should == 96.72
    end
    it "should convert negative numbers right" do
      subject.convert(-70, 'chf', 'usd', :at => Time.gm(2011,9,9)).should == -79.51
    end
    it "should convert when given symbols" do
      subject.convert(70, :sek, :usd, :at => Time.gm(2011,9,9)).should == 10.87
    end
  end
end