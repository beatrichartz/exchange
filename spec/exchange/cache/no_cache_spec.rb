require 'spec_helper'

describe "Exchange::Cache::Rails" do
  context "with rails defined" do
    class ::Rails
    end
  end
  subject { Exchange::Cache::NoCache }
  before(:each) do
    Exchange.configuration = Exchange::Configuration.new { |c|
      c.cache = {
        :class => :no_cache
      }
    }
  end
  after(:each) do
    Exchange.configuration = Exchange::Configuration.new { |c|
      c.cache = {
        :class => :memcached,
        :host => 'localhost',
        :port => 11211
      }
    }
  end
  describe "cached" do
    it "should directly call the block" do
      subject.cached('API_CLASS') { 'something' }.should == 'something'
    end
    it "should raise an error if no block was given" do
      lambda { subject.cached('API_CLASS') }.should raise_error(Exchange::Cache::CachingWithoutBlockError)
    end
  end
end