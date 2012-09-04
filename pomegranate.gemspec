Gem::Specification.new do |s|
  s.name = 'ruby-pomegranate'
  s.version = '0.0.2'
  s.date = '2012-08-30'
  s.summary = "Pomegranate API Wrapper"
  s.description = "Ruby wrapper for TimeSquare2's Pomegranate API"
  s.authors = ["Jake Bellacera"]
  s.email = 'ruby-pomegranate@googlegroups.com'
  s.homepage = 'http://github.com/jakebellacera/ruby-pomegranate'
  s.files = Dir['lib/pomegranate.rb']
  s.required_ruby_version = '>= 1.9.3'
  s.has_rdoc = false

  # Dependencies
  s.add_dependency('ruby-ntlm', '~> 0.0.1')
  s.add_dependency('nokogiri', '~> 1.5.5')
end
