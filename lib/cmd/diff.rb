# frozen_string_literal: true

require 'git'
require_relative '../config'

# Internal: Diff command
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
