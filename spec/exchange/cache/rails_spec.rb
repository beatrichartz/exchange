require 'spec_helper'

describe "Exchange::Cache::Rails" do
  context "with rails defined" do
    class ::Rails
    end
  end
  subject { Exchange::Cache::Rails }
  before(:each) do
    Exchange::Configuration.define do |c|
      c.cache      = :rails
    end
  end
  after(:each) do
    Exchange::Configuration.define do |c|
      c.cache      = :memcached
    end
  end
  describe "client" do
    let(:client) { mock('rails_cache') }
    it "should set up a client on the specified host and port for the cache" do
      ::Rails.should_receive(:cache).and_return(client)
      subject.client.should == client
    end
  end
  describe "cached" do
    context "when a result is returned" do
      let(:client) { mock('rails_cache') }
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
          Exchange::Configuration.update = :hourly
          subject.should_receive(:key).with('API_CLASS', {}).and_return('KEY')
          ::Rails.should_receive(:cache).and_return(client)
          client.should_receive(:fetch).with('KEY', :expires_in => 3600).and_return "{\"RESULT\":\"YAY\"}"
        end
        after(:each) do
          Exchange::Configuration.update = :daily
        end
        it "should return the JSON loaded result" do
          subject.cached('API_CLASS') { 'something' }.should == "{\"RESULT\":\"YAY\"}"
        end
      end
    end
    context "when no result is returned" do
      let(:client) { mock('rails_cache') }
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