# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::Gemloader" do

  describe "initializing with a gem name" do
    subject { Exchange::GemLoader.new('some_gem') }
    it "should assign the gem name" do
      subject.instance_variable_get('@gem').should == 'some_gem'
    end
  end
  
  describe "loading the gem" do
    context "with the gem being bundled" do
      subject { Exchange::GemLoader.new('dalli') }
      it "should not fail" do
        lambda { subject.try_load }.should_not raise_error
        defined?(Dalli).should be_true
      end
    end
    context "with the gem not being bundled" do
      subject { Exchange::GemLoader.new('blabla') }
      it "should fail" do
        lambda { subject.try_load }.should raise_error(Exchange::GemLoader::GemNotFoundError, "You specified blabla to be used with Exchange, yet it is not loadable. Please install blabla to be able to use it with Exchange")
        defined?(Blabla).should be_false
      end
    end
  end
  
end
