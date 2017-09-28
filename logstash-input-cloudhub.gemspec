Gem::Specification.new do |s|
  s.name          = 'logstash-input-cloudhub'
  s.version       = '1.3.3'
  s.licenses      = ['Apache License (2.0)']
  s.summary       = 'logstash input plugin for mulesoft cloudhub platform'
  s.description   = 'this plugin has been designed to fetch cloudhub logs using Mulesoft CloudHub Enhanced Log APIs'
  s.homepage      = 'https://bitbucket.org/gerdau/logstash-input-cloudhub'
  s.authors       = ['Leonardo Mello Gaona']
  s.email         = 'leonardo.gaona@sciensa.com'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md', 'Gemfile','LICENSE','NOTICE.TXT']

   # Tests
  s.test_files = s.files.grep(/_test.rb$/)

  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "input" }

  s.add_runtime_dependency "logstash-core-plugin-api", ">= 1.60", "<= 2.99"
  s.add_runtime_dependency 'logstash-codec-plain'
  s.add_runtime_dependency 'stud', '>= 0.0.22'

  s.add_development_dependency "rspec-mocks"
  s.add_development_dependency "rspec"
end
