# configerator

> This was adapted from the configuration implementation in [Pliny](https://github.com/interagent/pliny).

## Install

```ruby
# file: Gemfile
gem 'configerator'
```

Or...

```bash
$ gem install configerator
```

## Usage

### Methods

* `required :key`
    * Require a key, raise a `KeyError` if key is not supplied on application start up.
* `requied :key, error_on_load: false`
    * Require a key, raise a `RuntimeError` if key is not supplied when `key` is requested.
* `optional :key`
    * Create `key`, set to `nil` if not present.
* `override :key, :value`
    * Create `key`, set to `value` if not present.

### Rails

You can generate a config file, thusly:

```bash
rails generate config
```

This will generate a configuration with tips in comments.

Overtime your config will be customized to your app:

```ruby
# file: config/config.rb
module Config
  extend Configerator

  required :something
  optional :anotherthing
  override :port, 3000, int
end
```

```ruby
# file: config/application.rb
require_relative 'config'
```

### Pure Ruby

**As a module**

```ruby
require 'configerator'

module Config
  extend Configerator

  required :something
  optional :anotherthing
  override :port, 3000, int
end

puts "#{Config.something}, and maybe: '#{Config.anotherthing}', all with #{Config.port}"
```

**Included**

```ruby
require 'configerator'

class Foo
  include Configerator

  def initialize
    required :something
    optional :anotherthing
    override :port, 3000, int
  end

  def run
    puts "Doing %s with %s on %s" % [ something, anotherthing, port ]
  end
end
```

## Development

### Testing

```
# w/ docker
$ docker-compose --rm test

# w/o docker
$ make

# w/o make and docker
$ bundle install
$ bundle exec ruby -Ilib:test ./test/*_test.rb
```
