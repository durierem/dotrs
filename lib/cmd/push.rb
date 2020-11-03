# frozen_string_literal: true

require 'git'
require 'socket'
require_relative '../config'

# Internal: Push command
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
