# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::Helper" do
  subject { Exchange::Helper }
  describe "assure_time" do
    before(:each) do
      time = Time.now
      Time.stub :now => time
    end
    context "with a time object" do
      it "should return that time object" do
        Exchange::Helper.assure_time(Time.now - 3400).should == Time.now - 3400
      end
    end
    context "with a string" do
      it "should send to Time.gm" do
        Time.should_receive(:gm).with('2011','09','09').once.and_return('TIME')
        Exchange::Helper.assure_time('2011-09-09').should == 'TIME'
      end
    end
    context "with nil" do
      it "should return nil if no default is defined" do
        Exchange::Helper.assure_time(nil).should be_nil
      end
      it "should return the default if the default is defined" do
        Exchange::Helper.assure_time(nil, :default => :now).should == Time.now
      end
    end
  end
end
