# frozen_string_literal: true

require_relative '../config'
require_relative '../master_tree'

# Internal: Remove the given files from the local repository.
#
# If the --all option is defined, the Remove command removes every tracked files
# from the local repository.
class Remove
  include Config

  # Internal: Initialize the Remove command.
  #
  # files - The String file names to remove from the local repository.
  def initialize(*files)
    @mt = MasterTree.new(Config.master_tree_path, Dir.home)
    @files = Config.options[:remove_all] ? @mt.list : files.flatten
  end

  def perform
    @files.each do |file|
      @mt.remove(file)
      puts("#{file} removed from tracked files") if Config.options[:verbose]
    rescue AssertionError => e
      abort("dotrs: #{e}")
    end
  end
end
