# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::Cachify" do
  
  describe "cachify" do
    subject { ["hello", 23, :world ] }
    it "should marshal dump" do
      expect(subject.cachify).to eq(Marshal.dump(subject))
    end
  end
  
end
