# configerator

## Usage

### Rails

```ruby
# file: config/config.rb
module Config
  extend Configerator

  required :something
  optional :anotherthing
  override :port, 3000, int
end
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
