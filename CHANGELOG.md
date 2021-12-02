# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.1] - 2021-12-02
### Fixed
- Fix CloudWatchClient log events retrieval to handle changes in AWS response payload pagination

## [2.2.0] - 2021-11-22
### Added
- Add aws_profile environment variable as a fallback when initialising the client

## [2.1.0] - 2021-11-19
### Added
- Add STS support with session token handling when initialising credential

### Fixed
- Fix typo with secret access key lowercase env var name

## [2.0.1] - 2021-10-06
### Added
- Add publish and release-* GH Actions

### Changed
- Upgrade yard to 0.9.26

## [2.0.0] - 2020-11-24
### Added
- Add exception rescue while describing the tags of an ELB if ELB was deleted in the meantime [#24]

### Changed
- Replaced Classic Load Balancer Client with Application Load Balancer Client [#30]
- Replaced Classic Load Balancer health state verifier with an Application Load Balancer health state verifier  [#30]

## [1.5.0] - 2020-03-01
### Added
- Add new feature to read AWS Region from AWS environment variable `AWS_DEFAULT_REGION` [shinesolutions/inspec-aem-aws#42]
- Add new feature to read AWS Region from AWS environment variable `AWS_REGION` [shinesolutions/inspec-aem-aws#42]

### Changed
- Change expected config parameter `region` to `aws_region` to keep consistency

### Fixed
- Fixed consolidated client connection [#10]
- Fix documentation errors

## [1.4.0] - 2019-08-14
### Changed
- Changed ASG health check to check ec2 instance state code to determine running component instance [#22]
- Add additional skip for instances which do not have state code 16 which represents a running instance
- Upgrade yard to 0.9.20

## [1.3.0] - 2019-05-23
### Added
- Add new component method get_tags

## [1.2.1] - 2019-05-16
### Changed
- Fix empty line after guard clause Rubocop violations

## [1.2.0] - 2019-04-03
### Added
- Add termination feature for Chaos Monkey & Orchestrator

### Removed
- Remove support for Ruby 2.2
- Remove support for Ruby 2.3

## [1.1.0] - 2018-06-13
### Changed
- Update ec2 resource filter to only get running ec2 instances [#17]

## [1.0.0] - 2018-05-22
### Added
- Add AutoScalingGroup health check support

### Changed
- Restructure modules by architectures, components, and clients

## [0.9.3] - 2018-04-23
### Changed
- Reduce frequency of ASG and ELB client calls

## [0.9.2] - 2018-04-16
### Changed
- Handle AutoScalingGroups describe beyond max records by using next token

## [0.9.1] - 2018-04-11
### Added
- Add support for AEM Stack Manager Events
- Add feature to get Dispatcher ELB health state
- Add feature for AWS credential handling
- Add feature to determine AEM Author health state
- Add feature to terminate random/all AEM instance(s)
- Add AWS S3, DynamoDB and SNS client

### Changed
- Fix instance handling while getting health state

## 0.9.0 - 2018-01-11
### Added
- Initial version

[#10]: https://github.com/shinesolutions/ruby_aem_aws/issues/10
[#17]: https://github.com/shinesolutions/ruby_aem_aws/issues/17
[#22]: https://github.com/shinesolutions/ruby_aem_aws/issues/22
[#24]: https://github.com/shinesolutions/ruby_aem_aws/issues/24
[#30]: https://github.com/shinesolutions/ruby_aem_aws/issues/30

[2.2.1]: https://github.com/shinesolutions/ruby_aem_aws/compare/2.2.0...2.2.1
[2.2.0]: https://github.com/shinesolutions/ruby_aem_aws/compare/2.1.0...2.2.0
[2.1.0]: https://github.com/shinesolutions/ruby_aem_aws/compare/2.0.1...2.1.0
[2.0.1]: https://github.com/shinesolutions/ruby_aem_aws/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/shinesolutions/ruby_aem_aws/compare/1.5.0...2.0.0
[1.5.0]: https://github.com/shinesolutions/ruby_aem_aws/compare/1.4.0...1.5.0
[1.4.0]: https://github.com/shinesolutions/ruby_aem_aws/compare/1.3.0...1.4.0
[1.3.0]: https://github.com/shinesolutions/ruby_aem_aws/compare/1.2.1...1.3.0
[1.2.1]: https://github.com/shinesolutions/ruby_aem_aws/compare/1.2.0...1.2.1
[1.2.0]: https://github.com/shinesolutions/ruby_aem_aws/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/shinesolutions/ruby_aem_aws/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/shinesolutions/ruby_aem_aws/compare/0.9.3...1.0.0
[0.9.3]: https://github.com/shinesolutions/ruby_aem_aws/compare/0.9.2...0.9.3
[0.9.2]: https://github.com/shinesolutions/ruby_aem_aws/compare/0.9.1...0.9.2
[0.9.1]: https://github.com/shinesolutions/ruby_aem_aws/compare/0.9.0...0.9.1
