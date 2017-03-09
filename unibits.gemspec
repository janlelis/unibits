# -*- encoding: utf-8 -*-

require File.dirname(__FILE__) + "/lib/unibits/version"

Gem::Specification.new do |gem|
  gem.name          = "unibits"
  gem.version       = Unibits::VERSION
  gem.summary       = "Visualizes Unicode encodings."
  gem.description   = "Visualizes Unicode encodings in the terminal. Supports UTF-8, UTF-16LE, UTF-16BE, UTF-32LE, UTF-32BE, US-ASCII, and ASCII-8BIT. Comes as CLI command and as Ruby Kernel method."
  gem.authors       = ["Jan Lelis"]
  gem.email         = ["mail@janlelis.de"]
  gem.homepage      = "https://github.com/janlelis/unibits"
  gem.license       = "MIT"

  gem.files         = Dir["{**/}{.*,*}"].select{ |path| File.file?(path) && path !~ /^pkg/ }
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'paint', '>= 0.9', '< 3.0'
  gem.add_dependency 'unicode-display_width', '~> 1.1'
  gem.add_dependency 'unicode-categories', '~> 1.1', '>= 1.1.2'
  gem.add_dependency 'rationalist', '~> 2.0'

  gem.required_ruby_version = "~> 2.0"
end
