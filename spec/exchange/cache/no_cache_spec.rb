# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::Cache::NoCache" do
  subject { Exchange::Cache::NoCache }
  before(:all) do
    Exchange.configuration = Exchange::Configuration.new { |c|
      c.cache = {
        :subclass => :no_cache
      }
    }
  end
  after(:all) do
    Exchange.configuration.reset
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
