require 'spec_helper'

describe "Exchange::Cachify" do
  
  describe "cachify" do
    subject { "bla" }
    it "should marshal dump" do
      subject.cachify.should == Marshal.dump(subject)
    end
  end
  
  describe "decachify" do
    context "with a string" do
      subject { "blu" }
      it "should work" do
        subject.cachify.decachify.should == subject
      end
    end
    context "with a hash" do
      subject { {:bla => "blu", "bli" => :blo, nil => [5,6]} }
      it "should work" do
        subject.cachify.decachify.should == subject
      end
    end
    context "with a symbol" do
      subject { :blu }
      it "should work" do
        subject.cachify.decachify.should == subject
      end
    end
    context "with an array" do
      subject { [2, 2.3, "blu", :bli, BigDecimal.new("3.345345")] }
      it "should work" do
        subject.cachify.decachify.should == subject
      end
    end
    context "with numeric" do
      context "big decimal" do
        subject { BigDecimal.new("33.3333333", 3) }
        it "should work" do
          subject.cachify.decachify.should == subject
        end
      end
      context "integer" do
        subject { 33 }
        it "should work" do
          subject.cachify.decachify.should == subject
        end
      end
      context "float" do
        subject { 33.33333333 }
        it "should work" do
          subject.cachify.decachify.should == subject
        end
      end
    end
  end
  
end