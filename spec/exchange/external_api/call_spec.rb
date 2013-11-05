# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Exchange::ExternalAPI::Call" do
  before(:all) do
    Exchange.configuration = Exchange::Configuration.new{|c|
      c.cache = {
        :subclass => :no_cache
      }
    }
  end
  after(:all) do
    Exchange.configuration.reset
  end
  describe "initialization" do
    context "with a json api" do
      before(:each) do
        mock_api('JSON_API', fixture('api_responses/example_json_api.json'), 7)
      end
      it "should call the api and yield a block with the result" do
        Exchange::ExternalAPI::Call.new('JSON_API') do |result|
          result.should == JSON.load(fixture('api_responses/example_json_api.json'))
        end
      end
      context "with http errors" do
        it "should recall and deliver the result if possible" do
          @count = 0
          @uri_mock.should_receive(:open).at_most(3).times.and_return do
            @count += 1
            @count == 3 ? double('opened', :read => fixture('api_responses/example_json_api.json')) : raise(OpenURI::HTTPError.new('404', 'URI'))
          end
          Exchange::ExternalAPI::Call.new('JSON_API') do |result|
            result.should == JSON.load(fixture('api_responses/example_json_api.json'))
          end
        end
        it "should raise if the maximum recall size is reached" do
          @uri_mock.should_receive(:open).at_most(7).times.and_return do
            raise OpenURI::HTTPError.new('404', 'URI')
          end
          lambda { Exchange::ExternalAPI::Call.new('JSON_API') }.should raise_error(Exchange::ExternalAPI::APIError)
        end
      end
      context "with socket errors" do
        it "should raise an error immediately" do
          @uri_mock.should_receive(:open).at_most(7).times.and_raise(SocketError)
          lambda { Exchange::ExternalAPI::Call.new('JSON_API') }.should raise_error(Exchange::ExternalAPI::APIError)
        end
      end
    end
  end
  context "with an xml api" do
    before(:each) do
      mock_api('XML_API', fixture('api_responses/example_xml_api.xml'), 7)
    end
    it "should call the api and yield a block with the result" do
      Exchange::ExternalAPI::Call.new('XML_API', :format => :xml) do |result|
        result.to_s.should == Nokogiri::XML.parse(fixture('api_responses/example_xml_api.xml').sub("\n", '')).to_s
      end
    end
    context "with http errors" do
      it "should recall and deliver the result if possible" do
        @count = 0
        @uri_mock.should_receive(:open).at_most(3).times.and_return do
          @count += 1
          @count == 3 ? double('opened', :read => fixture('api_responses/example_xml_api.xml')) : raise(OpenURI::HTTPError.new('404', 'URI'))
        end
        Exchange::ExternalAPI::Call.new('XML_API', :format => :xml) do |result|
          result.to_s.should == Nokogiri::XML.parse(fixture('api_responses/example_xml_api.xml').sub("\n", '')).to_s
        end
      end
      it "should raise if the maximum recall size is reached" do
        @uri_mock.should_receive(:open).at_most(7).times.and_return do
          raise OpenURI::HTTPError.new('404', 'URI')
        end
        lambda { Exchange::ExternalAPI::Call.new('XML_API') }.should raise_error(Exchange::ExternalAPI::APIError)
      end
    end
    context "with socket errors" do
      it "should raise an error immediately" do
        @uri_mock.should_receive(:open).once.and_raise(SocketError)
        lambda { Exchange::ExternalAPI::Call.new('XML_API', :format => :xml) }.should raise_error(Exchange::ExternalAPI::APIError)
      end
    end
  end
end
