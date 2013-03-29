# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::Cachify" do
  
  describe "cachify" do
    subject { ["hello", 23, :world ] }
    it "should marshal dump" do
      subject.cachify.should == Marshal.dump(subject)
    end
  end
  
end
