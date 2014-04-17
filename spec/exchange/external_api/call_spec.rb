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
          expect(result).to eq(JSON.load(fixture('api_responses/example_json_api.json')))
        end
      end
      context "with http errors" do
        it "should recall and deliver the result if possible" do
          @count = 0
          expect(@uri_mock).to receive(:open).at_most(3).times do
            @count += 1
            @count == 3 ? double('opened', :read => fixture('api_responses/example_json_api.json')) : raise(OpenURI::HTTPError.new('404', 'URI'))
          end
          Exchange::ExternalAPI::Call.new('JSON_API') do |result|
            expect(result).to eq(JSON.load(fixture('api_responses/example_json_api.json')))
          end
        end
        it "should raise if the maximum recall size is reached" do
          expect(@uri_mock).to receive(:open).at_most(7).times do
            raise OpenURI::HTTPError.new('404', 'URI')
          end
          expect { Exchange::ExternalAPI::Call.new('JSON_API') }.to raise_error(Exchange::ExternalAPI::APIError)
        end
      end
      context "with socket errors" do
        it "should raise an error immediately" do
          expect(@uri_mock).to receive(:open).at_most(7).times.and_raise(SocketError)
          expect { Exchange::ExternalAPI::Call.new('JSON_API') }.to raise_error(Exchange::ExternalAPI::APIError)
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
        expect(result.to_s).to eq(Nokogiri::XML.parse(fixture('api_responses/example_xml_api.xml').sub("\n", '')).to_s)
      end
    end
    context "with http errors" do
      it "should recall and deliver the result if possible" do
        @count = 0
        expect(@uri_mock).to receive(:open).at_most(3).times do
          @count += 1
          @count == 3 ? double('opened', :read => fixture('api_responses/example_xml_api.xml')) : raise(OpenURI::HTTPError.new('404', 'URI'))
        end
        Exchange::ExternalAPI::Call.new('XML_API', :format => :xml) do |result|
          expect(result.to_s).to eq(Nokogiri::XML.parse(fixture('api_responses/example_xml_api.xml').sub("\n", '')).to_s)
        end
      end
      it "should raise if the maximum recall size is reached" do
        expect(@uri_mock).to receive(:open).at_most(7).times do
          raise OpenURI::HTTPError.new('404', 'URI')
        end
        expect { Exchange::ExternalAPI::Call.new('XML_API') }.to raise_error(Exchange::ExternalAPI::APIError)
      end
    end
    context "with socket errors" do
      it "should raise an error immediately" do
        expect(@uri_mock).to receive(:open).once.and_raise(SocketError)
        expect { Exchange::ExternalAPI::Call.new('XML_API', :format => :xml) }.to raise_error(Exchange::ExternalAPI::APIError)
      end
    end
  end
end
