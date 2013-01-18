# -*- encoding: utf-8 -*-
require File.expand_path('../lib/freebase_api/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Aymeric Brisse"]
  gem.email         = ["aymeric.brisse@mperfect-memory.com"]
  gem.description   = %q{A library to use the Freebase API}
  gem.summary       = %q{A library to use the Freebase API}
  gem.homepage      = "https://github.com/PerfectMemory/freebase-api"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "freebase-api"
  gem.require_paths = ["lib"]
  gem.version       = FreebaseAPI::VERSION

  gem.add_dependency('httparty', '~> 0.10')

  gem.add_development_dependency('rake', '~> 10.0')
  gem.add_development_dependency('rspec', '~> 2.12')
  gem.add_development_dependency('yard', '~> 0.8')
  gem.add_development_dependency('redcarpet', '~> 2.2')
end
