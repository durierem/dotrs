# frozen_string_literal: true

require 'git'
require_relative '../config'
require_relative '../master_tree'

# Internal: Init command
class Init
  include Config

  def initialize(origin)
    @origin = origin
  end

  def perform
    m = %r{/(?<repo>[\w.@:\-~]+)(?:.git)?\z}.match(@origin)
    repo_name = m[:repo].delete_prefix('git')
    Git.clone(@origin, File.join(Dir.home, repo_name))
    Config.change_repo_name(repo_name)

    # Create the src/ directory in the MasterTree to avoid missing directory
    # in future commands
    MasterTree.new(Config.master_tree_path, Dir.home)
  rescue Git::GitExecuteError => e
    abort("dotrs: #{e}")
  end
end
