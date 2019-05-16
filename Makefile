#export RUBYOPT = --enable-frozen-string-literal
export AWS_PROFILE = sandpit

all: deps clean build lint install test-unit test-integration doc
ci: deps clean build lint install doc

clean:
	rm -rf .bundler bin ruby_aem_aws-*.gem out

deps:
	gem install bundler --version=1.17.3
	bundle install --binstubs

lint:
	bundle exec rubocop

build: clean
	gem build ruby_aem_aws.gemspec

install: build
	gem install `ls ruby_aem_aws-*.gem`

test-unit:
	bundle exec rspec test/unit

test-integration: install
	bundle exec rspec test/integration

test-integration-connection: install
	bundle exec rspec test/integration/ruby_aem_aws_spec.rb

test-integration-consolidated: install
	bundle exec rspec test/integration/consolidated

test-integration-full-set: install
	bundle exec rspec test/integration/full-set

doc:
	bundle exec yard doc --output-dir doc/api/master/

doc-publish:
	gh-pages --dist doc/

publish:
	gem push `ls ruby_aem_aws-*.gem`

release:
	rtk release

tools:
	npm install -g gh-pages

.PHONY: all ci deps clean build lint install test-unit test-integration test-integration-connection test-integration-consolidated test-integration-full-set doc doc-publish publish release tools
