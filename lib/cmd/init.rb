# frozen_string_literal: true

require 'git'
require_relative '../config'
require_relative '../master_tree'

# Internal: Clone a remote repository into the user's home directory.
class Init
  include Config

  # Internal: Initialize the Init command.
  #
  # remote - The String URL of the remote repository to clone.
  def initialize(remote)
    @remote = remote
  end

  def perform
    # Match the repository name in the remote URL
    m = %r{/(?<repo>[\w.@:\-~]+)(?:.git)?\z}.match(@remote)
    repo_name = m[:repo].delete_prefix('git')

    # Clone the remote
    Git.clone(@remote, File.join(Dir.home, repo_name))

    # Update the configuration file with the newly cloned repository name
    Config.change_repo_name(repo_name)

    # Create the src/ directory in the MasterTree to avoid missing directory
    # in future commands
    MasterTree.new(Config.master_tree_path, Dir.home)
  rescue Git::GitExecuteError => e
    abort("dotrs: #{e}")
  end
end
