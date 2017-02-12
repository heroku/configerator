default: install clean test

install:
	bundle install

clean:
	bundle clean

test:
	bundle exec rspec -fd ./spec/

spec: test

.PHONY: test
