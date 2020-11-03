# frozen_string_literal: true

require 'toml-rb'

CONFIG_FILE_PATH = File.join(Dir.home, '.config', 'dotrs', 'config.toml')

# Internal: Provide a centralized configuration.
#
# This modules allows to read and write the configuration file and serves as a
# centralized way to retrieve user defined options surch as --verbose.
#
# The configuration file can be loaded with load_config_file.
#
# User defined options are accessible as the option attribute. It is initially
# empty and must be set externally.
module Config
  class << self
    attr_reader :repo_path, :master_tree_path
    attr_accessor :options

    def load_config_file
      config_hash = TomlRB.load_file(CONFIG_FILE_PATH, symbolize_keys: true)

      @repo_path = File.join(Dir.home, config_hash[:repository][:name])
      @master_tree_path = File.join(@repo_path, 'src')
    end

    def change_repo_name(repo_name)
      config_hash = TomlRB.load_file(CONFIG_FILE_PATH, symbolize_keys: true)
      config_hash[:repository][:name] = repo_name
      File.open(CONFIG_FILE_PATH, 'w') { |f| f.write(TomlRB.dump(config_hash)) }
    end
  end
end
