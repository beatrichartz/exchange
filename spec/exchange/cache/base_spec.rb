require 'spec_helper'

describe "Exchange::Cache::Base" do
  subject { Exchange::Cache::Base }
  describe "key generation" do
    before(:each) do
      time = Time.gm 2012, 03, 01, 23, 23, 23
      Time.stub! :now => time
    end
    context "with a daily cache" do
      it "should build a timestamped key with the class given, the yearday and the year" do
        Exchange::Cache::Base.send(:key, Exchange::ExternalAPI::XavierMedia).should == 'Exchange_ExternalAPI_XavierMedia_2012_61'
        Exchange::Cache::Base.send(:key, Exchange::ExternalAPI::CurrencyBot).should == 'Exchange_ExternalAPI_CurrencyBot_2012_61'
      end
    end
    context "with an hourly cache" do
      before(:each) do
        Exchange::Configuration.update = :hourly
      end
      after(:each) do
        Exchange::Configuration.update = :daily
      end
      it "should build a timestamped key with the class given, the yearday, the year and the hour" do
        Exchange::Cache::Base.send(:key, Exchange::ExternalAPI::XavierMedia).should == 'Exchange_ExternalAPI_XavierMedia_2012_61_23'
        Exchange::Cache::Base.send(:key, Exchange::ExternalAPI::CurrencyBot).should == 'Exchange_ExternalAPI_CurrencyBot_2012_61_23'
      end
    end
  end
end