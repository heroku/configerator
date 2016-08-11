require 'configerator'

module Config
  extend Configerator

  #
  # REQUIRED - exception is raised for these variables when missing
  #

  # required :database_url, string

  # You can also defer raising an error until the key is requested:
  # required :database_url, error_on_load: false, string


  #
  # OPTIONAL - value is returned or nil if it wasn't present
  #

  optional :app_name, string


  #
  # OVERRIDE - value is returned or the set default
  #

  override :rack_env,  'development', string
  override :rails_env, 'development', string

  # Other examplse
  # override :database_timeout, 10,    int
  # override :db_pool,          5,     int
  # override :force_ssl,        true,  bool
  # override :port,             5000,  int
  # override :puma_max_threads, 16,    int
  # override :puma_min_threads, 1,     int
  # override :puma_workers,     3,     int
  # override :raise_errors,     false, bool


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
