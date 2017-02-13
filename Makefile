default: install clean test

install:
	bundle install

clean:
	bundle clean

test:
	bundle exec rspec -fd ./spec/

spec: test

regression:
	docker-compose run test
	docker-compose run test_2_0
	docker-compose run test_2_1
	docker-compose run test_2_2
	docker-compose run test_2_3

.PHONY: test
