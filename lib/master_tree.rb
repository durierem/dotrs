# frozen_string_literal: true

require 'fileutils'
require_relative 'contract'

# Internal: A directory where each file is as a reference for a symbolic link.
#
# Adding a file to a MasterTree moves the said file under the MasterTree's root
# directory and creates a symbolic link at the file's original location
# pointing to the file's new location.
#
# If a file's original path is "/foo/bar/file" the new path of the same file,
# after being added to a MasterTree is "mastertree_root_directory/foo/bar/file".
#
# By default, the reproduction depth is the root '/' directory; which means that
# the full path to the file is recreated in the MasterTree. The reproduction
# depth can be specified as an optional argument when creating a new MasterTree.
# The path of an added file will be recreated only until the given directory is
# reached.
#
# The terms "real path" and "virtual path" will be used to describe,
# respectively, the original path of a file, and its new path once added in a
# MasterTree.
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
  # Internal: Get the String path of the MasterTree.
  attr_reader :path

  # Internal: Get the String path to the directory of max repdroduction depth.
  attr_reader :max_depth

  # Internal: Initialize a new MasterTree at the given directory.
  #
  # If the given directory for the root of the MasterTree doesn't exist, it is
  # created.
  #
  # dir_name - The String root directory name for the new MasterTree. This
  #            parameter must not be null.
  # max_depth - The String directory path for the reproduction depth
  #             (default: '/'). The directory must already exist. This parameter
  #             must not be null.
  def initialize(dir_name, max_depth = '/')
    Contract.check(!dir_name.nil?, "invalid directory: #{dir_name}")
    Contract.check(!max_depth.nil? && Dir.exist?(max_depth),
                   "invalid maximum depth: #{max_depth}")

    FileUtils.mkdir_p(dir_name) unless File.exist?(dir_name)
    @path = File.absolute_path(dir_name)
    @max_depth = max_depth
  end

  # Internal: Add a file to the MasterTree.
  #
  # The given file is moved under the MasterTree's root directory and a symbolic
  # link referencing the moved file is then created at the old location of the
  # file. The full path to the old file is recreated in the MasterTree (see the
  # example below).
  #
  # file_name - The String name of the file to add. The file must exist, must
  #             not be a symbolic link, must not be a directory and must not
  #             already be in the MasterTree. This parameter must not be null.
  #
  # Returns nothing.
  def add(file_name)
    Contract.check(!file_name.nil?, "#{file_name} is nil")
    check_pre_add(file_name)

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
    Contract.check(!file_name.nil?, "#{file_name} is nil")
    Contract.check(File.symlink?(file_name) &&
                   File.exist?(File.readlink(file_name)) &&
                   File.readlink(file_name).include?(@path),
                   "#{file_name} is not tracked yet")

    FileUtils.rm(file_name)
    FileUtils.mv(virtual_path(file_name), file_name)
    remove_empty_dirs(@path)
  end

  # Internal: Get a list of all files in the MasterTree
  #
  # Returns an Array of the true String paths of the files in the MasterTree.
  def list
    result = []
    each_child_rec(@path) do |file|
      next if File.directory?(file)

      file_name = File.join(Dir.home, file.delete_prefix(@path))
      result << file_name
    end
    result
  end

  # Internal: Creates the corresponding link for every file in the MasterTree.
  #
  # Returns nothing.
  def link_all
    each_child_rec(@path) do |file|
      next if File.directory?(file)

      parent = File.dirname(real_path(file))
      FileUtils.mkdir_p(parent) unless Dir.exist?(parent)
      FileUtils.ln_s(file, real_path(file), force: true)
    end
  end

  # Internal: Check if the MasterTree is empty.
  #
  # Returns true if the MasterTree is empty, false otherwise.
  def empty?
    Dir.empty?(@path)
  end

  # Internal: Get the virtual path in the MasterTree corresponding to a real
  # path in the filesystem.
  #
  # real_path - the String real path in the file system.
  #
  # Returns the String virtual path.
  def virtual_path(real_path)
    File.join(@path,
              File.absolute_path(real_path).delete_prefix("#{@max_depth}/"))
  end

  # Internal: Get the real path in the file system corresponding to a virtual
  # path in the MasterTree.
  #
  # virtual_path - The String virtual path.
  #
  # Returns the String true path.
  def real_path(virtual_path)
    File.join(@max_depth, virtual_path.delete_prefix("#{@path}/"))
  end

  private

  # Internal: Check the preconditions for add.
  #
  # file_name - The String file name to test.
  #
  # Returns nothing.
  def check_pre_add(file_name)
    Contract.check(File.exist?(file_name), "#{file_name} doesn't exist")
    Contract.check(File.owned?(file_name),
                   "insufficent permissions for #{file_name}")
    Contract.check(!File.directory?(file_name), "#{file_name} is a directory")
    Contract.check(!File.absolute_path(file_name).include?(@path) &&
                   !File.exist?(File.absolute_path(virtual_path(file_name))),
                   "#{file_name} is already tracked")
    Contract.check(!File.symlink?(file_name), "#{file_name} is a symbolic link")
  end

  # Internal: Recursively remove all empty directories in a directory.
  #
  # dir_name - The String directory name in which to remove empty directories.
  #
  # Returns nothing.
  def remove_empty_dirs(dir_name)
    each_child_rec(dir_name) do |entry|
      next unless File.directory?(entry)

      FileUtils.rmdir(entry) if Dir.empty?(entry)
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

    invalid = ['.', '..']
    Dir.glob("#{dir_name}/**/*", File::FNM_DOTMATCH).each do |file|
      next if invalid.include?(File.basename(file))

      yield file
    end
  end
end
