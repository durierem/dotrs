# frozen_string_literal: true

require_relative '../config'
require_relative '../master_tree'

# Internal: Add command
class Add
  include Config

  def initialize(files)
    @mt = MasterTree.new(Config.master_tree_path, Dir.home)
    @files = files
  end

  def perform
    @files.each do |file|
      @mt.add(file)
      puts("#{file} added to tracked files") if Config.options[:verbose]
    rescue AssertionError => e
      abort("dotrs: #{e}")
    end
  end
end
