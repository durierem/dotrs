# frozen_string_literal: true

require 'socket'
require 'git'
require 'tty-tree'
require_relative 'master_tree'
require_relative 'config'

# Internal: Methods for each of dotrs commands.
module Commands
  class << self
    include Config

    def add(files)
      mt = MasterTree.new(MASTER_TREE_PATH, Dir.home)
      files.each do |file|
        mt.add(file)
      rescue AssertionError => e
        abort("dotrs: #{e}")
      end
    end

    def apply
      MasterTree.new(MASTER_TREE_PATH, Dir.home).link_all
    end

    def init(origin)
      m = %r{/(?<repo>[\w.@:\-~]+)(?:.git)?\z}.match(origin)
      repo_name = m[:repo].delete_prefix('git')
      Git.clone(origin, File.join(Dir.home, repo_name))
      Config.change_repo_name(repo_name)

      # Create the src/ directory in the MasterTree to avoid missing directory
      # in future commands
      MasterTree.new(MASTER_TREE_PATH, Dir.home)
    rescue Git::GitExecuteError => e
      abort("dotrs: #{e}")
    end

    def list(tree: false)
      mt = MasterTree.new(MASTER_TREE_PATH, Dir.home)
      return if mt.empty?

      if tree
        str = TTY::Tree.new(MASTER_TREE_PATH, show_hidden: true).render
        str.delete_prefix!(File.basename(MASTER_TREE_PATH))
        str = "#{Dir.home}#{str}"
        puts(str)
      else
        mt.list.each { |file| puts(file) }
      end
    end

    def remove(files)
      mt = MasterTree.new(MASTER_TREE_PATH, Dir.home)
      files.each do |file|
        mt.remove(file) 
      rescue AssertionError => e
        abort("dotrs: #{e}")
      end
    end

    def pull
      Git.open(REPO_PATH).pull
    rescue Git::GitExecuteError => e
      abort("dotrs: #{e}")
    end

    def push
      repo = Git.open(REPO_PATH)
      begin
        repo.add(all: true)
        repo.commit(compute_commit_message)
        repo.push
      rescue Git::GitExecuteError => e
        repo.reset('HEAD^')
        abort("dotrs: #{e}")
      end
    end

    def diff(short: false)
      Git.open(REPO_PATH).diff('HEAD').each do |file_diff|
        puts(file_diff.path)
        puts(file_diff.patch) unless short
      end
    end

    private

    def compute_commit_message
      msg = String.new("dotrs: push from '#{Socket.gethostname}'\n")
      msg << compute_message(:added)
      msg << compute_message(:changed)
      msg << compute_message(:deleted)
      msg
    end

    def compute_message(status_method)
      return '' if Git.open(REPO_PATH).status.send(status_method).empty?

      result = "\nFile(s) #{status_method}:\n"
      repo = Git.open(REPO_PATH)
      mt_dir = File.basename(MASTER_TREE_PATH)
      repo.status.send(status_method).each_key do |file|
        result += "\t#{file.delete_prefix("#{mt_dir}/")}\n"
      end
      result
    end
  end
end
