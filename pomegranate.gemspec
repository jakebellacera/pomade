Gem::Specification.new do |s|
  s.name = 'ruby-pomegranate'
  s.version = '0.0.1'
  s.date = '2012-08-30'
  s.summary = "Pomegranate API Wrapper"
  s.description = "Ruby wrapper for TimeSquare2's Pomegranate API"
  s.authors = ["Jake Bellacera"]
  s.email = 'hi@jakebellacera.com'
  s.files = Dir['lib/pomegranate.rb']

  # Dependencies
  s.add_dependency('ruby-ntlm', '~> 0.0.1')
  s.add_dependency('nokogiri', '~> 1.5.5')
end
