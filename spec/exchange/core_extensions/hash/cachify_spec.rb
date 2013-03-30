# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::Cachify" do
  
  describe "cachify" do
    subject { { :bla => 'bli', "BLU" => [2,3] } }
    it "should marshal dump" do
      subject.cachify.should == Marshal.dump(subject)
    end
  end
  
end
