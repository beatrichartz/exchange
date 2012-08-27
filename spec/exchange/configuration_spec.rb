require 'spec_helper'

describe "Exchange::Configuration" do
  let(:subject) { Exchange::Configuration }
  it "should have a standard configuration" do
    subject.api.should == :xavier_media
    subject.api_class.should == Exchange::ExternalAPI::XavierMedia
    subject.cache.should == :memcached
    subject.cache_class.should == Exchange::Cache::Memcached
    subject.cache_host.should == 'localhost'
    subject.cache_port.should == 11211
    subject.retries.should == 5
  end
  it "should respond to all configuration getters and setters" do
    [:api, :retries, :allow_mixed_operations, :cache, :cache_host, :cache_port, :update].each do |k|
      subject.should be_respond_to(k)
      subject.should be_respond_to(:"#{k}=")
    end
  end
  it "should allow to be defined with a block" do
    subject.define do |c|
      c.api = :xavier_media
      c.cache = :redis
      c.retries = 60
    end
    subject.api.should == :xavier_media
    subject.api_class.should == Exchange::ExternalAPI::XavierMedia
    subject.cache.should == :redis
    subject.cache_class.should == Exchange::Cache::Redis
    subject.retries.should == 60
  end
  it "should allow to be set directly" do
    subject.api = :paypal
    subject.cache = :yml
    subject.retries = 1
    subject.api.should == :paypal
    subject.cache.should == :yml
    subject.retries.should == 1
  end
  after(:all) do
    subject.api = :currency_bot
    subject.cache = :memcached
    subject.cache_host = 'localhost'
    subject.cache_port = 11211
    subject.retries = 5
  end  
end