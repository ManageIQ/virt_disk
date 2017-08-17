# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'virt_disk/version'

Gem::Specification.new do |spec|
  spec.name          = "virt_disk"
  spec.version       = VirtDisk::VERSION
  spec.authors       = ["Mo Morsi"]
  spec.email         = ["mmorsi@redhat.com"]

  spec.summary       = "Virtual Block Device Implementation"
  spec.description   = %q{
  }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "binary_struct"
  spec.add_dependency "uuidtools"
  spec.add_dependency "log_decorator"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "yard"
end
