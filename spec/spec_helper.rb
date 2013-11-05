# -*- encoding : utf-8 -*-
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'exchange'
require 'dalli'

module HelperMethods
  def fixture(name)
    File.read(File.dirname(__FILE__) +  "/support/#{name}")
  end
  
  def mock_api(adress, response, count=1)
    @uri_mock = double('uri', :open => double('opened_uri', :read => response))
    URI.should_receive(:parse).with(adress).at_most(count).times.and_return(@uri_mock)
  end
end

RSpec.configuration.include(HelperMethods)
