# -*- encoding: utf-8 -*-

require File.dirname(__FILE__) + "/lib/unibits/version"

Gem::Specification.new do |gem|
  gem.name          = "unibits"
  gem.version       = Unibits::VERSION
  gem.summary       = "CLI utility that visualizes a broad range of encodings of a string"
  gem.description   = "CLI utility that Visualizes a broad range of encodings in the terminal. Supports UTF-8, UTF-16LE, UTF-16BE, UTF-32LE, UTF-32BE, US-ASCII, ASCII-8BIT, and a variety of single-byte encodings."
  gem.authors       = ["Jan Lelis"]
  gem.email         = ["hi@ruby.consulting"]
  gem.homepage      = "https://github.com/janlelis/unibits"
  gem.license       = "MIT"

  gem.files         = Dir["{**/}{.*,*}"].select{ |path| File.file?(path) && path !~ /^(pkg|screenshots)/ }
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]
  gem.metadata      = { "rubygems_mfa_required" => "true" }

  gem.add_dependency 'paint', '>= 0.9', '< 3.0'
  gem.add_dependency 'unicode-display_width', '~> 3.3'
  gem.add_dependency 'symbolify', '~> 1.4'
  gem.add_dependency 'characteristics', '~> 1.9'
  gem.add_dependency 'rationalist', '~> 2.0', '>= 2.0.1'

  gem.required_ruby_version = ">= 2.0"
end
