# -*- encoding : utf-8 -*-
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
    Exchange.configuration.reset
  end
  describe "client" do
    let(:client) { double('memcached') }
    before(:each) do
      Exchange::GemLoader.new('dalli').try_load
    end
    after(:each) do
      subject.instance_variable_set "@client", nil
    end
    it "should set up a client on the specified host and port for the cache" do
      expect(Dalli::Client).to receive(:new).with("HOST:PORT").and_return(client)
      expect(subject.client).to eq(client)
    end
  end
  describe "wipe_client!" do
    let(:client) { double('memcached') }
    
    it "should set the client to nil" do
      expect(Dalli::Client).to receive(:new).with("HOST:PORT").and_return(client)
      expect(subject.client).to eq(client)
      subject.wipe_client!
      expect(subject.instance_variable_get("@client")).to be_nil
    end
  end
  describe "cached" do
    let(:client) { double('memcached', :get => '') }
    before(:each) do
      expect(Dalli::Client).to receive(:new).with("HOST:PORT").and_return(client)
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
          expect(client).to receive(:get).with('KEY').and_return "122.0".cachify
          expect(subject.cached('API_CLASS', :plain => true) { 'something' }).to eq("122.0".cachify)
        end
      end
    end
    context "when no cached result exists" do
      let(:client) { double('memcached') }
      context "when returning nil" do
        before(:each) do
          expect(subject).to receive(:key).with('API_CLASS', {}).twice.and_return('KEY')
          expect(client).to receive(:get).with('KEY').and_return(nil)
        end
        context "with daily cache" do
          it "should call the block and set and return the result" do
            expect(client).to receive(:set).with('KEY', {'RESULT' => 'YAY'}.cachify, 86400).once
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
            expect(client).to receive(:set).with('KEY', {'RESULT' => 'YAY'}.cachify, 3600).once
            expect(subject.cached('API_CLASS') { {'RESULT' => 'YAY'} }).to eq({'RESULT' => 'YAY'})
          end
        end
      end
      context "when returning an empty string" do
        before(:each) do
          expect(subject).to receive(:key).with('API_CLASS', {}).twice.and_return('KEY')
          expect(client).to receive(:get).with('KEY').and_return('')
        end
        context "with daily cache" do
          it "should call the block and set and return the result" do
            expect(client).to receive(:set).with('KEY', {'RESULT' => 'YAY'}.cachify, 86400).once
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
            expect(client).to receive(:set).with('KEY', {'RESULT' => 'YAY'}.cachify, 3600).once
            expect(subject.cached('API_CLASS') { {'RESULT' => 'YAY'} }).to eq({'RESULT' => 'YAY'})
          end
        end
      end
    end
  end
end
