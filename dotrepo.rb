#frozen_string_literal: true

require 'git'
require_relative 'assertion.rb'

# class DotfileRepo: a set of file stored in a Git repository
# @inv:
#   
class DotfileRepo
  REPO_NAME = '.dotfiles'
  REPO_PATH = File.join(Dir.home, REPO_NAME)

  def initialize(link)
  end

  # add: add `file` to the repository handled by @repo.
  # @pre:
  #   !file.nil?
  # @post
  #   
  def add(file)
  end

  # apply: for all
  def apply
  end
  
  def list
  end

  def remove(file)
  end

  def save
  end
end
