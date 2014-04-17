# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::Cache::File" do
  subject { Exchange::Cache::File.instance }
  before(:each) do
    Exchange.configuration = Exchange::Configuration.new { |c|
      c.cache      = {
        :subclass => :file,
        :path     => 'STORE/PATH'
      }
    }
  end
  after(:each) do
    Exchange.configuration.reset
  end
  describe "cached" do
    it "should raise an error if no block was given" do
      expect { subject.cached('API_CLASS') }.to raise_error(Exchange::Cache::CachingWithoutBlockError)
    end
    context "when a result is returned" do
      context "with a daily cache" do
        before(:each) do
          expect(subject).to receive(:key).with('API_CLASS', nil).and_return('KEY')
          expect(::File).to receive(:exists?).with('STORE/PATH/KEY').and_return(true)
          expect(::File).to receive(:read).with('STORE/PATH/KEY').and_return 'CONTENT'.cachify
        end
        it "should return the file contents" do
          expect(subject.cached('API_CLASS') { 'something' }).to eq('CONTENT')
        end
        it "should also return plain when asked to" do
          expect(subject.cached('API_CLASS', :plain => true) { 'something' }).to eq('CONTENT'.cachify)
        end
      end
      context "with a monthly cache" do
        before(:each) do
          expect(subject).to receive(:key).with('API_CLASS', an_instance_of(Symbol)).and_return('KEY')
          expect(::File).to receive(:exists?).with('STORE/PATH/KEY').and_return(true)
          expect(::File).to receive(:read).with('STORE/PATH/KEY').and_return 'CONTENT'.cachify
        end
        it "should return the file contents" do
          expect(subject.cached('API_CLASS', :cache_period => :monthly) { 'something' }).to eq('CONTENT')
        end
        it "should also return plain when asked to" do
          expect(subject.cached('API_CLASS', :cache_period => :monthly, :plain => true) { 'something' }).to eq('CONTENT'.cachify)
        end
      end
    end
    context "when no file is cached yet" do
      before(:each) do
        expect(subject).to receive(:key).with('API_CLASS', an_instance_of(Symbol)).at_most(3).times.and_return('KEY')
        expect(::File).to receive(:exists?).with('STORE/PATH/KEY').and_return(false)
        expect(Dir).to receive(:entries).with('STORE/PATH').once.and_return(%W(entry entry2))
        expect(::File).to receive(:delete).with(an_instance_of(String)).twice
        expect(FileUtils).to receive(:mkdir_p).once
        expect(::File).to receive(:open).once
      end
      it "should return the file contents" do
        expect(subject.cached('API_CLASS', :cache_period => :monthly) { 'RESULT' }).to eq('RESULT')
      end
    end
    context "when no result is returned" do
      before(:each) do
        expect(subject).to receive(:key).with('API_CLASS', an_instance_of(Symbol)).at_most(3).times.and_return('KEY')
        expect(::File).to receive(:exists?).with('STORE/PATH/KEY').and_return(false)
        expect(FileUtils).to receive(:mkdir_p).never
        expect(::File).to receive(:open).never
      end
      it "should return the file contents" do
        expect(subject.cached('API_CLASS', :cache_period => :monthly) { '' }).to eq('')
      end
    end
  end
end
