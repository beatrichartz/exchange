# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::Cache::Memory" do
  subject { Exchange::Cache::Memory.instance }
  before(:each) do
    Exchange.configuration = Exchange::Configuration.new { |c|
      c.cache = { :subclass => :memory }
    }
  end
  after(:each) do
    Exchange.configuration.reset
  end
  describe "instance_variable_name" do
    context "with a class" do
      before(:each) do
        @time = Time.gm(2012,10,10,12)
        Time.stub :now => @time
      end
      it "should yield a valid instance variable name" do
        subject.send(:instance_variable_name, Exchange::ExternalAPI::Ecb, {}).should == '@exchange_externalapi_ecb_2012_284_2012_284'
      end
    end
  end
  describe "clean_out_cache" do
    before(:each) do
      @time = Time.gm(2012,10,10,12)
      Time.stub :now => @time
      subject.instance_variable_set '@exchange_externalapi_someapi_2011_284_2011_284_chfeur', 'Expired'
      subject.instance_variable_set '@exchange_externalapi_someapi_2010_284_2012_284_chfeur', 'Valid1'
      subject.instance_variable_set '@exchange_externalapi_ecb_2012_283_2011_283', 'Expired'
      subject.instance_variable_set '@exchange_externalapi_ecb_2012_282_2012_284_chfusd', 'Valid2'
      subject.instance_variable_set '@exchange_externalapi_currency_2012_284_11_2012_284_11', 'Expired'
      subject.instance_variable_set '@exchange_externalapi_something_2012_284_12_2012_284_12', 'Valid3'
      subject.instance_variable_set '@exchange_externalapi_something_2009_284_12_2012_284_12', 'Valid4'
      subject.instance_variable_set '@exchange_externalapi_open_exchange_rates_2010_280_8_2012_284_8', 'Expired'
      subject.instance_variable_set '@exchange_externalapi_xaviermedia_2012_84_12_2012_123_8', 'Expired'
    end
    it "should unset all expired instance variables" do
      subject.send(:clean!)
      ivars = subject.instance_variables.reject{|i| i.to_s == "@helper" }.map{|i| subject.instance_variable_get(i) }.compact.sort_by(&:to_s)
      ivars.select{|i| i.is_a?(String) }.should be_eql(%W(Valid1 Valid2 Valid3 Valid4))
    end
  end
  describe "cached" do
    it "should raise an error if no block was given" do
      lambda { subject.cached('API_CLASS') }.should raise_error(Exchange::Cache::CachingWithoutBlockError)
    end
    context "when a cached result exists" do
      context "when loading json" do
        before(:each) do
          subject.should_receive(:instance_variable_name).with('API::CLASS', {}).and_return('@KEY')
          subject.should_receive(:instance_variable_get).with('@KEY').and_return('something')
        end
        it "should return the loaded result" do
          subject.cached('API::CLASS') { 'something' }.should == 'something'
        end
      end
      context "when loading plain" do
        before(:each) do
          subject.should_receive(:instance_variable_name).with('API::CLASS', {:plain => true}).and_return('@KEY')
        end
        it "should return a String result in the right format" do
          subject.should_receive(:instance_variable_get).with('@KEY').and_return "0.122E3"
          subject.cached('API::CLASS', :plain => true) { 'something' }.should == "0.122E3".cachify
        end
        it "should return a Hash result in the right format" do
          subject.should_receive(:instance_variable_get).with('@KEY').and_return({'RESULT' => 'YAY'})
          subject.cached('API::CLASS', :plain => true) { 'something' }.should == {'RESULT' => 'YAY'}.cachify
        end
      end
    end
    context "when no cached result exists" do
      context "when returning nil" do
        before(:each) do
          subject.should_receive(:instance_variable_name).with('API::CLASS', {}).once.and_return('@KEY')
          subject.should_receive(:instance_variable_get).with('@KEY').and_return(nil)
        end
        context "with daily cache" do
          it "should call the block and set and return the result" do
            subject.should_receive(:instance_variable_set).with('@KEY', {'RESULT' => 'YAY'}).once
            subject.cached('API::CLASS') { {'RESULT' => 'YAY'} }.should == {'RESULT' => 'YAY'}
          end
        end
        context "with hourly cache" do
          before(:each) do
            Exchange.configuration.cache.expire = :hourly
          end
          after(:each) do
            Exchange.configuration.cache.expire = :daily
          end
          it "should call the block and set and return the result" do
            subject.should_receive(:instance_variable_set).with('@KEY', {'RESULT' => 'YAY'}).once
            subject.cached('API::CLASS') { {'RESULT' => 'YAY'} }.should == {'RESULT' => 'YAY'}
          end
        end
      end
      context "when returning an empty string" do
        before(:each) do
          subject.should_receive(:instance_variable_name).with('API::CLASS', {}).once.and_return('@KEY')
          subject.should_receive(:instance_variable_get).with('@KEY').and_return('')
        end
        context "with daily cache" do
          it "should call the block and set and return the result" do
            subject.should_receive(:instance_variable_set).with('@KEY', {'RESULT' => 'YAY'}).once
            subject.cached('API::CLASS') { {'RESULT' => 'YAY'} }.should == {'RESULT' => 'YAY'}
          end
        end
        context "with hourly cache" do
          before(:each) do
            Exchange.configuration.cache.expire = :hourly
          end
          after(:each) do
            Exchange.configuration.cache.expire = :daily
          end
          it "should call the block and set and return the result" do
            subject.should_receive(:instance_variable_set).with('@KEY', {'RESULT' => 'YAY'}).once
            subject.cached('API::CLASS') { {'RESULT' => 'YAY'} }.should == {'RESULT' => 'YAY'}
          end
        end
      end
    end
  end
end
