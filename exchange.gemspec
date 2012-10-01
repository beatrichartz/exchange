$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'exchange/version'

Gem::Specification.new do |s|
  s.name        = "exchange"
  s.version     = Exchange::VERSION.dup
  s.authors     = ["Beat Richartz"]
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.email       = "attr_accessor@gmail.com"
  s.homepage    = "http://github.com/beatrichartz/exchange"
  s.summary     = "Making currency conversion easy"
  s.description = "Making currency conversion easy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('json', '>= 1.0.0')
end
