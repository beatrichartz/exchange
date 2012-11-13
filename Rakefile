# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "exchange"
  gem.homepage = "http://github.com/beatrichartz/exchange"
  gem.license = "MIT"
  gem.summary = %Q{Simple Exchange Rate operations for your ruby app}
  gem.description = %Q{The Exchange Gem gives you easy access to currency functions directly on your Numbers. Imagine a conversion as easy as 
    1.in(:eur).to(:usd)
  or even better 
    1.in(:eur).to(:usd, :at => Time.now - 84600)
  which gets you an exchange at the rates of yesterday.}
  gem.email = "exchange_gem@gmail.com"
  gem.authors = ["Beat Richartz"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

task :default => :test

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

require 'yard'
YARD::Rake::YardocTask.new

# RSpec::Core::RakeTask.new(:rcov) do |spec|
#   spec.pattern = 'spec/**/*_spec.rb'
#   spec.rcov = true
# end
