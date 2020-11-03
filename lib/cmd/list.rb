# frozen_string_literal: true

require 'tty-tree'
require_relative '../config'
require_relative '../master_tree'

# Internal: List all currently tracked files.
#
# If the --tree option is defined, the files are displayed as a tree structure.
class List
  include Config

  def initialize
    @mt = MasterTree.new(Config.master_tree_path, Dir.home)
  end

  def perform
    return if @mt.empty?

    if Config.options[:tree]
      str = TTY::Tree.new(@mt.path, show_hidden: true).render

      # Replace the name of the directory at the top of the tree with the user's
      # home directory.
      str.delete_prefix!(File.basename(@mt.path))
      str = "#{Dir.home}#{str}"

      puts(str)
    else
      @mt.list.each { |file| puts(file) }
    end
  end
end
