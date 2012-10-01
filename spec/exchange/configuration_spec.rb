require 'spec_helper'

describe "Exchange::Configuration" do
  let(:subject) { Exchange::Configuration.new }
  it "should have a standard configuration" do
    subject.api.retries.should == 5
    subject.api.subclass.should == Exchange::ExternalAPI::XavierMedia
    subject.cache.subclass.should == Exchange::Cache::Memcached
    subject.cache.host.should == 'localhost'
    subject.cache.port.should == 11211
    subject.cache.expire.should == :daily
  end
  it "should respond to all configuration getters and setters" do
    [:api, :allow_mixed_operations, :cache].each do |k|
      subject.should be_respond_to(k)
      subject.should be_respond_to(:"#{k}=")
    end
  end
  it 'should respond to nested getters and setters for the api and the cache' do
    {:api => [:subclass, :retries], :cache => [:subclass, :host, :port, :expire]}.each do |k,m|
      m.each do |meth|
        subject.send(k).should be_respond_to(meth)
        subject.send(k).should be_respond_to(:"#{meth}=")
      end
    end
  end
  it "should allow to be defined with a block" do
    Exchange.configuration = Exchange::Configuration.new {|c|
      c.api = {
        :subclass => :xavier_media,
        :retries => 60
      }
      c.cache = {
        :subclass => :redis
      }
    }
    Exchange.configuration.api.subclass.should == Exchange::ExternalAPI::XavierMedia
    Exchange.configuration.api.retries.should == 60
    Exchange.configuration.cache.subclass.should == Exchange::Cache::Redis
  end
  it "should allow to be set directly" do
    subject.api = {
      :subclass => :ecb,
      :retries => 1
    }
    subject.api.subclass.should == Exchange::ExternalAPI::Ecb
    subject.api.retries.should == 1
  end
  after(:all) do
    subject.api = {
      :subclass => :currency_bot,
      :retries => 5
    }
  end  
end