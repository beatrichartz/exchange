require 'spec_helper'

describe "Exchange::ExternalAPI::Base" do
  subject { Exchange::ExternalAPI::Base.new }
  before(:each) do
    subject.instance_variable_set("@rates", {'EUR' => 3.45, 'CHF' => 5.565})
    subject.instance_variable_set("@base", 'usd')
  end
  describe "rate" do
    it "should put out an exchange rate for the two currencies" do
      subject.should_receive(:update).once
      ((subject.rate('eur', 'chf') * 10000).round.to_f / 10000).should == 1.613
    end
    it "should put out an exchange rate for the two currencies and pass on opts" do
      time = Time.now
      subject.should_receive(:update).with(:at => time).once
      ((subject.rate('eur', 'chf', :at => time) * 10000).round.to_f / 10000).should == 1.613
    end
  end
  describe "convert" do
    it "should convert according to the given rates" do
      subject.should_receive(:update).once
      subject.convert(80,'chf','eur').should == 49.6
    end
    it "should convert according to the given rates and pass opts" do
      time = Time.now
      subject.should_receive(:update).with(:at => time).once
      subject.convert(80,'chf','eur', :at => time).should == 49.6
    end
  end
end