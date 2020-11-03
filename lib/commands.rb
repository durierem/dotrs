# frozen_string_literal: true

require 'socket'
require 'git'
require 'tty-tree'
require_relative 'master_tree'
require_relative 'config'

# Internal: Methods for each of dotrs commands.
module Commands
  class << self
    Config.load

    def add(files, verbose: false)
      mt = MasterTree.new(Config.master_tree_path, Dir.home)
      files.each do |file|
        mt.add(file)
        puts("#{file} added to tracked files") if verbose
      rescue AssertionError => e
        abort("dotrs: #{e}")
      end
    end

    def apply(verbose: false)
      mt = MasterTree.new(Config.master_tree_path, Dir.home)
      mt.link_all
      return unless verbose

      mt.list.each do |file|
        puts("'#{file}' -> '#{File.join(Config.master_tree_path, file)}'")
      end
    end

    def init(origin)
      m = %r{/(?<repo>[\w.@:\-~]+)(?:.git)?\z}.match(origin)
      repo_name = m[:repo].delete_prefix('git')
      Git.clone(origin, File.join(Dir.home, repo_name))
      Config.change_repo_name(repo_name)

      # Create the src/ directory in the MasterTree to avoid missing directory
      # in future commands
      MasterTree.new(Config.master_tree_path, Dir.home)
    rescue Git::GitExecuteError => e
      abort("dotrs: #{e}")
    end

    def list(tree: false)
      mt = MasterTree.new(Config.master_tree_path, Dir.home)
      return if mt.empty?

      if tree
        str = TTY::Tree.new(Config.master_tree_path, show_hidden: true).render
        str.delete_prefix!(File.basename(Config.master_tree_path))
        str = "#{Dir.home}#{str}"
        puts(str)
      else
        mt.list.each { |file| puts(file) }
      end
    end

    def remove(files, verbose: false)
      mt = MasterTree.new(Config.master_tree_path, Dir.home)
      files.each do |file|
        mt.remove(file)
        puts("#{file} removed from tracked files") if verbose
      rescue AssertionError => e
        abort("dotrs: #{e}")
      end
    end

    def remove_all(verbose: false)
      mt = MasterTree.new(Config.master_tree_path, Dir.home)
      mt.list.each do |file|
        mt.remove(file)
        puts("#{file} removed from tracked files") if verbose
      rescue AssertionError => e
        abort("dotrs: #{e}")
      end
    end

    def pull
      Git.open(Config.repo_path).pull
    rescue Git::GitExecuteError => e
      abort("dotrs: #{e}")
    end

    def push
      repo = Git.open(Config.repo_path)
      begin
        repo.add(all: true)
        repo.commit(compute_commit_message)
        repo.push('origin', repo.current_branch)
      rescue Git::GitExecuteError => e
        repo.reset('HEAD^') unless empty_repo?(Config.repo_path)
        abort("dotrs: #{e}")
      end
    end

    def diff(short: false)
      Git.open(Config.repo_path).diff('HEAD').each do |file_diff|
        puts(file_diff.path)
        puts(file_diff.patch) unless short
      end
    rescue Git::GitExecuteError => e
      abort("dotrs: #{e}")
    end

    private

    def empty_repo?(repo_path)
      Dir.empty?(File.join(repo_path, '.git', 'refs', 'heads'))
    end

    def compute_commit_message
      return 'dotrs: first commit' if empty_repo?(Config.repo_path)

      msg = String.new("dotrs: push from '#{Socket.gethostname}'\n")
      msg << compute_message(:added)
      msg << compute_message(:changed)
      msg << compute_message(:deleted)
      msg
    end

    def compute_message(status_method)
      return '' if Git.open(Config.repo_path).status.send(status_method).empty?

      result = "\n#{status_method.capitalize}:\n"
      repo = Git.open(Config.repo_path)
      repo.status.send(status_method).each_key do |file|
        result += "\t#{File.basename(file)}\n"
      end
      result
    end
  end
end
