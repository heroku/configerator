# configerator

Simple module for implementing environment based configuration following the 12factor pattern.

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
* `namespace :name { optional :key }`
    * Namespaces a collection of keys &mdash; e.g. `name_key`
    * Creates a validator for all defined keys in the block &mdash; e.g. `name?`
    * Skip prefixing namespace for variables and methods with `prefix: false`

```ruby
# namespace example
namespace :aws do
    required :token,  string
    required :secret, string
    optional :region, string
end

# where
aws?

#=> true # if aws_token? && aws_secret? && aws_region?

# namespace without prefix
namespace :etc, prefix: false do
    required :foo, string
    required :bar, string
end

# where
etc?
#=> true # if foo? && bar?
```

### Rails

You can generate a config file, thusly:

```bash
rails generate config
```

This will generate a configuration into `config/config.rb` with tips in comments.

Over time your config will be customized to your app, for example:

```ruby
# file: config/config.rb
require 'configurator'

module Config
  extend Configerator

  required :something,    string
  optional :anotherthing, string
  override :port, 3000,   int
end
```

```ruby
# file: config/application.rb
require_relative 'boot'
require 'rails/all'

# after to let rails framework to load first
require_relative 'config'
```

### Pure Ruby

**As a module**

```ruby
require 'configerator'

module Config
  extend Configerator

  required :something,    string
  optional :anotherthing, string
  override :port, 3000,   int
end

puts "#{Config.something}, and maybe: '#{Config.anotherthing}', all with #{Config.port}"
```

**Included**

```ruby
require 'configerator'

class Foo
  include Configerator

  def initialize
    required :something.    string
    optional :anotherthing, string
    override :port, 3000,   int
  end

  def run
    puts "Doing %s with %s on %s" % [ something, anotherthing, port ]
  end
end
```

### Auto-detecting Dotenv

Configerator will autodetect [Dotenv](https://github.com/bkeepers/dotenv) or
`dotenv-rails` and load it so that its environment variables are available
as soon as the Configerator is ready.

If you wish to bypass this autodetecting because of your apps specific needs,
you can do this by requiring the library directly:

```ruby
require 'configerator/configerator'
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
