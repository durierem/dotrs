# frozen_string_literal: true

require 'toml-rb'

CONFIG_FILE_PATH = File.join(Dir.home, '.config', 'dotrs', 'config.toml')

# Internal: Internal settings for dotrs.
module Config
  class << self
    attr_accessor :repo_path, :master_tree_path

    def load
      @config_hash = TomlRB.load_file(CONFIG_FILE_PATH, symbolize_keys: true)
      @repo_path = File.join(Dir.home, @config_hash[:repository][:name])
      @master_tree_path = File.join(@repo_path, 'src')
    end

    def change_repo_name(repo_name)
      @config_hash[:repository][:name] = repo_name
      File.open(CONFIG_FILE_PATH, 'w') { |f| f.write(TomlRB.dump(@config_hash)) }
    end
  end
end
