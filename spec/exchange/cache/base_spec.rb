# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::Cache::Base" do
  subject { Exchange::Cache::Base.instance }
  describe "key generation" do
    before(:each) do
      time = Time.gm 2012, 03, 01, 23, 23, 23
      allow(Time).to receive(:now).and_return time
    end
    context "with a daily cache" do
      it "should build a timestamped key with the class given, the yearday and the year" do
        expect(subject.send(:key, :xavier_media)).to eq('exchange_xavier_media_2012_61')
        expect(subject.send(:key, :open_exchange_rates)).to eq('exchange_open_exchange_rates_2012_61')
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
        expect(subject.send(:key, :xavier_media)).to eq('exchange_xavier_media_2012_61_23')
        expect(subject.send(:key, :open_exchange_rates)).to eq('exchange_open_exchange_rates_2012_61_23')
      end
    end
  end
end
