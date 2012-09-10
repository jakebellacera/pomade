# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pomade/version'

Gem::Specification.new do |gem|
  gem.name          = "pomade"
  gem.version       = Pomade::VERSION
  gem.authors       = ["Jake Bellacera"]
  gem.email         = ["hi@jakebellacera.com"]
  gem.description   = "Pomegranate API Wrapper"
  gem.summary       = "Ruby wrapper for TimesSquare2's Pomegranate API"
  gem.homepage      = "http://github.com/jakebellacera/pomade"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('ruby-ntlm', '~> 0.0.1')
  gem.add_dependency('nokogiri', '~> 1.5.5')
end
