# frozen_string_literal: true

require 'git'
require_relative '../config'

module Commands
  # Internal: Execute 'git diff' in the local repository.
  #
  # If the option --short is defined, only the file names are displayed.
  class Diff
    include Config

    def initialize; end

    def perform
      Git.open(Config.repo_path).diff('HEAD').each do |file_diff|
        puts(file_diff.path)
        puts(file_diff.patch) unless Config.options[:short]
      end
    rescue Git::GitExecuteError => e
      abort("dotrs: #{e}")
    end
  end
end
