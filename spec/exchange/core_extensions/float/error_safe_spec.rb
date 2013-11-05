# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::ErrorSafe" do
  before(:all) do
    Exchange.configuration = Exchange::Configuration.new { |c| c.cache = { :subclass => :no_cache } }
  end
  before(:each) do
    @time = Time.gm(2012,8,27)
    Time.stub :now => @time
  end
  after(:all) do
    Exchange.configuration.reset
  end
  
  describe "money safe calculation" do
    describe "*" do
      it "should calculate correctly with exchange money" do
        (0.29 * 50.in(:usd)).round.should == 15
      end
      it "should not touch other operations" do
        (0.29 * 50).round.should == 14
      end
    end
    describe "/" do
      it "should calculate correctly with exchange money" do
        (((1829.82 / 12.in(:usd)) * 100).round.to_f / 100).to_f.should == 152.49
      end
      it "should not touch other operations" do
        (((1829.82 / 12) * 100).round.to_f / 100).should == 152.48
      end
    end
    describe "+" do
      it "should calculate correctly with exchange money" do
        (1.0e+25 + BigDecimal.new("9999999999999999900000000").in(:usd)).round.to_f.should == 2.0e+25
      end
      it "should not touch other operations" do
        (1.0e+25 + BigDecimal.new("9999999999999999900000000")).round.should == 20000000000000001811939328
      end
    end
    describe "-" do
      it "should calculate correctly with exchange money" do
        (1.0e+25 - BigDecimal.new("9999999999999999900000000").in(:usd)).round.should == 100000000
      end
      it "should not touch other operations" do
        (1.0e+25 - BigDecimal.new("9999999999999999900000000")).should == 0
      end
    end
  end
end
