# frozen_string_literal: true

require 'toml-rb'

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
    # Internal: The String path to the configuration file.
    CONFIG_PATH = File.join(Dir.home, '.config', 'dotrs', 'config.toml')

    # Internal: The default local repository name.
    DEFAULT_REPO_NAME = '.dotfiles'

    private_constant :CONFIG_PATH, :DEFAULT_REPO_NAME

    # Internal: Get the String path to the local repository.
    attr_reader :repo_path

    # Internal: Get the String master tree's path.
    attr_reader :master_tree_path

    # Internal: Get/Set the options Hash
    attr_accessor :options

    # Internal: Load the configuration from the configuration file.
    #
    # Returns nothing.
    def load_config_file
      unless File.exist?(CONFIG_PATH)
        FileUtils.mkdir_p(File.dirname(CONFIG_PATH))
        FileUtils.touch(CONFIG_PATH)
        change_repo_name(DEFAULT_REPO_NAME)
      end

      config_hash = TomlRB.load_file(CONFIG_PATH, symbolize_keys: true)

      @repo_path = File.join(Dir.home, config_hash[:repository][:name])
      @master_tree_path = File.join(@repo_path, 'src')
    end

    # Internal: Update the local repository name in the configuration file.
    #
    # Returns nothing.
    def change_repo_name(repo_name)
      config_hash = { repository: { name: repo_name } }
      File.write(CONFIG_PATH, TomlRB.dump(config_hash))
    end
  end
end
