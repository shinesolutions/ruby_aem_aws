require 'yaml'

gem_conf = YAML.load_file('conf/gem.yaml')

Gem::Specification.new do |s|
  s.name              = 'ruby_aem_aws'
  s.version           = gem_conf['version']
  s.platform          = Gem::Platform::RUBY
  s.authors           = ['Shine Solutions']
  s.email             = ['opensource@shinesolutions.com']
  s.homepage          = 'https://github.com/shinesolutions/ruby_aem_aws'
  s.summary           = 'AEM on AWS API Ruby client'
  s.description       = 'ruby_aem_aws is a Ruby client for Shine Solutions Adobe Experience Manager (AEM) Platform on AWS'
  s.license           = 'Apache-2.0'
  s.required_ruby_version = '>= 4.0'
  s.files             = Dir.glob('{conf,lib}/**/*')
  s.require_paths     = ['lib']

  s.add_runtime_dependency 'aws-sdk-autoscaling', '1.168.0'
  s.add_runtime_dependency 'aws-sdk-cloudformation', '1.160.0'
  s.add_runtime_dependency 'aws-sdk-cloudwatch', '1.149.0'
  s.add_runtime_dependency 'aws-sdk-cloudwatchlogs', '1.165.0'
  s.add_runtime_dependency 'aws-sdk-dynamodb', '1.175.0'
  s.add_runtime_dependency 'aws-sdk-ec2', '1.655.0'
  s.add_runtime_dependency 'aws-sdk-elasticloadbalancingv2', '1.159.0'
  s.add_runtime_dependency 'aws-sdk-sns', '1.121.0'
  s.add_runtime_dependency 'aws-sdk-s3', '1.233.2'
  s.add_runtime_dependency 'retries', '0.0.5'
  s.add_runtime_dependency 'tuples', '0.1.0'

  s.add_development_dependency 'rspec', '3.13.2'
  s.add_development_dependency 'yard', '0.9.45'
end
