# config_helper

## Usage

### Rails

```ruby
# file: config/config.rb
module Config
  extend ConfigHelper

  required :something
  optional :anotherthing
  override :port, 3000, int
end
```

### Pure Ruby

```ruby
require 'config_helper'

module Config
  extend ConfigHelper

  required :something
  optional :anotherthing
  override :port, 3000, int
end

puts "#{Config.something}, and maybe: '#{Config.anotherthing}', all with #{Config.port}"
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
