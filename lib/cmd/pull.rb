# frozen_string_literal: true

require 'git'
require_relative '../config'

# Internal: Pull command
class Pull
  include Config

  def initialize; end

  def perform
    Git.open(Config.repo_path).pull
  rescue Git::GitExecuteError => e
    abort("dotrs: #{e}")
  end
end
