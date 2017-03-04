# -*- encoding: utf-8 -*-

require File.dirname(__FILE__) + "/lib/unicolors/version"

Gem::Specification.new do |gem|
  gem.name          = "unicolors"
  gem.version       = Unicolors::VERSION
  gem.summary       = "Visualizes Unicode encodings."
  gem.description   = "Visualizes Unicode encodings in the terminal."
  gem.authors       = ["Jan Lelis"]
  gem.email         = ["mail@janlelis.de"]
  gem.homepage      = "https://github.com/janlelis/unicolors"
  gem.license       = "MIT"

  gem.files         = Dir["{**/}{.*,*}"].select{ |path| File.file?(path) && path !~ /^pkg/ }
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'paint', '~> 2.0'
  gem.add_dependency 'unicode-display_width', '~> 1.1'

  gem.required_ruby_version = "~> 2.0"
end
