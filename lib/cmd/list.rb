# frozen_string_literal: true

require 'tty-tree'
require_relative '../config'
require_relative '../master_tree'

# Internal: List command
class List
  include Config

  def initialize
    @mt = MasterTree.new(Config.master_tree_path, Dir.home)
  end

  def perform
    return if @mt.empty?

    if Config.options[:tree]
      str = TTY::Tree.new(@mt.path, show_hidden: true).render
      str.delete_prefix!(File.basename(@mt.path))
      str = "#{Dir.home}#{str}"
      puts(str)
    else
      @mt.list.each { |file| puts(file) }
    end
  end
end
