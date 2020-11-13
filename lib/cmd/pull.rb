# frozen_string_literal: true

require 'git'
require_relative '../config'

module Commands
  # Internal: Pull the remote repository.
  class Pull
    include Config

    def initialize; end

    def perform
      Git.open(Config.repo_path).pull
    rescue Git::GitExecuteError => e
      abort("dotrs: #{e}")
    end
  end
end
