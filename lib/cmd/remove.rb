# frozen_string_literal: true

require_relative '../config'
require_relative '../master_tree'

# Internal: Remove command
class Remove
  include Config

  def initialize(files)
    @mt = MasterTree.new(Config.master_tree_path, Dir.home)
    @files = Config.options[:remove_all] ? @mt.list : files
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
