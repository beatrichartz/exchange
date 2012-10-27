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
  
  describe "set" do
    before(:each) do
      @return = subject.set :subclass => :xavier_media, :retries => 55, :app_id => "KEY"
    end
    it "should set the options given" do
      subject.subclass.should == Exchange::ExternalAPI::XavierMedia
      subject.retries.should == 55
      subject.app_id.should == 'KEY'
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
      subject.retries.should == 5
      subject.app_id.should be_nil
    end
  end
  
end