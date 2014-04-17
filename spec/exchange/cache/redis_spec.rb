# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'redis'

describe "Exchange::Cache::Redis" do
  subject { Exchange::Cache::Redis.instance }
  before(:each) do
    Exchange.configuration = Exchange::Configuration.new do |c|
      c.cache = {
        :subclass => :redis,
        :host => 'HOST',
        :port => 'PORT'
      }
    end
  end
  after(:each) do
    Exchange.configuration.reset
  end
  describe "client" do
    let(:client) { double('redis') }
    after(:each) do
      subject.instance_variable_set "@client", nil
    end
    it "should set up a client on the specified host and port for the cache" do
      expect(::Redis).to receive(:new).with(:host => 'HOST', :port => 'PORT').and_return(client)
      expect(subject.client).to eq(client)
    end
  end
  describe "cached" do
    let(:client) { double('redis', :get => nil) }
    before(:each) do
      expect(::Redis).to receive(:new).with(:host => 'HOST', :port => 'PORT').and_return(client)
    end
    after(:each) do
      subject.instance_variable_set "@client", nil
    end
    it "should raise an error if no block was given" do
      expect { subject.cached('API_CLASS') }.to raise_error(Exchange::Cache::CachingWithoutBlockError)
    end
    context "when a cached result exists" do
      context "when loading" do
        before(:each) do
          expect(subject).to receive(:key).with('API_CLASS', {}).and_return('KEY')
          expect(client).to receive(:get).with('KEY').and_return({'RESULT' => 'YAY'}.cachify)
        end
        it "should return the JSON loaded result" do
          expect(subject.cached('API_CLASS') { 'something' }).to eq({'RESULT' => 'YAY'})
        end
      end
      context "when loading plain" do
        before(:each) do
          expect(subject).to receive(:key).with('API_CLASS', {:plain => true}).and_return('KEY')
        end
        it "should return a String result in the right format" do
          expect(client).to receive(:get).with('KEY').and_return("122.0".cachify)
          expect(subject.cached('API_CLASS', :plain => true) { 'something' }).to eq("122.0".cachify)
        end
      end
    end
    context "when no cached result exists" do
      before(:each) do
        expect(subject).to receive(:key).with('API_CLASS', {}).at_most(3).times.and_return('KEY')
        expect(client).to receive(:get).with('KEY').and_return nil
      end
      context "with daily cache" do
        it "should call the block and set and return the result" do
          expect(client).to receive(:set).with('KEY', {'RESULT' => 'YAY'}.cachify).once
          expect(client).to receive(:expire).with('KEY', 86400).once
          expect(subject.cached('API_CLASS') { {'RESULT' => 'YAY'} }).to eq({'RESULT' => 'YAY'})
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
          expect(client).to receive(:set).with('KEY', {'RESULT' => 'YAY'}.cachify).once
          expect(client).to receive(:expire).with('KEY', 3600).once
          expect(subject.cached('API_CLASS') { {'RESULT' => 'YAY'} }).to eq({'RESULT' => 'YAY'})
        end
      end
    end
  end
end
