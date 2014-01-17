# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::Typecasting" do
  
  class Manager
    
    attr_accessor :currency
    
    def initialize *args
      self.currency = :eur
      
      super
    end
    
  end
  
  class MyClass
    extend Exchange::Typecasting
    
    attr_accessor :price, :manager
    
    def initialize *args
      self.manager = Manager.new
      
      super
    end
    
    def created_at
      Time.gm(2012,8,8)
    end
    
    money :price, :at => :created_at, :currency => lambda { |s| s.manager.currency }
    
  end
  
  describe "get" do
    subject { MyClass.new }
    before(:each) do
      subject.price = 0.77
    end
    it "should instantiate the attribute as a currency" do
      subject.price.should be_instance_of(Exchange::Money)
    end
    it "should instantiate the currency with the right currency" do
      subject.price.currency.should == :eur
    end
    it "should instantiate with the right value" do
      subject.price.value.should == 0.77
    end
    it "should instantiate the currency with the right time" do
      subject.price.time.should == Time.gm(2012,8,8)
    end
    context "when changing the currency value" do
      before(:each) do
        subject.manager.currency = :usd
      end
      it "should instantiate with the new currency" do
        subject.price.currency.should == :usd
      end
      it "should leave the value unchanged" do
        subject.price.value.should == 0.77
      end
    end
    context "when the currency is nil" do
      before(:each) do
        subject.manager.currency = nil
      end
      it "should raise an error" do
        lambda { subject.price }.should raise_error(Exchange::NoCurrencyError, "No currency is given for typecasting price. Make sure a currency is present")
      end
    end
    context "when the value is nil" do
      before(:each) do
        subject.price = nil
        subject.manager.currency = :usd
      end
      it "should return nil" do
        subject.price.should be_nil
      end
    end
  end
  
  describe "set" do
    subject { MyClass.new }
    before(:each) do
      subject.price = 0.77
    end
    it "should set the value if the given value is numeric" do
      subject.price = 0.83
      subject.price.should == 0.83.in(:eur)
    end
    it "should not convert the value if the given value is in the same currency" do
      subject.price = 0.83.in(:eur)
      subject.price.should == 0.83.in(:eur)
    end
    it "should convert the value if the given value is in another currency" do
      mock_api("http://api.finance.xaviermedia.com/api/#{Time.now.strftime("%Y/%m/%d")}.xml", fixture('api_responses/example_xml_api.xml'))
      subject.price = 0.83.in(:usd)
      subject.price.should == 0.62.in(:eur)
    end
    context "when the preset value is nil" do
      before(:each) do
        subject.price = nil
        subject.manager.currency = :eur
      end
      it "should set the value if the given value is numeric" do
        subject.price = 0.83
        subject.price.should == 0.83.in(:eur)
      end
      it "should not convert the value if the given value is in the same currency" do
        subject.price = 0.83.in(:eur)
        subject.price.should == 0.83.in(:eur)
      end
      it "should convert the value if the given value is in another currency" do
        mock_api("http://api.finance.xaviermedia.com/api/#{Time.now.strftime("%Y/%m/%d")}.xml", fixture('api_responses/example_xml_api.xml'))
        subject.price = 0.83.in(:usd)
        subject.price.should == 0.62.in(:eur)
      end
    end
  end
  
end
