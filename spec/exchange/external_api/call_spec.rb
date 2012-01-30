require 'spec_helper'

describe "Exchange::ExternalAPI::Call" do
  before(:all) do
    Exchange::Configuration.cache = false
  end
  describe "initialization" do
    context "with a json api" do
      before(:each) do
        mock_api('JSON_API', fixture('api_responses/example_json_api.json'))
      end
      it "should call the api and yield a block with the result" do
        Exchange::ExternalAPI::Call.new('JSON_API') do |result|
          result.should == JSON.load(fixture('api_responses/example_json_api.json'))
        end
      end
      #context "with http errors" do
        #let(:opened_uri) { mock('uri', :read => fixture('api_responses/example_xml_api.xml'))}
        # it "should recall as many times as specified in the options" do
        #   URI.should_receive(:parse).with('JSON_API').and_return(uri_mock)
        #   Exchange::ExternalAPI::Call.new('JSON_API') do |result|
        #     result.should == JSON.load(fixture('api_responses/example_json_api.json'))
        #   end
        # end
        # it "should raise errors if the maximum call repetition is reached" do
        #   URI.stub_chain :parse, :open, :read => OpenURI::HTTPError.new
        #   uri_mock.should_receive(:open).at_most(5).times.and_raise(OpenURI::HTTPError)
        #   lambda { Exchange::ExternalAPI::Call.new('JSON_API') }.should raise_error(Exchange::ExternalAPI::APIError)
        # end
      #end
      context "with socket errors" do
        it "should raise an error immediately" do
          @uri_mock.should_receive(:open).at_most(5).times.and_raise(SocketError)
          lambda { Exchange::ExternalAPI::Call.new('JSON_API') }.should raise_error(Exchange::ExternalAPI::APIError)
        end
      end
    end
  end
  context "with an xml api" do
    before(:each) do
      mock_api('XML_API', fixture('api_responses/example_xml_api.xml'))
    end
    it "should call the api and yield a block with the result" do
      Exchange::ExternalAPI::Call.new('XML_API', :format => :xml) do |result|
        result.to_s.should == Nokogiri.parse(fixture('api_responses/example_xml_api.xml')).to_s
      end
    end
    # context "with http errors" do
    #   let(:error_mock) { mock('opened_uri') }
    #   it "should recall as many times as specified in the options" do
    #     URI.stub! :parse => OpenURI::HTTPError.new
    #     Exchange::ExternalAPI::Call.new('XML_API', :format => :xml) do |result|
    #       result.to_s.should == Nokogiri.parse(fixture('api_responses/example_xml_api.xml')).to_s
    #     end
    #   end
    #   it "should raise errors if the maximum call repetition is reached" do
    #     URI.stub! :parse => OpenURI::HTTPError.new
    #     lambda { Exchange::ExternalAPI::Call.new('XML_API', :format => :xml) }.should raise_error(Exchange::ExternalAPI::APIError)
    #   end
    # end
    context "with socket errors" do
      it "should raise an error immediately" do
        @uri_mock.should_receive(:open).once.and_raise(SocketError)
        lambda { Exchange::ExternalAPI::Call.new('XML_API', :format => :xml) }.should raise_error(Exchange::ExternalAPI::APIError)
      end
    end
  end
end