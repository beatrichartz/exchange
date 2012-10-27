require 'spec_helper'

describe "Exchange::Cachify" do
  
  describe "cachify" do
    context "with a big decimal" do
      subject { BigDecimal.new("5") }
      it "should marshal dump" do
        subject.cachify.should == "\x04\bu:\x0FBigDecimal\r18:0.5E1"
      end
    end
    context "with a float" do
      subject { 0.4545 }
      it "should marshal dump" do
        subject.cachify.should == "\x04\bf\v0.4545"
      end
    end
    context "with an integer" do
      subject { 45 }
      it "should marshal dump" do
        subject.cachify.should == "\x04\bi2"
      end
    end
  end
  
end