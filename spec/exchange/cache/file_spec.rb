# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::Cache::File" do
  subject { Exchange::Cache::File.instance }
  before(:each) do
    Exchange.configuration = Exchange::Configuration.new { |c|
      c.cache      = {
        :subclass => :file,
        :path     => 'STORE/PATH'
      }
    }
  end
  after(:each) do
    Exchange.configuration.reset
  end
  describe "cached" do
    it "should raise an error if no block was given" do
      lambda { subject.cached('API_CLASS') }.should raise_error(Exchange::Cache::CachingWithoutBlockError)
    end
    context "when a result is returned" do
      context "with a daily cache" do
        before(:each) do
          subject.should_receive(:key).with('API_CLASS', nil).and_return('KEY')
          ::File.should_receive(:exists?).with('STORE/PATH/KEY').and_return(true)
          ::File.should_receive(:read).with('STORE/PATH/KEY').and_return 'CONTENT'.cachify
        end
        it "should return the file contents" do
          subject.cached('API_CLASS') { 'something' }.should == 'CONTENT'
        end
        it "should also return plain when asked to" do
          subject.cached('API_CLASS', :plain => true) { 'something' }.should == 'CONTENT'.cachify
        end
      end
      context "with a monthly cache" do
        before(:each) do
          subject.should_receive(:key).with('API_CLASS', an_instance_of(Symbol)).and_return('KEY')
          ::File.should_receive(:exists?).with('STORE/PATH/KEY').and_return(true)
          ::File.should_receive(:read).with('STORE/PATH/KEY').and_return 'CONTENT'.cachify
        end
        it "should return the file contents" do
          subject.cached('API_CLASS', :cache_period => :monthly) { 'something' }.should == 'CONTENT'
        end
        it "should also return plain when asked to" do
          subject.cached('API_CLASS', :cache_period => :monthly, :plain => true) { 'something' }.should == 'CONTENT'.cachify
        end
      end
    end
    context "when no file is cached yet" do
      before(:each) do
        subject.should_receive(:key).with('API_CLASS', an_instance_of(Symbol)).at_most(3).times.and_return('KEY')
        ::File.should_receive(:exists?).with('STORE/PATH/KEY').and_return(false)
        Dir.should_receive(:entries).with('STORE/PATH').once.and_return(%W(entry entry2))
        ::File.should_receive(:delete).with(an_instance_of(String)).twice
        FileUtils.should_receive(:mkdir_p).once
        ::File.should_receive(:open).once
      end
      it "should return the file contents" do
        subject.cached('API_CLASS', :cache_period => :monthly) { 'RESULT' }.should == 'RESULT'
      end
    end
    context "when no result is returned" do
      before(:each) do
        subject.should_receive(:key).with('API_CLASS', an_instance_of(Symbol)).at_most(3).times.and_return('KEY')
        ::File.should_receive(:exists?).with('STORE/PATH/KEY').and_return(false)
        FileUtils.should_receive(:mkdir_p).never
        ::File.should_receive(:open).never
      end
      it "should return the file contents" do
        subject.cached('API_CLASS', :cache_period => :monthly) { '' }.should == ''
      end
    end
  end
end
