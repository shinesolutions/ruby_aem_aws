# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Fixed
- Fixed consolidated client connection #10
- Add feature to check for logstream name with hostname in it instead of only using the instance_id #25

## 1.4.0 - 2019-08-14
### Changed
- Changed ASG health check to check ec2 instance state code to determine running component instance [#22]
- Add additional skip for instances which do not have state code 16 which represents a running instance
- Upgrade yard to 0.9.20

## 1.3.0 - 2019-05-23
### Added
- Add new component method get_tags

## 1.2.1 - 2019-05-16
### Changed
- Fix empty line after guard clause Rubocop violations

## 1.2.0 - 2019-04-03
### Added
- Add termination feature for Chaos Monkey & Orchestrator

### Removed
- Remove support for Ruby 2.2
- Remove support for Ruby 2.3

## 1.1.0 - 2018-06-13
### Changed
- Update ec2 resource filter to only get running ec2 instances [#17]

## 1.0.0 - 2018-05-22
### Added
- Add AutoScalingGroup health check support

### Changed
- Restructure modules by architectures, components, and clients

## 0.9.3 - 2018-04-23
### Changed
- Reduce frequency of ASG and ELB client calls

## 0.9.2 - 2018-04-16
### Changed
- Handle AutoScalingGroups describe beyond max records by using next token

## 0.9.1 - 2018-04-11
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
