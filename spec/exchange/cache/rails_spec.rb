# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::Cache::Rails" do
  context "with rails defined" do
    class ::Rails
    end
  end
  subject { Exchange::Cache::Rails.instance }
  before(:each) do
    Exchange.configuration = Exchange::Configuration.new { |c|
      c.cache = {
        :subclass => :rails
      }
    }
  end
  after(:each) do
    Exchange.configuration.reset
  end
  describe "client" do
    let(:client) { double('rails_cache') }
    it "should set up a client on the specified host and port for the cache" do
      ::Rails.should_receive(:cache).and_return(client)
      subject.client.should == client
    end
  end
  describe "cached" do
    it "should raise an error if no block was given" do
      lambda { subject.cached('API_CLASS') }.should raise_error(Exchange::Cache::CachingWithoutBlockError)
    end
    context "when a result is returned" do
      let(:client) { double('rails_cache') }
      context "with a daily cache" do
        before(:each) do
          subject.should_receive(:key).with('API_CLASS', {}).and_return('KEY')
          ::Rails.should_receive(:cache).and_return(client)
          client.should_receive(:fetch).with('KEY', :expires_in => 86400).and_return "{\"RESULT\":\"YAY\"}"
        end
        it "should return the JSON loaded result" do
          subject.cached('API_CLASS') { 'something' }.should == "{\"RESULT\":\"YAY\"}"
        end
      end
      context "with an hourly cache" do
        before(:each) do
          Exchange.configuration.cache.expire = :hourly
          subject.should_receive(:key).with('API_CLASS', {}).and_return('KEY')
          ::Rails.should_receive(:cache).and_return(client)
          client.should_receive(:fetch).with('KEY', :expires_in => 3600).and_return "{\"RESULT\":\"YAY\"}"
        end
        after(:each) do
          Exchange.configuration.cache.expire = :daily
        end
        it "should return the JSON loaded result" do
          subject.cached('API_CLASS') { 'something' }.should == "{\"RESULT\":\"YAY\"}"
        end
      end
    end
    context "when no result is returned" do
      let(:client) { double('rails_cache') }
      before(:each) do
        subject.should_receive(:key).with('API_CLASS', {}).at_most(3).times.and_return('KEY')
        ::Rails.should_receive(:cache).twice.and_return(client)
        client.should_receive(:fetch).with('KEY', an_instance_of(Hash)).and_return nil
        client.should_receive(:delete).with('KEY').once
      end
      it "should call the block and delete the key to avoid empty caches" do
        subject.cached('API_CLASS') { {'RESULT' => 'YAY'} }.should be_nil
      end
    end
  end
end
