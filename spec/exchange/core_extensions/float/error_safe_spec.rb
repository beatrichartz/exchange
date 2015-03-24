# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::ErrorSafe" do
  let(:is_mri_21) { (RUBY_VERSION =~ /\A2.1/ && RUBY_ENGINE == 'ruby') }
  let(:time) { Time.gm(2012,8,27) }
  before(:all) do
    Exchange.configuration = Exchange::Configuration.new { |c| c.cache = { :subclass => :no_cache } }
  end
  before(:each) do
    allow(Time).to receive(:now).and_return time
  end
  after(:all) do
    Exchange.configuration.reset
  end

  describe "money safe calculation" do
    describe "*" do
      it "should calculate correctly with exchange money" do
        expect((0.29 * 50.in(:usd)).round).to eq(15)
      end
      it "should not touch other operations" do
        expect((0.29 * 50).round).to eq(14)
      end
    end
    describe "/" do
      it "should calculate correctly with exchange money" do
        expect((((1829.82 / 12.in(:usd)) * 100).round.to_f / 100).to_f).to eq(152.49)
      end
      it "should not touch other operations" do
        expect(((1829.82 / 12) * 100).round.to_f / 100).to eq(152.48)
      end
    end
    describe "+" do
      it "should calculate correctly with exchange money" do
        expect((1.0e+25 + BigDecimal.new("9999999999999999900000000").in(:usd)).round.to_f).to eq(2.0e+25)
      end
      it "should not touch other operations" do
        if is_mri_21
          expect((1.0e+25 + BigDecimal.new("9999999999999999900000000")).round).to eq(BigDecimal.new("0.199999999999999999E26"))
        else
          expect((1.0e+25 + BigDecimal.new("9999999999999999900000000")).round).to eq(20000000000000001811939328)
        end
      end
    end
    describe "-" do
      it "should calculate correctly with exchange money" do
        expect((1.0e+25 - BigDecimal.new("9999999999999999900000000").in(:usd)).round).to eq(100000000)
      end
      it "should not touch other operations" do
        if is_mri_21
          expect(1.0e+25 - BigDecimal.new("9999999999999999900000000")).to eq(BigDecimal.new("0.1E9"))
        else
          expect(1.0e+25 - BigDecimal.new("9999999999999999900000000")).to eq(0)
        end
      end
    end
  end
end
