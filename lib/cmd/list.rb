# frozen_string_literal: true

require 'tty-tree'
require_relative '../config'
require_relative '../master_tree'

# Internal: A command to list all currently tracked files.
#
# Files that are more recent than the last commit are displayed with the '(*)'
# symbol next to them.
#
# If the --tree option is defined, the files are displayed as a tree structure.
class List
  include Config

  def initialize
    @mt = MasterTree.new(Config.master_tree_path, Dir.home)
    @diff_files = git_diff_files
  end

  def perform
    return if @mt.empty?

    Config.options[:tree] ? list_as_tree : list_regular
  end

  private

  # Internal: Get the list of changed files in the master tree.
  #
  # Returns an Array of String basename of changed files.
  def git_diff_files
    files = []
    Git.open(Config.repo_path).diff('HEAD').each do |file_diff|
      # file_diff is the path from the master tree only. We have to add the
      # master tree path to get the actual absolute path of the file
      files << File.basename(file_diff.path)
    end
    files
  end

  # Internal: Display the list of files as a tree structure.
  def list_as_tree
    str = TTY::Tree.new(@mt.path, show_hidden: true).render

    # Replace the name of the directory at the top of the tree with the user's
    # home directory.
    str.delete_prefix!(File.basename(@mt.path)).prepend(Dir.home)

    # Print each line of the tree, and add ' (*)' at the end of unsaved files
    str.each_line do |line|
      @diff_files.each do |diff|
        line.replace("#{line.chomp} (*)") if line.include?(diff)
      end
      puts(line)
    end
  end

  # Internal: Display each file's full path, one by one.
  def list_regular
    @mt.list.each do |file|
      @diff_files.each do |diff|
        file.replace("#{file} (*)") if file.include?(diff)
      end
      puts(file)
    end
  end
end
