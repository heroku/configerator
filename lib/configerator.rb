require 'configerator/configerator'

# We want to detect if dotenv is in the environment and loaded it right after
# the library is loaded so that if any configurations rely on it, the
# .env environment variables will be available immediately.
#
# In order to bypass this autoloading of Dotenv, the user can load the library
# directly:
#
# require 'configerator/configerator'

begin
  require 'dotenv/rails-now'
rescue LoadError, NameError
  # dotenv-rails not available
end

begin
  # fallback to Dotenv
  require 'dotenv'
  Dotenv.load
rescue LoadError
  # dotenv not available
end unless defined?(Dotenv::Railtie)
