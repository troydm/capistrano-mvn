# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/mvn/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-mvn"
  spec.version       = Capistrano::Mvn::VERSION
  spec.authors       = ["Dmitry Geurkov (troydm)"]
  spec.email         = ["d.geurkov@gmail.com"]
  spec.description   = %q{maven deployment tasks for capistrano v3}
  spec.summary       = %q{capistrano maven deployment}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "capistrano", "~> 3.0"
  spec.add_dependency "sshkit", "~> 1.2"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
