default: install clean test

install:
	bundle install

clean:
	bundle clean

test:
	bundle exec ruby -Ilib:test ./test/*_test.rb

.PHONY: test
