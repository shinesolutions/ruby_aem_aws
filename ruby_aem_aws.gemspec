Gem::Specification.new do |s|
  s.name              = 'ruby_aem_aws'
  s.version           = '0.9.0'
  s.platform          = Gem::Platform::RUBY
  s.authors           = ['Shine Solutions']
  s.email             = ['opensource@shinesolutions.com']
  s.homepage          = 'https://github.com/shinesolutions/ruby_aem_aws'
  s.summary           = 'AEM API Ruby client'
  s.description       = 'ruby_aem_aws is a Ruby client for Shine Solutions Adobe Experience Manager (AEM) Platform on AWS'
  s.license           = 'Apache-2.0'
  s.required_ruby_version = '>= 2.1'
  s.files             = Dir.glob('{conf,lib}/**/*')
  s.require_paths     = ['lib']

  s.add_runtime_dependency 'aws-sdk', '~> 3.0'
  s.add_runtime_dependency 'retries', '~> 0.0.5'

  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'yard', '~> 0.9.5'
end
