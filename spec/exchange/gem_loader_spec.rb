# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::Gemloader" do

  describe "initializing with a gem name" do
    subject { Exchange::GemLoader.new('some_gem') }
    it "should assign the gem name" do
      expect(subject.instance_variable_get('@gem')).to eq('some_gem')
    end
  end
  
  describe "loading the gem" do
    context "with the gem being bundled" do
      subject { Exchange::GemLoader.new('dalli') }
      it "should not fail" do
        expect { subject.try_load }.not_to raise_error
        expect(defined?(Dalli)).to be_true
      end
    end
    context "with the gem not being bundled" do
      subject { Exchange::GemLoader.new('blabla') }
      it "should fail" do
        expect { subject.try_load }.to raise_error(Exchange::GemLoader::GemNotFoundError, "You specified blabla to be used with Exchange, yet it is not loadable. Please install blabla to be able to use it with Exchange")
        expect(defined?(Blabla)).to be_false
      end
    end
  end
  
end
