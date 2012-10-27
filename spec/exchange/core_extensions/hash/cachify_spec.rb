require 'spec_helper'

describe "Exchange::Cachify" do
  
  describe "cachify" do
    subject { { :bla => 'bli', "BLU" => [2,3] } }
    it "should marshal dump" do
      subject.cachify.should == "\x04\b{\a:\bblaI\"\bbli\x06:\x06EFI\"\bBLU\x06;\x06F[\ai\ai\b"
    end
  end
  
end