[![Build Status](https://github.com/shinesolutions/ruby_aem_aws/workflows/CI/badge.svg)](https://github.com/shinesolutions/ruby_aem_aws/actions?query=workflow%3ACI)
[![Published Version](https://badge.fury.io/rb/ruby_aem.svg)](https://rubygems.org/gems/ruby_aem)
[![Known Vulnerabilities](https://snyk.io/test/github/shinesolutions/ruby_aem_aws/badge.svg)](https://snyk.io/test/github/shinesolutions/ruby_aem_aws)

ruby_aem_aws
------------

ruby_aem_aws is a Ruby client for Shine Solutions [Adobe Experience Manager (AEM)](http://www.adobe.com/au/marketing-cloud/enterprise-content-management.html) Platform on AWS.

This library provides an API which enables the interaction with the platform via Ruby language, allowing a deep integration with a number of Ruby-based tools such as [Puppet](https://puppet.com/) and [InSpec](https://www.inspec.io/).

ruby_aem_aws is part of [AEM OpenCloud](https://aemopencloud.io) platform.

Installation
------------

    gem install ruby_aem_aws

Usage
-----

Initialise client:

    require 'ruby_aem_aws'

    aem = RubyAemAws::AemAws.new({
    })

    TODO

Required parameters:

- `AWS_PROFILE` eg `sandpit`

Optional parameters:

- `AWS_REGION` eg `ap-southeast-2`
- `STACK_PREFIX` eg `bob`
