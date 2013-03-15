# -*- encoding: utf-8 -*-
require File.expand_path('../lib/freebase_api/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Aymeric Brisse"]
  gem.email         = ["aymeric.brisse@mperfect-memory.com"]
  gem.description   = %q{A library to use the Freebase API}
  gem.summary       = %q{Provides access to both a raw-access and an abstract-layer to the Freebase API}
  gem.homepage      = "https://github.com/PerfectMemory/freebase-api"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "freebase-api"
  gem.require_paths = ["lib"]
  gem.version       = FreebaseAPI::VERSION

  gem.add_dependency('httparty', '~> 0.10')
end
