# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::ExternalAPI::Configuration" do
  
  subject { Exchange::ExternalAPI::Configuration.instance }
  
  describe "attr_readers" do
    [:subclass, :retries, :app_id].each do |reader|
      it "should respond to #{reader}" do
        subject.should be_respond_to(reader)
      end
      it "should respond to #{reader}=" do
        subject.should be_respond_to(:"#{reader}=")
      end
    end
  end
  
  describe "subclass constantize" do
    it "should automatically constantize the subclass" do
      subject.subclass = :xavier_media
      
      subject.subclass.should == Exchange::ExternalAPI::XavierMedia
    end
  end
  
  describe "fallback constantize" do
    it "should automatically constantize a single fallback and wrap it in an array" do
      subject.fallback = :xavier_media
      
      subject.fallback.should == [Exchange::ExternalAPI::XavierMedia]
    end
    it "should automatically constantize the fallbacks" do
      subject.fallback = [:xavier_media, :random]
      
      subject.fallback.should == [Exchange::ExternalAPI::XavierMedia, Exchange::ExternalAPI::Random]
    end
  end
  
  describe "set" do
    before(:each) do
      @return = subject.set :subclass => :xavier_media, :retries => 55, :app_id => "KEY", :fallback => [:random, :ecb]
    end
    it "should set the options given" do
      subject.subclass.should == Exchange::ExternalAPI::XavierMedia
      subject.retries.should == 55
      subject.app_id.should == 'KEY'
      subject.fallback.should == [Exchange::ExternalAPI::Random, Exchange::ExternalAPI::Ecb]
    end
    it "should return self" do
      @return.should == subject
    end
  end
  
  describe "reset" do
    before(:each) do
      subject.set :subclass => :xavier_media, :retries => 55, :app_id => "KEY"
    end
    it "should restore the defaults" do
      subject.reset
      subject.subclass.should == Exchange::ExternalAPI::XavierMedia
      subject.retries.should == 7
      subject.app_id.should be_nil
      subject.fallback.should == [Exchange::ExternalAPI::Ecb]
    end
  end
  
end
