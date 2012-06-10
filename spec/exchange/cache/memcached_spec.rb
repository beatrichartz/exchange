require 'spec_helper'

describe "Exchange::Cache::Memcached" do
  subject { Exchange::Cache::Memcached }
  before(:each) do
    Exchange::Configuration.define do |c|
      c.cache_host = 'HOST'
      c.cache_port = 'PORT'
    end
  end
  after(:each) do
    Exchange::Configuration.define do |c|
      c.cache_host = 'localhost'
      c.cache_port = 11211
    end
  end
  describe "client" do
    let(:client) { mock('memcached') }
    after(:each) do
      subject.send(:remove_class_variable, "@@client")
    end
    it "should set up a client on the specified host and port for the cache" do
      ::Memcached.should_receive(:new).with("HOST:PORT").and_return(client)
      subject.client.should == client
    end
  end
  describe "cached" do
    it "should raise an error if no block was given" do
      lambda { subject.cached('API_CLASS') }.should raise_error(Exchange::Cache::CachingWithoutBlockError)
    end
    context "when a cached result exists" do
      let(:client) { mock('memcached') }
      before(:each) do
        ::Memcached.should_receive(:new).with("HOST:PORT").and_return(client)
      end
      after(:each) do
        subject.send(:remove_class_variable, "@@client")
      end
      context "when loading json" do
        before(:each) do
          subject.should_receive(:key).with('API_CLASS', {}).and_return('KEY')
          client.should_receive(:get).with('KEY').and_return "{\"RESULT\":\"YAY\"}"
        end
        it "should return the JSON loaded result" do
          subject.cached('API_CLASS') { 'something' }.should == {'RESULT' => 'YAY'}
        end
      end
      context "when loading plain" do
        before(:each) do
          subject.should_receive(:key).with('API_CLASS', {:plain => true}).and_return('KEY')
        end
        it "should return a String result in the right format" do
          client.should_receive(:get).with('KEY').and_return "122.0"
          subject.cached('API_CLASS', :plain => true) { 'something' }.should == "122.0"
        end
        it "should also return a String result in the right format when memcached adds quotes and spaces" do
          client.should_receive(:get).with('KEY').and_return "\"122.0\" "
          subject.cached('API_CLASS', :plain => true) { 'something' }.should == "122.0"
        end
      end
    end
    context "when no cached result exists" do
      let(:client) { mock('memcached') }
      before(:each) do
        subject.should_receive(:key).with('API_CLASS', {}).twice.and_return('KEY')
        ::Memcached.should_receive(:new).with("HOST:PORT").and_return(client)
        client.should_receive(:get).with('KEY').and_raise(::Memcached::NotFound)
      end
      after(:each) do
        subject.send(:remove_class_variable, "@@client")
      end
      context "with daily cache" do
        it "should call the block and set and return the result" do
          client.should_receive(:set).with('KEY', "{\"RESULT\":\"YAY\"}", 86400).once
          subject.cached('API_CLASS') { {'RESULT' => 'YAY'} }.should == {'RESULT' => 'YAY'}
        end
      end
      context "with hourly cache" do
        before(:each) do
          Exchange::Configuration.update = :hourly
        end
        after(:each) do
          Exchange::Configuration.update = :daily
        end
        it "should call the block and set and return the result" do
          client.should_receive(:set).with('KEY', "{\"RESULT\":\"YAY\"}", 3600).once
          subject.cached('API_CLASS') { {'RESULT' => 'YAY'} }.should == {'RESULT' => 'YAY'}
        end
      end
    end
  end
end