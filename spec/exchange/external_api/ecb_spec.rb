# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::ExternalAPI::Ecb" do
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
  before(:each) do
    time = Time.gm(2012,2,3)
    Time.stub! :now => time
  end
  describe "updating rates" do
    subject { Exchange::ExternalAPI::Ecb.new }
    before(:each) do
      mock_api("http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml", fixture('api_responses/example_ecb_xml_90d.xml'))
    end
    it "should call the api and yield a block with the result" do
      subject.update
      subject.base.should == :eur
    end
    it "should set a unix timestamp from the api file" do
      subject.update
      subject.timestamp.should == 1328227200
    end
  end
  describe "conversion" do
    subject { Exchange::ExternalAPI::Ecb.new }
    before(:each) do
      mock_api("http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml", fixture('api_responses/example_ecb_xml_90d.xml'))
    end
    it "should convert right" do
      subject.convert(80, :eur, :usd).round(2).should == 105.28
    end
    it "should convert negative numbers right" do
      subject.convert(-70, :chf, :usd).round(2).should == BigDecimal.new("-76.45")
    end
    it "should convert when given symbols" do
      subject.convert(70, :sek, :usd).round(2).should == 10.41
    end
  end
  describe "historic conversion" do
    subject { Exchange::ExternalAPI::Ecb.new }
    before(:each) do
      mock_api("http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.xml", fixture('api_responses/example_ecb_xml_history.xml'))
    end
    it "should convert and be able to use history" do
      subject.convert(70, :eur, :usd, :at => Time.gm(2011,9,9)).round(2).should == 91.66
    end
    it "should convert negative numbers right" do
      subject.convert(-70, :chf, :usd, :at => Time.gm(2011,9,9)).round(2).should == BigDecimal.new("-76.08")
    end
    it "should convert when given symbols" do
      subject.convert(70, :sek, :usd, :at => Time.gm(2011,9,9)).round(2).should == 10.35
    end
  end
end
