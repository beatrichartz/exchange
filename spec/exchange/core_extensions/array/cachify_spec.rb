require 'spec_helper'

describe "Exchange::Cachify" do
  
  describe "cachify" do
    subject { ["hello", 23, :world ] }
    it "should marshal dump" do
      subject.cachify.should == "\x04\b[\bI\"\nhello\x06:\x06EFi\x1C:\nworld"
    end
  end
  
end