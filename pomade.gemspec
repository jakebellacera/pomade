Gem::Specification.new do |s|
  s.name = 'pomade'
  s.version = '0.1.1'
  s.date = '2012-09-04'
  s.summary = "Pomegranate API Wrapper"
  s.description = "Ruby wrapper for TimeSquare2's Pomegranate API"
  s.authors = ["Jake Bellacera"]
  s.email = 'hi@jakebellacera.com'
  s.homepage = 'http://github.com/jakebellacera/pomade'
  s.files = Dir['lib/pomade.rb']
  s.required_ruby_version = '>= 1.9.3'
  s.has_rdoc = false

  # Dependencies
  s.add_dependency('ruby-ntlm', '~> 0.0.1')
  s.add_dependency('nokogiri', '~> 1.5.5')
end
