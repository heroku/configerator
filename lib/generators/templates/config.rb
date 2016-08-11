require 'configerator'

module Config
  extend Configerator

  #
  # REQUIREDS - exception is raised for these variables when missing
  #

  # required :foo, string

  # You can also defer raising an error until the key is requested:
  # required :bar, error_on_load: false, string


  #
  # OPTIONALS - value is returned or nil if it wasn't present
  #

  # optional :bar, string


  #
  # OVERRIDES - value is returned or the set default
  #

  override :rack_env,  'development', string
  override :rails_env, 'development', string


  #
  # CLASS METHODS - for calculated/specialized values (its just ruby!)
  #

  # class << self
  #   def app_name
  #     "blammo-#{rails_env}"
  #   end
  # end

  #
  # CASTING TYPES, there are several casting types
  #

  # optional :name,   string         # "blammo"
  # optional :number, int            # 42
  # optional :rate,   float          # 1.23
  # optional :flag,   bool           # true
  # optional :key,    symbol         # :info
  # optional :github, url            # #<URI::HTTP https://github.com/heroku>
  # optional :list,   array(string)  # ["this", "is", "a", "list"]
end
