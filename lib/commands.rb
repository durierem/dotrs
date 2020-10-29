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
        begin
          mt.add(file)
        rescue AssertionError
          abort("dotrs: invalid file '#{file}'")
        rescue Errno::EACCES
          abort('dotrs: insufficient permission')
        end
      end
    end

    def apply
      MasterTree.new(MASTER_TREE_PATH, Dir.home).link_all
    end

    def init(origin)
      Git.clone(origin, REPO_PATH)
    rescue Git::GitExecuteError
      abort('dotrs: an error occured while cloning')
    end

    def list(tree: false)
      if tree
        puts(TTY::Tree.new(MASTER_TREE_PATH, show_hidden: true).render)
      else
        mt = MasterTree.new(MASTER_TREE_PATH, Dir.home)
        mt.list.each { |file| puts(file) }
      end
    end

    def remove(files)
      mt = MasterTree.new(MASTER_TREE_PATH, Dir.home)
      files.each do |file|
        begin
          mt.remove(file)
        rescue AssertionError
          abort("dotrs: invalid file '#{file}'")
        end
      end
    end

    def pull
      Git.open(REPO_PATH).pull
    rescue Git::GitExecuteError
      abort('dotrs: an error occured while pulling')
    end

    def push
      repo = Git.open(REPO_PATH)
      begin
        repo.add(all: true)
        repo.commit(compute_commit_message)
        repo.push
      rescue Git::GitExecuteError, Interrupt
        repo.reset('HEAD^')
        abort('dotrs: an error occured while pushing')
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
      mt_dir = MASTER_TREE_PATH.delete_prefix("#{REPO_PATH}/")
      repo.status.send(status_method).each_key do |file|
        result += "\t#{file.delete_prefix("#{mt_dir}/")}\n"
      end
      result
    end
  end
end
