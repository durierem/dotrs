# frozen_string_literal: true

require 'toml-rb'

CONFIG_FILE_PATH = File.join(Dir.home, '.config', 'dotrs', 'config')
CONFIG_HASH = TomlRB.load_file(CONFIG_FILE_PATH, symbolize_keys: true)

# Internal: Internal settings for dotrs.
module Config
  REPO_PATH = File.join(Dir.home, CONFIG_HASH[:repository][:name])
  MASTER_TREE_PATH = File.join(REPO_PATH, 'src')

  class << self
    def change_repo_name(repo_name)
      config_hash = CONFIG_HASH
      config_hash[:repository][:name] = repo_name
      File.open(CONFIG_FILE_PATH, 'w') { |f| f.write(TomlRB.dump(config_hash)) }
    end
  end
end
