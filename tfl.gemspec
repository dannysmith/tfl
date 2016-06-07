# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tfl/version'

Gem::Specification.new do |spec|
  spec.name          = "tfl"
  spec.version       = TFL::VERSION
  spec.authors       = ["James Hill"]
  spec.email         = ["james.f.hill@gmail.com"]
  spec.summary       = %q{Data scraping gem for acquiring TFL journey information from contactless cards}
  spec.homepage      = "https://github.com/jameshill/tfl"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
