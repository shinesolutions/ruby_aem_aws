[![Build Status](https://img.shields.io/travis/shinesolutions/ruby_aem.svg)](http://travis-ci.org/shinesolutions/ruby_aem)
[![Published Version](https://badge.fury.io/rb/ruby_aem.svg)](https://rubygems.org/gems/ruby_aem)

ruby_aem_aws
------------

ruby_aem_aws is a Ruby client for Shine Solutions [Adobe Experience Manager (AEM)](http://www.adobe.com/au/marketing-cloud/enterprise-content-management.html) (AEM) Platform on AWS.

<!--
[Versions History](docs/versions.md)
-->

Install
-------

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
    
    