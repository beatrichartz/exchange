# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::Conversability" do
  before(:all) do
    Exchange.configuration = Exchange::Configuration.new { |c| c.cache = { :subclass => :no_cache } }
  end
  before(:each) do
    @time = Time.gm(2012,8,27)
    Time.stub! :now => @time
  end
  after(:all) do
    Exchange.configuration.reset
  end
  context "with a fixnum" do
    it "should allow to convert to a currency" do
      3.in(:eur).should be_kind_of Exchange::Money
      3.in(:eur).value.should == 3
    end
    it "should allow to convert to a curreny with a negative number" do
      -3.in(:eur).should be_kind_of Exchange::Money
      -3.in(:eur).value.should == -3
    end
    it "should allow to do full conversions" do
      mock_api("http://api.finance.xaviermedia.com/api/2012/08/27.xml", fixture('api_responses/example_xml_api.xml'), 3)
      3.in(:eur).to(:chf).should be_kind_of Exchange::Money
      3.in(:eur).to(:chf).value.round(2).should == 3.68
      3.in(:eur).to(:chf).currency.should == :chf
    end
    it "should allow to do full conversions with negative numbers" do
      mock_api("http://api.finance.xaviermedia.com/api/2012/08/27.xml", fixture('api_responses/example_xml_api.xml'), 3)
      -3.in(:eur).to(:chf).should be_kind_of Exchange::Money
      -3.in(:eur).to(:chf).value.round(2).should == -3.68
      -3.in(:eur).to(:chf).currency.should == :chf
    end
    it "should allow to define a historic time in which the currency should be interpreted" do
      3.in(:chf, :at => Time.gm(2010,1,1)).time.yday.should == 1
      3.in(:chf, :at => Time.gm(2010,1,1)).time.year.should == 2010
      3.in(:chf, :at => '2010-01-01').time.year.should == 2010
    end
    it "should raise a no currency error if the currency does not exist" do
      lambda { 35.in(:zzz) }.should raise_error(Exchange::NoCurrencyError, "zzz is not a currency nor a country code matchable to a currency")
    end
  end
  context "with a float" do
    it "should allow to convert to a currency" do
      3.25.in(:eur).should be_kind_of Exchange::Money
      3.25.in(:eur).value.round(2).should == 3.25
    end
    it "should allow to convert to a curreny with a negative number" do
      -3.25.in(:eur).should be_kind_of Exchange::Money
      -3.25.in(:eur).value.round(2).should == -3.25
    end
    it "should allow to do full conversions" do
      mock_api("http://api.finance.xaviermedia.com/api/2012/08/27.xml", fixture('api_responses/example_xml_api.xml'), 3)
      3.25.in(:eur).to(:chf).should be_kind_of Exchange::Money
      3.25.in(:eur).to(:chf).value.round(2).should == 3.99
      3.25.in(:eur).to(:chf).currency.should == :chf
    end
    it "should allow to do full conversions with negative numbers" do
      mock_api("http://api.finance.xaviermedia.com/api/2012/08/27.xml", fixture('api_responses/example_xml_api.xml'), 3)
      -3.25.in(:eur).to(:chf).should be_kind_of Exchange::Money
      -3.25.in(:eur).to(:chf).value.round(2).should == -3.99
      -3.25.in(:eur).to(:chf).currency.should == :chf
    end
    it "should allow to define a historic time in which the currency should be interpreted" do
      3.25.in(:chf, :at => Time.gm(2010,1,1)).time.yday.should == 1
      3.25.in(:chf, :at => Time.gm(2010,1,1)).time.year.should == 2010
      3.25.in(:chf, :at => '2010-01-01').time.year.should == 2010
    end
    it "should raise a no currency error if the currency does not exist" do
      lambda { 35.23.in(:zzz) }.should raise_error(Exchange::NoCurrencyError, "zzz is not a currency nor a country code matchable to a currency")
    end
  end
  context "with a big decimal" do
    it "should allow to convert to a currency" do
      BigDecimal.new("3.25").in(:eur).should be_kind_of Exchange::Money
      BigDecimal.new("3.25").in(:eur).value.round(2).should == 3.25
    end
    it "should allow to convert to a curreny with a negative number" do
      BigDecimal.new("-3.25").in(:eur).should be_kind_of Exchange::Money
      BigDecimal.new("-3.25").in(:eur).value.round(2).should == -3.25
    end
    it "should allow to do full conversions" do
      mock_api("http://api.finance.xaviermedia.com/api/2012/08/27.xml", fixture('api_responses/example_xml_api.xml'), 3)
      BigDecimal.new("3.25").in(:eur).to(:chf).should be_kind_of Exchange::Money
      BigDecimal.new("3.25").in(:eur).to(:chf).value.round(2).should == 3.99
      BigDecimal.new("3.25").in(:eur).to(:chf).currency.should == :chf
    end
    it "should allow to do full conversions with negative numbers" do
      mock_api("http://api.finance.xaviermedia.com/api/2012/08/27.xml", fixture('api_responses/example_xml_api.xml'), 3)
      BigDecimal.new("-3.25").in(:eur).to(:chf).should be_kind_of Exchange::Money
      BigDecimal.new("-3.25").in(:eur).to(:chf).value.round(2).should == -3.99
      BigDecimal.new("-3.25").in(:eur).to(:chf).currency.should == :chf
    end
    it "should allow to define a historic time in which the currency should be interpreted" do
      BigDecimal.new("3.25").in(:chf, :at => Time.gm(2010,1,1)).time.yday.should == 1
      BigDecimal.new("3.25").in(:chf, :at => Time.gm(2010,1,1)).time.year.should == 2010
      BigDecimal.new("3.25").in(:chf, :at => '2010-01-01').time.year.should == 2010
    end
    it "should raise a no currency error if the currency does not exist" do
      lambda { BigDecimal.new("3.25").in(:zzz) }.should raise_error(Exchange::NoCurrencyError, "zzz is not a currency nor a country code matchable to a currency")
    end
  end
end
