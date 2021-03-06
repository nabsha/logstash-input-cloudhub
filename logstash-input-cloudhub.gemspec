Gem::Specification.new do |s|
  s.name          = 'logstash-input-cloudhub'
  s.version       = '2.0.1'
  s.licenses      = ['Apache-2.0']
  s.summary       = 'logstash input plugin for mulesoft cloudhub platform'
  s.description   = 'this plugin has been designed to fetch cloudhub data using Mulesoft CloudHub APIs'
  s.homepage      = 'https://bitbucket.org/gerdau-operations/logstash-input-cloudhub'
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
