# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::ExternalAPI::Base" do
  subject { Exchange::ExternalAPI::Base.new }
  before(:all) do
    Exchange.configuration = Exchange::Configuration.new{|c|
      c.cache = {:subclass => :no_cache}
    }
  end
  after(:all) do
    Exchange.configuration.reset
  end
  before(:each) do
    subject.instance_variable_set("@rates", {:eur => BigDecimal.new("3.45"), :chf => BigDecimal.new("5.565")})
    subject.instance_variable_set("@base", :usd)
  end
  describe "rate" do
    it "should put out an exchange rate for the two currencies" do
      expect(subject).to receive(:update).once
      expect(subject.rate(:eur, :chf).round(3)).to eq(1.613)
    end
    it "should put out an exchange rate for the two currencies and pass on opts" do
      time = Time.now
      expect(subject).to receive(:update).with(:at => time).once
      expect(subject.rate(:eur, :chf, :at => time).round(3)).to eq(1.613)
    end
  end
  describe "convert" do
    it "should convert according to the given rates" do
      expect(subject).to receive(:update).once
      expect(subject.convert(80,:chf, :eur).round(2)).to eq(49.6)
    end
    it "should convert according to the given rates and pass opts" do
      time = Time.now
      expect(subject).to receive(:update).with(:at => time).once
      expect(subject.convert(80,:chf, :eur, :at => time).round(2)).to eq(49.6)
    end
  end
end
