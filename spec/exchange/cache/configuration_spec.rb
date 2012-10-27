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