Gem::Specification.new do |s|
  s.name        = 'configerator'
  s.version     = '0.0.4'
  s.summary     = 'Configerator: A Config Helper'
  s.description = 'Simple module for implementing environment based configuration adapted from Pliny and following the 12factor pattern.'
  s.authors     = ['Joshua Mervine',     'Reid MacDonald']
  s.email       = ['joshua@mervine.net', 'reidmix@gmail.com']
  s.files       = `git ls-files -- lib/*`.split("\n")
  s.test_files  = `git ls-files -- test/*`.split("\n")
  s.homepage    = 'https://github.com/heroku/configerator'
  s.license     = 'MIT'
end
