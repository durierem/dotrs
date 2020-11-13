# frozen_string_literal: true

require 'git'
require 'socket'
require_relative '../config'

module Commands
  # Internal: Commit and push to the remote repository.
  #
  # In the case of an empty repository the first commit message is
  # "first commit". In any other cases, the commit message highlights which
  # files have been added, changed or deleted.
  class Push
    include Config

    def initialize; end

    def perform
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

    private

    # Internal: Check if a git repository contains no commit.
    #
    # repo_path - The String repository path to test.
    #
    # Returns true if the repository is empty, false otherwise.
    def empty_repo?(repo_path)
      Dir.empty?(File.join(repo_path, '.git', 'refs', 'heads'))
    end

    # Internal: Compute the commit message based on changed files.
    #
    # If the repository is empty, the returned String is "dotrs: first commit".
    # Otherwise, the return String is of the following form:
    #   # dotrs: push from HOSTNAME
    #   #
    #   # Added:
    #   #       FILE_1
    #   #       FILE_2
    #   #
    #   # Changed:
    #   #       FILE_3
    #   #
    #   # Deleted:
    #   #       FILE_4
    #   #       FILE_5
    #
    # Returns the String commit message.
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
        result += "\t#{file.delete_prefix('src/')}\n"
      end
      result
    end
  end
end
