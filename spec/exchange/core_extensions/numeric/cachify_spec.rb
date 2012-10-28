require 'spec_helper'

describe "Exchange::Cachify" do
  
  describe "cachify" do
    context "with a big decimal" do
      subject { BigDecimal.new("5") }
      it "should marshal dump" do
        subject.cachify.should == Marshal.dump(subject)
      end
    end
    context "with a float" do
      subject { 0.4545 }
      it "should marshal dump" do
        subject.cachify.should == Marshal.dump(subject)
      end
    end
    context "with an integer" do
      subject { 45 }
      it "should marshal dump" do
        subject.cachify.should == Marshal.dump(subject)
      end
    end
  end
  
end