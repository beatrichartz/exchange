# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::Cache::Configuration" do
  
  subject { Exchange::Cache::Configuration.instance }
  
  describe "attr_readers" do
    [:subclass, :expire, :host, :port, :path].each do |reader|
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
      subject.subclass = :no_cache
      
      expect(subject.subclass).to eq(Exchange::Cache::NoCache)
    end
  end
  
  describe "set" do
    before(:each) do
      @return = subject.set :subclass => :no_cache, :expire => :daily, :host => 'localhost', :port => 112211, :path => "PATH"
    end
    it "should set the options given" do
      expect(subject.subclass).to eq(Exchange::Cache::NoCache)
      expect(subject.expire).to eq(:daily)
      expect(subject.host).to eq('localhost')
      expect(subject.port).to eq(112211)
      expect(subject.path).to eq('PATH')
    end
    it "should return self" do
      expect(@return).to eq(subject)
    end
  end
  
  describe "setting and wiping the client" do
    context "with a wipeable client" do
      before(:each) do
        subject.subclass = :memcached
        subject.host = '127.0.0.1'
        subject.port = 11211
      end
      after(:each) do
        subject.subclass = :no_cache
      end
      it "should do so for the host" do
        expect(subject.subclass.client).not_to be_nil
        subject.subclass.client
        expect(subject.subclass.instance.instance_variable_get("@client")).not_to be_nil
        subject.host = 'new'
        expect(subject.subclass.instance.instance_variable_get("@client")).to be_nil
      end
      it "should do so for the port" do
        expect(subject.subclass.client).not_to be_nil
        subject.subclass.client
        expect(subject.subclass.instance.instance_variable_get("@client")).not_to be_nil
        subject.port = 112
        expect(subject.subclass.instance.instance_variable_get("@client")).to be_nil
      end
    end
    context "without a wipeable client" do
      before(:each) do
        subject.subclass = :memory
      end
      it "should not fail for the host" do
        subject.host = 'new'
        expect(subject.host).to eq('new')
      end
      it "should not fail for the port" do
        subject.port = 11
        expect(subject.port).to eq(11)
      end
    end
  end
  
  describe "reset" do
    before(:each) do
      subject.set :subclass => :no_cache, :expire => :daily, :host => 'localhost', :port => 112211, :path => "PATH"
    end
    it "should restore the defaults" do
      subject.reset
      expect(subject.subclass).to eq(Exchange::Cache::Memory)
      expect(subject.expire).to eq(:daily)
      expect(subject.host).to be_nil
      expect(subject.port).to be_nil
      expect(subject.path).to be_nil
    end
  end
  
end
