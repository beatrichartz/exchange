# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::ExternalAPI::Configuration" do
  
  subject { Exchange::ExternalAPI::Configuration.instance }
  
  describe "attr_readers" do
    [:subclass, :retries, :app_id].each do |reader|
      it "should respond to #{reader}" do
        expect(subject).to be_respond_to(reader)
      end
      it "should respond to #{reader}=" do
        expect(subject).to be_respond_to(:"#{reader}=")
      end
    end
  end
  
  describe "subclass constantize" do
    it "should automatically constantize the subclass" do
      subject.subclass = :xavier_media
      
      expect(subject.subclass).to eq(Exchange::ExternalAPI::XavierMedia)
    end
  end
  
  describe "fallback constantize" do
    it "should automatically constantize a single fallback and wrap it in an array" do
      subject.fallback = :xavier_media
      
      expect(subject.fallback).to eq([Exchange::ExternalAPI::XavierMedia])
    end
    it "should automatically constantize the fallbacks" do
      subject.fallback = [:xavier_media, :random]
      
      expect(subject.fallback).to eq([Exchange::ExternalAPI::XavierMedia, Exchange::ExternalAPI::Random])
    end
  end
  
  describe "set" do
    before(:each) do
      @return = subject.set :subclass => :xavier_media, :retries => 55, :app_id => "KEY", :fallback => [:random, :ecb]
    end
    it "should set the options given" do
      expect(subject.subclass).to eq(Exchange::ExternalAPI::XavierMedia)
      expect(subject.retries).to eq(55)
      expect(subject.app_id).to eq('KEY')
      expect(subject.fallback).to eq([Exchange::ExternalAPI::Random, Exchange::ExternalAPI::Ecb])
    end
    it "should return self" do
      expect(@return).to eq(subject)
    end
  end
  
  describe "reset" do
    before(:each) do
      subject.set :subclass => :xavier_media, :retries => 55, :app_id => "KEY"
    end
    it "should restore the defaults" do
      subject.reset
      expect(subject.subclass).to eq(Exchange::ExternalAPI::XavierMedia)
      expect(subject.retries).to eq(7)
      expect(subject.app_id).to be_nil
      expect(subject.fallback).to eq([Exchange::ExternalAPI::Ecb])
    end
  end
  
end
