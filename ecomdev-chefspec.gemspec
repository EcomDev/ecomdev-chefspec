# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ecomdev/chefspec/version'

Gem::Specification.new do |spec|
  spec.name          = 'ecomdev-chefspec'
  spec.version       = EcomDev::ChefSpec::VERSION
  spec.authors       = ['Ivan Chepurnyi']
  spec.email         = ['ivan.chepurnyi@ecomdev.org']
  spec.summary       = 'A collection of helpers for chef spec, to make easier writing recipe specs'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/IvanChepurnyi/ecomdev-chefspec'
  spec.license       = 'GPLv3'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'chefspec', '~> 4.0'
  spec.add_dependency 'json'
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
