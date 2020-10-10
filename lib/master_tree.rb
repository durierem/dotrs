# frozen_string_literal: true

require 'fileutils'
require_relative 'contract.rb'

# Internal: A directory where each file is as a reference for a symbolic link.
#
# Adding a file to a MasterTree moves the said file under the MasterTree's root
# directory and creates a symbolic link at the file's original location,
# pointing to the file's new location.
#
# If a file's original path is "/foo/bar/file" the new path of the same file,
# after being added to a MasterTree is "mastertree_root_directory/foo/bar/file".
#
# In the following documentation, the terms "real" and "virtual" will be used
# to describe, respectively, the original path of a file, and its path once
# added in a MasterTree.
#
# Examples
#
#   t.add('/foo/bar/file')
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
class MasterTree
  # Internal: Returns the String asbolute path of the MasterTree.
  attr_reader :path

  # Internal: Initialize a new MasterTree whose root directory is the given
  # empty directory.
  #
  # dir_name - The String root directory name for the new MasterTree. The
  #            directory must already exist. This parameter must not be null.
  def initialize(dir_name)
    Contract.check(!dir_name.nil? && Dir.exist?(dir_name),
                   "invalid directory: #{dir_name}")

    @path = File.absolute_path(dir_name)
  end

  # Internal: Add a file to the MasterTree.
  #
  # The given file is moved under the MasterTree's root directory and a symbolic
  # link referencing the moved file is then created at the old location of the
  # file. The full path to the old file is recreated in the MasterTree (see the
  # example below).
  #
  # file_name - The String name of the file to add. The file must exist, must
  #             not be a symbolic link, and must not already be in the
  #             MasterTree. This parameter must not be null.
  #
  # Returns nothing.
  def add(file_name)
    Contract.check(!file_name.nil? && File.exist?(file_name) &&
                    !File.symlink?(file_name) &&
                   !File.absolute_path(file_name).include?(@path),
                   "invalid file: #{file_name}")

    mt_parent = File.dirname(virtual_path(file_name))
    FileUtils.mkdir_p(mt_parent) unless Dir.exist?(mt_parent)
    FileUtils.mv(file_name, mt_parent)
    FileUtils.ln_s(virtual_path(file_name), file_name)
  end

  # Internal: Remove a file from the MasterTree.
  #
  # This procedure does the opposite of adding a file to the MasterTree. The
  # file located at the virtual path of the given file name is moved back at
  # its original location. If this procedure leaves any empty directory in the
  # MasterTree it is recursively removed until no path in the MasterTree ends
  # with no file.
  #
  # file_name - The String name of the file to remove. The file must be a
  #             symbolic link to an existing file in the MasterTree. This
  #             parameter must not be null.
  #
  # Returns nothing.
  def remove(file_name)
    Contract.check(!file_name.nil? &&
                   File.symlink?(file_name) &&
                   File.exist?(File.readlink(file_name)) &&
                   File.readlink(file_name).include?(@path),
                   "invalid file: #{file_name}")

    FileUtils.rm(file_name)
    FileUtils.mv(virtual_path(file_name), file_name)
    remove_empty_dirs(@path)
  end

  # Internal: Get a list of all files in the MasterTree
  #
  # Returns an Array the true String paths of all the files in the MasterTree.
  def list
    result = []
    each_child_rec(@path) { |file| result << file.delete_prefix(@path) }
    result
  end

  # Internal: Creates the corresponding link for every file in the MasterTree.
  #
  # Returns nothing.
  def link_all
    each_child_rec(@path) do |file|
      parent = File.dirname(real_path(file))
      FileUtils.mkdir_p(parent) unless Dir.exist?(parent)
      FileUtils.ln_s(file, real_path(file), force: true)
    end
  end

  private

  # Internal: Get the virtual path in the MasterTree corresponding to a real
  # path in the filesystem.
  #
  # real_path - the String real path in the file system.
  #
  # Returns the String virtual path.
  def virtual_path(real_path)
    File.join(@path, File.absolute_path(real_path))
  end

  # Internal: Get the real path in the file system corresponding to a virtual
  # path in the MasterTree.
  #
  # virtual_path - The String virtual path.
  #
  # Returns the String true path.
  def real_path(virtual_path)
    virtual_path.delete_prefix(@path)
  end

  def remove_empty_dirs(dir_name)
    # mt_parent = File.dirname(virtual_path(file_name))
    # while Dir.empty?(mt_parent)
    #   FileUtils.rm_r(mt_parent) if Dir.exist?(mt_parent)
    #   mt_parent = File.dirname(mt_parent)
    # end
    Dir.each_child(dir_name) do |entry|
      next unless File.directory?(entry)

      remove_empty_dirs(entry)
    end
  end

  # Internal: Call the given block once for each entry, recursively, in a
  # directory (except for '.' and '..'), passing the file name of each entry as
  # a parameter to the block.
  #
  # dir_name - the String name of the directory.
  #
  # Returns nothing.
  def each_child_rec(dir_name)
    raise 'No block given' unless block_given?

    Dir.glob("#{dir_name}/**/*", File::FNM_DOTMATCH).each do |file|
      next if file == '.' || file == '..' || File.directory?(file) ||
              file.include?('.git')

      yield file
    end
  end
end
