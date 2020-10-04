#frozen_string_literal: true

require 'fileutils'
require_relative 'contract.rb'

# Internal: a directory tree that is a copy of a portion of the file system
# hierarchy, starting from the root directory. A file in a MasterTree is pointed
# to by a soft link of the same name at the location of the original file.
class MasterTree
  # Internal: Initialize a MasterTree.
  #
  # Pre:
  # !path.nil? && Dir.exist?(path)
  #
  # path - The String representation of the path for the new MasterTree.
  def initialize(path)
    Contract.check(!path.nil? && Dir.exist?(path), 'invalid path')

    @path = path
  end
  
  # Internal: Add a file to this MasterTree.
  # The added file is moved under this MasterTree's director and a soft link
  # pointing at the moved file is created at its original location. The full
  # tree structure from the root directroy is recreated in the MasterTree (see
  # the example below).
  #
  # Pre:
  # !file_name.nil? && File.exist?(file_name) && !File.symlink?(file_name)
  # 
  # Post:
  # File.symlink?(file_name)
  # && File.readlink(file_name).end_with?(File.expand_path(file_name))
  #
  # file_name - The String representation of the file to add.
  #
  # Examples
  #
  #   t.add('/path/to/file')
  #   # Before:                    After:
  #   #   .                          .
  #   #   |                          |
  #   #   |-foo/                     |-foo/
  #   #   | |-bar/                   | |-bar/
  #   #   |   |-file                 |   |-link_to_file
  #   #   |                          |
  #   #   |-master_tree/             |-master_tree/
  #   #                                |-foo/
  #   #                                  |-bar/
  #   #                                    |-file
  #
  # Returns nothing.
  def add(file_name)
    Contract.check(!file_name.nil? && File.exist?(file_name) &&
                   !File.symlink?(file_name), 'invalid file')

    parent = File.join(@path, File.dirname(File.expand_path(file_name)))
    FileUtils.mkdir_p(parent) unless Dir.exist?(parent)
    FileUtils.mv(file_name, parent)
    FileUtils.ln_s(File.join(@path, file_name), file_name)
  end

  # Internal: Remove a file from this MasterTree.
  # This method does the opposite of `add`: given a soft link that points to a
  # file in this MasterTree, it replaces the link by the orginal file. If a
  # directory in this MasterTree contains no file recursively, the empty branch
  # is deleted.
  #
  # Pre:
  # !link_name.nil?
  # && File.symkink?(link_name)
  # && File.exist?(File.readlink(link_name))
  #
  # Post:
  # File.exist?(link_name)
  # && !File.symlink?(link_name)
  #
  # Returns nothing.
  def remove(link_name)
    Contract.check(!link_name.nil? && File.symlink?(link_name) &&
                   File.exist?(File.readlink(link_name)))
    FileUtils.rm(link_name)
    FileUtils.mv(File.join(@path, link_name), link_name)
    mt_parent = File.dirname(File.join(@path, link_name), link_name)
    while Dir.empty?(mt_parent)
      Filutils.rm_r(mt_parent)
      mt_parent = File.dirname(mt_parent)
    end
  end

  # Internal: Get the list of files in this MasterTree
  #
  # Examples
  #
  #   t = MasterTree.new('path/to/directory')
  #   t.add('foo')
  #   t.add('bar')
  #   t.list
  #   # => ['path/to/foo', 'path/to/bar']
  #
  # Returns an Array containing the absolute paths of all the files in this
  # MasterTree.
  def list
    result = []
    each_child_rec(@path) { |file| result << file.delete_prefix(@path) }
    return result
  end

  private

  # Internal: Call the given block once for each entry, recursively, in a
  # directory (except for '.' and '..'), passing the file name of each entry as
  # a parameter to the block.
  # 
  # dir_name - the String representation of the directory.
  #
  # Returns nothing.
  def each_child_rec(dir_name)
    raise 'No block given' unless block_given?

    Dir.glob("#{dir_name}/**/*", File::FNM_DOTMATCH).each do |file|
      next if file == '.' || file == '..' || File.directory?(file)

      yield file
    end
  end
end
