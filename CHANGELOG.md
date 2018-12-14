### 1.1.1
* Add termination feature for Chaos Monkey & Orchestrator
* Remove support for Ruby 2.2
* Remove support for Ruby 2.3

### 1.1.0
* Update ec2 resource filter to only get running ec2 instances #17

### 1.0.0
* Restructure modules by architectures, components, and clients
* Add AutoScalingGroup health check support

### 0.9.3
* Reduce frequency of ASG and ELB client calls

### 0.9.2
* Handle AutoScalingGroups describe beyond max records by using next token

### 0.9.1
* Add support for AEM Stack Manager Events
* Add feature to get Dispatcher ELB health state
* Add feature for AWS credential handling
* Add feature to determine AEM Author health state
* Add feature to terminate random/all AEM instance(s)
* Add AWS S3, DynamoDB and SNS client
* Fix instance handling while getting health state

### 0.9.0
* Initial version
