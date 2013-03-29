# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::Cache::Configuration" do
  
  subject { Exchange::Cache::Configuration.instance }
  
  describe "attr_readers" do
    [:subclass, :expire, :host, :port, :path].each do |reader|
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
      subject.subclass = :no_cache
      
      subject.subclass.should == Exchange::Cache::NoCache
    end
  end
  
  describe "set" do
    before(:each) do
      @return = subject.set :subclass => :no_cache, :expire => :daily, :host => 'localhost', :port => 112211, :path => "PATH"
    end
    it "should set the options given" do
      subject.subclass.should == Exchange::Cache::NoCache
      subject.expire.should == :daily
      subject.host.should == 'localhost'
      subject.port.should == 112211
      subject.path.should == 'PATH'
    end
    it "should return self" do
      @return.should == subject
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
        subject.subclass.client.should_not be_nil
        subject.subclass.client
        subject.subclass.instance.instance_variable_get("@client").should_not be_nil
        subject.host = 'new'
        subject.subclass.instance.instance_variable_get("@client").should be_nil
      end
      it "should do so for the port" do
        subject.subclass.client.should_not be_nil
        subject.subclass.client
        subject.subclass.instance.instance_variable_get("@client").should_not be_nil
        subject.port = 112
        subject.subclass.instance.instance_variable_get("@client").should be_nil
      end
    end
    context "without a wipeable client" do
      before(:each) do
        subject.subclass = :memory
      end
      it "should not fail for the host" do
        subject.host = 'new'
        subject.host.should == 'new'
      end
      it "should not fail for the port" do
        subject.port = 11
        subject.port.should == 11
      end
    end
  end
  
  describe "reset" do
    before(:each) do
      subject.set :subclass => :no_cache, :expire => :daily, :host => 'localhost', :port => 112211, :path => "PATH"
    end
    it "should restore the defaults" do
      subject.reset
      subject.subclass.should == Exchange::Cache::Memory
      subject.expire.should == :daily
      subject.host.should be_nil
      subject.port.should be_nil
      subject.path.should be_nil
    end
  end
  
end
