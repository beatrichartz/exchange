# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::Cache::Base" do
  subject { Exchange::Cache::Base.instance }
  describe "key generation" do
    before(:each) do
      time = Time.gm 2012, 03, 01, 23, 23, 23
      Time.stub :now => time
    end
    context "with a daily cache" do
      it "should build a timestamped key with the class given, the yearday and the year" do
        subject.send(:key, :xavier_media).should == 'exchange_xavier_media_2012_61'
        subject.send(:key, :open_exchange_rates).should == 'exchange_open_exchange_rates_2012_61'
      end
    end
    context "with an hourly cache" do
      before(:each) do
        Exchange.configuration.cache.expire = :hourly
      end
      after(:each) do
        Exchange.configuration.cache.expire = :daily
      end
      it "should build a timestamped key with the class given, the yearday, the year and the hour" do
        subject.send(:key, :xavier_media).should == 'exchange_xavier_media_2012_61_23'
        subject.send(:key, :open_exchange_rates).should == 'exchange_open_exchange_rates_2012_61_23'
      end
    end
  end
end
