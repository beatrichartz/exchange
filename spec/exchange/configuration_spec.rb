# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::Configuration" do
  let(:subject) { Exchange::Configuration.new }
  it "should have a standard configuration" do
    expect(subject.api.retries).to eq(7)
    expect(subject.api.subclass).to eq(Exchange::ExternalAPI::XavierMedia)
    expect(subject.cache.subclass).to eq(Exchange::Cache::Memory)
    expect(subject.cache.host).to be_nil
    expect(subject.cache.port).to be_nil
    expect(subject.cache.expire).to eq(:daily)
  end
  it "should respond to all configuration getters and setters" do
    [:api, :implicit_conversions, :cache].each do |k|
      expect(subject).to be_respond_to(k)
      expect(subject).to be_respond_to(:"#{k}=")
    end
  end
  it 'should respond to nested getters and setters for the api and the cache' do
    {:api => [:subclass, :retries], :cache => [:subclass, :host, :port, :expire]}.each do |k,m|
      m.each do |meth|
        expect(subject.send(k)).to be_respond_to(meth)
        expect(subject.send(k)).to be_respond_to(:"#{meth}=")
      end
    end
  end
  it "should allow to be defined with a block" do
    Exchange.configuration = Exchange::Configuration.new {|c|
      c.api = {
        :subclass => :xavier_media,
        :retries => 60,
        :fallback => :open_exchange_rates
      }
      c.cache = {
        :subclass => :redis
      }
    }
    expect(Exchange.configuration.api.subclass).to eq(Exchange::ExternalAPI::XavierMedia)
    expect(Exchange.configuration.api.retries).to eq(60)
    expect(Exchange.configuration.api.fallback).to eq([Exchange::ExternalAPI::OpenExchangeRates])
    expect(Exchange.configuration.cache.subclass).to eq(Exchange::Cache::Redis)
  end
  it "should allow to be set directly" do
    subject.api = {
      :subclass => :ecb,
      :retries => 1
    }
    expect(subject.api.subclass).to eq(Exchange::ExternalAPI::Ecb)
    expect(subject.api.retries).to eq(1)
  end
  describe "reset" do
    Exchange.configuration = Exchange::Configuration.new {|c|
      c.api = {
        :subclass => :open_exchange_rates,
        :retries => 60,
        :app_id => '234u230482348023'
      }
      c.cache = {
        :subclass => :redis,
        :host => 'localhost',
        :port => 112211,
        :path => 'PATH'
      }
      c.implicit_conversions = false
    }
    it "should restore the defaults" do
      subject.reset
      expect(subject.api.subclass).to eq(Exchange::ExternalAPI::XavierMedia)
      expect(subject.api.retries).to eq(7)
      expect(subject.api.app_id).to be_nil
      expect(subject.api.fallback).to eq([Exchange::ExternalAPI::Ecb])
      expect(subject.cache.subclass).to eq(Exchange::Cache::Memory)
      expect(subject.cache.host).to be_nil
      expect(subject.cache.port).to be_nil
      expect(subject.cache.path).to be_nil
      expect(subject.implicit_conversions).to be_true
    end
  end
  after(:all) do
    Exchange.configuration.reset
  end  
end
