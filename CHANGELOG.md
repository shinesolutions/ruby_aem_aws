# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2019-04-03

### Added
- Add termination feature for Chaos Monkey & Orchestrator

### Removed
- Remove support for Ruby 2.2
- Remove support for Ruby 2.3

## [1.1.0] - 2018-06-13

### Changed
- Update ec2 resource filter to only get running ec2 instances #17

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

## [0.9.0] - 2018-01-11

### Added
- Initial version
