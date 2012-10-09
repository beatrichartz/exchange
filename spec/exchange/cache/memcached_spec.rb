require 'spec_helper'

describe "Exchange::CacheDalli::Client" do
  subject { Exchange::Cache::Memcached.instance }
  before(:each) do
    Exchange.configuration = Exchange::Configuration.new { |c|
      c.cache = {
        :host => 'HOST',
        :port => 'PORT'
      }
    }
  end
  after(:each) do
    Exchange.configuration = Exchange::Configuration.new { |c|
      c.cache = {
        :host => 'localhost',
        :port => 11211
      }
    }
  end
  describe "client" do
    let(:client) { mock('memcached') }
    before(:each) do
      Exchange::GemLoader.new('dalli').try_load
    end
    after(:each) do
      subject.instance_variable_set "@client", nil
    end
    it "should set up a client on the specified host and port for the cache" do
      Dalli::Client.should_receive(:new).with("HOST:PORT").and_return(client)
      subject.client.should == client
    end
  end
  describe "cached" do
    let(:client) { mock('memcached', :get => '') }
    before(:each) do
      Dalli::Client.should_receive(:new).with("HOST:PORT").and_return(client)
    end
    after(:each) do
      subject.instance_variable_set "@client", nil
    end
    it "should raise an error if no block was given" do
      lambda { subject.cached('API_CLASS') }.should raise_error(Exchange::Cache::CachingWithoutBlockError)
    end
    context "when a cached result exists" do
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
      context "when returning nil" do
        before(:each) do
          subject.should_receive(:key).with('API_CLASS', {}).twice.and_return('KEY')
          client.should_receive(:get).with('KEY').and_return(nil)
        end
        context "with daily cache" do
          it "should call the block and set and return the result" do
            client.should_receive(:set).with('KEY', "{\"RESULT\":\"YAY\"}", 86400).once
            subject.cached('API_CLASS') { {'RESULT' => 'YAY'} }.should == {'RESULT' => 'YAY'}
          end
        end
        context "with hourly cache" do
          before(:each) do
            Exchange.configuration.cache.expire = :hourly
          end
          after(:each) do
            Exchange.configuration.cache.expire = :daily
          end
          it "should call the block and set and return the result" do
            client.should_receive(:set).with('KEY', "{\"RESULT\":\"YAY\"}", 3600).once
            subject.cached('API_CLASS') { {'RESULT' => 'YAY'} }.should == {'RESULT' => 'YAY'}
          end
        end
      end
      context "when returning an empty string" do
        before(:each) do
          subject.should_receive(:key).with('API_CLASS', {}).twice.and_return('KEY')
          client.should_receive(:get).with('KEY').and_return('')
        end
        context "with daily cache" do
          it "should call the block and set and return the result" do
            client.should_receive(:set).with('KEY', "{\"RESULT\":\"YAY\"}", 86400).once
            subject.cached('API_CLASS') { {'RESULT' => 'YAY'} }.should == {'RESULT' => 'YAY'}
          end
        end
        context "with hourly cache" do
          before(:each) do
            Exchange.configuration.cache.expire = :hourly
          end
          after(:each) do
            Exchange.configuration.cache.expire = :daily
          end
          it "should call the block and set and return the result" do
            client.should_receive(:set).with('KEY', "{\"RESULT\":\"YAY\"}", 3600).once
            subject.cached('API_CLASS') { {'RESULT' => 'YAY'} }.should == {'RESULT' => 'YAY'}
          end
        end
      end
    end
  end
end