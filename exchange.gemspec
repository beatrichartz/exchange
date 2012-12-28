# -*- encoding: utf-8 -*-
$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'exchange/base'

Gem::Specification.new do |s|
  s.name              = "exchange"
  s.version           = Exchange::VERSION
  s.authors           = ["Beat Richartz"]
  s.date              = "2012-10-09"
  s.description       = "The Exchange Gem gives you easy access to currency functions directly on your Numbers. Imagine a conversion as easy as \n    1.in(:eur).to(:usd)  or even better \n    1.in(:eur).to(:usd, :at => Time.now - 84600)\n  which gets you an exchange at the rates of yesterday."
  s.email             = "exchange_gem@gmail.com"
  s.homepage          = "http://github.com/beatrichartz/exchange"
  s.licenses          = ["MIT"]
  s.require_paths     = ["lib"]
  s.rubygems_version  = "1.8.24"
  s.summary           = "Simple Exchange Rate operations for your ruby app"
  
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- spec/*`.split("\n")
  s.executables       = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths     = ["lib"]
  
  s.add_dependency             "nokogiri", ">= 1.0.0"
  s.add_development_dependency "yard", ">= 0.7.4"
  s.add_development_dependency "bundler", ">= 1.0.0"
end

