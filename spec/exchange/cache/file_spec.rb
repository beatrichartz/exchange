require 'spec_helper'

describe "Exchange::Cache::File" do
  subject { Exchange::Cache::File }
  before(:each) do
    Exchange::Configuration.define do |c|
      c.cache      = :file
    end
  end
  after(:each) do
    Exchange::Configuration.define do |c|
      c.cache      = :memcached
    end
  end
  describe "cached" do
    context "when a result is returned" do
      context "with a daily cache" do
        before(:each) do
          subject.should_receive(:key).with('API_CLASS', nil).and_return('KEY')
          Exchange::Configuration.should_receive(:filestore_path).and_return('STORE')
          ::File.should_receive(:exists?).with('STORE/KEY').and_return(true)
          ::File.should_receive(:read).with('STORE/KEY').and_return 'CONTENT'
        end
        it "should return the file contents" do
          subject.cached('API_CLASS') { 'something' }.should == 'CONTENT'
        end
      end
      context "with an monthly cache" do
        before(:each) do
          subject.should_receive(:key).with('API_CLASS', :monthly).and_return('KEY')
          Exchange::Configuration.should_receive(:filestore_path).and_return('STORE')
          ::File.should_receive(:exists?).with('STORE/KEY').and_return(true)
          ::File.should_receive(:read).with('STORE/KEY').and_return 'CONTENT'
        end
        it "should return the file contents" do
          subject.cached('API_CLASS', :cache_period => :monthly) { 'something' }.should == 'CONTENT'
        end
      end
    end
    context "when no result is returned" do
      before(:each) do
        subject.should_receive(:key).with('API_CLASS', :monthly).and_return('KEY')
        Exchange::Configuration.should_receive(:filestore_path).and_return('STORE')
        ::File.should_receive(:exists?).with('STORE/KEY').and_return(true)
        ::File.should_receive(:read).with('STORE/KEY').and_return 'CONTENT'
      end
      it "should return the file contents" do
        subject.cached('API_CLASS', :cache_period => :monthly) { 'something' }.should == 'CONTENT'
      end
    end
  end
end