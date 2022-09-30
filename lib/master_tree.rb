# frozen_string_literal: true

require 'fileutils'
require_relative 'contract'
require_relative 'extra/dir'

class MasterTree
  include Contract
  include Enumerable

  attr_reader :root, :depth

  def initialize(dirname, depth = '/')
    assert(!dirname.nil?, "invalid directory: #{dirname}")
    assert(!depth.nil? && Dir.exist?(depth),
           "invalid maximum depth: #{depth}")

    FileUtils.mkdir_p(dirname) unless File.exist?(dirname)

    @root = File.absolute_path(dirname)
    @depth = depth || '/'
  end

  # ----------------------------------------------------------------------------
  # ENUMERABLE
  # ----------------------------------------------------------------------------

  def each
    Dir.each_child_r(@root) do |filename|
      yield filename unless File.directory?(filename)
    end
  end

  # ----------------------------------------------------------------------------
  # FILE MANIPULATION
  # ----------------------------------------------------------------------------

  def add(filename)
    assert(untracked?(filename))

    dir = File.dirname(virtual_path(filename))
    FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
    FileUtils.cp(filename, dir)
  end

  def remove(filename)
    assert(inactive?(file))

    File.rm(virtual_path(filename))
  end

  def cleanup
    Dir.each_child_r(@root) do |filename|
      next unless File.directory?(filename)

      FileUtils.rmdir(filename) if Dir.empty?(filename)
    end
  end

  def link(filename)
    assert(inactive?(filename))

    File.rm(filename) if File.exist?(filename)
    FileUtils.ln_s(virtual_path(filename), filename)
  end

  def unlink(filename)
    assert(active?(filename))

    File.rm(filename)
    File.cp(virtual_path(filename), filename)
  end

  # ----------------------------------------------------------------------------
  # PATH MANIPULATION
  # ----------------------------------------------------------------------------

  def virtual_path(filename)
    File.join(
      @root,
      File.absolute_path(filename).delete_prefix("#{@depth}/")
    )
  end

  def real_path(filename)
    File.join(
      @depth,
      filename.delete_prefix("#{@root}/")
    )
  end

  # ----------------------------------------------------------------------------
  # STATE RESOLVING
  # ----------------------------------------------------------------------------

  def untracked?(filename)
    return false if filename.nil? || File.directory?(filename)

    !include?(virtual_path(filename)) &&
      !(
        File.symlink?(filename) &&
        File.readlink(filename) == virtual_path(filename)
      )
  end

  def inactive?(filename)
    return false if filename.nil? || File.directory?(filename)

    include?(virtual_path(filename)) &&
      (!File.exist?(filename) ||
        !File.symlink?(filename) ||
        File.readlink(filename) != virtual_path(filename))
  end

  def active?(filename)
    return false if filename.nil? || File.directory?(filename)

    include?(virtual_path(filename)) &&
      File.symlink?(filename) &&
      File.readlink(filename) == virtual_path(filename)
  end
end
