require 'spec_helper'

describe "Exchange::Cache::Redis" do
  subject { Exchange::Cache::Redis }
  before(:each) do
    Exchange::Configuration.define do |c|
      c.cache      = :redis
      c.cache_host = 'HOST'
      c.cache_port = 'PORT'
    end
  end
  after(:each) do
    Exchange::Configuration.define do |c|
      c.cache      = :memcached
      c.cache_host = 'localhost'
      c.cache_port = 11211
    end
  end
  describe "client" do
    let(:client) { mock('redis') }
    after(:each) do
      subject.send(:remove_class_variable, "@@client")
    end
    it "should set up a client on the specified host and port for the cache" do
      ::Redis.should_receive(:new).with(:host => 'HOST', :port => 'PORT').and_return(client)
      subject.client.should == client
    end
  end
  describe "cached" do
    context "when a cached result exists" do
      let(:client) { mock('redis') }
      before(:each) do
        subject.should_receive(:key).with('API_CLASS', {}).and_return('KEY')
        ::Redis.should_receive(:new).with(:host => 'HOST', :port => 'PORT').and_return(client)
        client.should_receive(:get).with('KEY').and_return "{\"RESULT\":\"YAY\"}"
      end
      after(:each) do
        subject.send(:remove_class_variable, "@@client")
      end
      it "should return the JSON loaded result" do
        subject.cached('API_CLASS') { 'something' }.should == {'RESULT' => 'YAY'}
      end
    end
    context "when no cached result exists" do
      let(:client) { mock('redis') }
      before(:each) do
        subject.should_receive(:key).with('API_CLASS', {}).at_most(3).times.and_return('KEY')
        ::Redis.should_receive(:new).with(:host => 'HOST', :port => 'PORT').and_return(client)
        client.should_receive(:get).with('KEY').and_return nil
      end
      after(:each) do
        subject.send(:remove_class_variable, "@@client")
      end
      context "with daily cache" do
        it "should call the block and set and return the result" do
          client.should_receive(:set).with('KEY', "{\"RESULT\":\"YAY\"}").once
          client.should_receive(:expire).with('KEY', 86400).once
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
          client.should_receive(:set).with('KEY', "{\"RESULT\":\"YAY\"}").once
          client.should_receive(:expire).with('KEY', 3600).once
          subject.cached('API_CLASS') { {'RESULT' => 'YAY'} }.should == {'RESULT' => 'YAY'}
        end
      end
    end
  end
end