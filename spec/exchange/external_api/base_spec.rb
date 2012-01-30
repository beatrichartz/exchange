require 'spec_helper'

describe "Exchange::ExternalAPI::Base" do
  subject { Exchange::ExternalAPI::Base.new }
  before(:each) do
    subject.rates = {'EUR' => 3.45, 'CHF' => 5.565}
    subject.base  = 'usd'
  end
  describe "rate" do
    it "should put out an exchange rate for the two currencies" do
      subject.should_receive(:update).once
      ((subject.rate('eur', 'chf') * 10000).round.to_f / 10000).should == 1.613
    end
  end
  describe "convert" do
    it "should convert according to the given rates" do
      subject.should_receive(:update).once
      subject.convert(80,'chf','eur').should == 49.6
    end
  end
end