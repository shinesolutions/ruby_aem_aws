[![Build Status](https://img.shields.io/travis/shinesolutions/ruby_aem.svg)](http://travis-ci.org/shinesolutions/ruby_aem)
[![Published Version](https://badge.fury.io/rb/ruby_aem.svg)](https://rubygems.org/gems/ruby_aem)

ruby_aem_aws
------------

ruby_aem_aws is a Ruby client for [Adobe Experience Manager (AEM)](http://www.adobe.com/au/marketing-cloud/enterprise-content-management.html) API.
It is written on top of [swagger_aem](https://github.com/shinesolutions/swagger-aem/blob/master/ruby/README.md) and provides resource-oriented API and convenient response handling.

[Versions History](docs/versions.md)

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
