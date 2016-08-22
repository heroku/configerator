module Configerator
  class ConfigGenerator < Rails::Generators::Base
    desc "Creates a Configerator-based file at config/config.rb"

    source_root File.expand_path("../../templates", __FILE__)

    def create_config_file
      copy_file "config.rb", "config/config.rb"
    end
  end
end
