#export RUBYOPT = --enable-frozen-string-literal
export AWS_PROFILE = sandpit

all: deps clean build lint install test-unit test-integration doc
ci: deps clean build lint install test-unit doc

deps:
	gem install bundler
	rm -rf .bundle
	bundle install

clean:
	rm -f ruby_aem_aws-*.gem
	rm -rf out

lint:
	rubocop

build: clean
	gem build ruby_aem_aws.gemspec

install: build
	gem install `ls ruby_aem_aws-*.gem`

test-unit:
	rspec test/unit

test-integration: install
	rspec test/integration

test-integration-connection: install
	rspec test/integration/ruby_aem_aws_spec.rb

test-integration-consolidated: install
	rspec test/integration/consolidated

test-integration-full-set: install
	rspec test/integration/full-set

doc:
	yard doc --output-dir doc/api/master/

doc-publish:
	gh-pages --dist doc/

publish:
	gem push `ls ruby_aem_aws-*.gem`

tools:
	npm install -g gh-pages

.PHONY: all ci deps clean build lint install test-unit test-integration test-integration-connection test-integration-consolidated test-integration-full-set doc doc-publish publish tools
