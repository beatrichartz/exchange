# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::ExternalAPI::OpenExchangeRates" do
  before(:all) do
    Exchange.configuration = Exchange::Configuration.new{|c|
      c.cache = {
        :subclass => :no_cache
      }
      c.api = {
        :subclass => :random
      }
    }
  end
  after(:all) do
    Exchange.configuration.reset
  end
  describe "updating rates" do
    subject { Exchange::ExternalAPI::Random.new }
    it "should have usd as base currency" do
      subject.update
      subject.base.should == :usd
    end
    it "should set the timestamp from time.now" do
      time = Time.now
      time.stub :now => time
      subject.update
      subject.timestamp.should == time.to_i
    end
  end
  describe "rates" do
    subject { Exchange::ExternalAPI::Random.new }
    it "should provide a rate for every ISO currency" do
      subject.update
      Exchange::ISO.currencies.each do |c|
        subject.rates[c].should_not be_nil
      end
    end
  end
end
