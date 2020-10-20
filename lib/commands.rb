# frozen_string_literal: true

require 'socket'
require 'git'
require_relative 'master_tree'
require_relative 'config'

# Internal: Methods for each of dotrs' commands.
module Commands
  class << self
    include Config

    def add(files)
      mt = MasterTree.new(REPO_PATH, Dir.home)
      files.each do |file|
        begin
          mt.add(file)
        rescue AssertionError
          abort("dotrs: invalid file '#{file}'.")
        end
      end
    end

    def apply
      MasterTree.new(REPO_PATH, Dir.home).link_all
    end

    def init(origin)
      Git.clone(origin, REPO_PATH)
    rescue Git::GitExecuteError
      abort('dotrs: an error occured while cloning.')
    end

    def list
      mt = MasterTree.new(REPO_PATH, Dir.home)
      mt.list.each { |file| puts(file) }
    end

    def remove(files)
      mt = MasterTree.new(REPO_PATH, Dir.home)
      files.each do |file|
        begin
          mt.remove(file)
        rescue AssertionError
          abort("dotrs: invalid file '#{file}'.")
        end
      end
    end

    def pull
      Git.open(REPO_PATH).pull
    rescue Git::GitExecuteError
      abort('dotrs: an error occured while pulling.')
    end

    def push
      repo = Git.open(REPO_PATH)
      repo.add(all: true)
      repo.commit(compute_commit_message)
      begin
        repo.push
      rescue Git::GitExecuteError
        abort('dotrs: an error occured while pushing.')
      end
    end

    def diff(short = false)
      Git.open(REPO_PATH).diff('HEAD').each do |file_diff|
        puts(file_diff.path)
        puts(file_diff.patch) unless short
      end
    end

    private

    def compute_commit_message
      msg = String.new("dotrs: push from '#{Socket.gethostname}'\n")
      msg << added_files_message
      msg << changed_files_message
      msg << deleted_files_message
      msg
    end

    def added_files_message
      return '' if Git.open(REPO_PATH).status.added.empty?

      result = "\nFile(s) added:\n"
      repo = Git.open(REPO_PATH)
      repo.status.added.each_key { |file| result += "  #{file}\n" }
      result
    end

    def changed_files_message
      return '' if Git.open(REPO_PATH).status.changed.empty?

      result = "\nFile(s) changed:\n"
      repo = Git.open(REPO_PATH)
      repo.status.changed.each_key { |file| result += "  #{file}\n" }
      result
    end

    def deleted_files_message
      return '' if Git.open(REPO_PATH).status.deleted.empty?

      result = "\nFile(s) deleted:\n"
      repo = Git.open(REPO_PATH)
      repo.status.deleted.each_key { |file| result += "  #{file}\n" }
      result
    end
  end
end
