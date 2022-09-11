#export RUBYOPT = --enable-frozen-string-literal
export AWS_PROFILE = sandpit

all: clean deps build lint install test-unit test-integration doc
ci: clean deps build lint install doc

clean:
	rm -f ruby_aem_aws-*.gem Gemfile.lock

deps:
	gem install bundler --version=2.3.21
	rm -rf .bundle
	bundle install --binstubs

lint:
	bundle exec rubocop lib/ test/
	bundle exec yaml-lint .*.yml conf/*.yaml

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

publish: install
	gem push `ls ruby_aem_aws-*.gem`

release-major:
	rtk release --release-increment-type major

release-minor:
	rtk release --release-increment-type minor

release-patch:
	rtk release --release-increment-type patch

release: release-minor

tools:
	npm install -g gh-pages

.PHONY: all ci deps clean build lint install test-unit test-integration test-integration-connection test-integration-consolidated test-integration-full-set doc doc-publish publish release release-major release-minor release-patch tools
