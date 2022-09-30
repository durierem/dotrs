# frozen_string_literal: true

require 'fileutils'
require_relative '../../lib/contract'

# [
#   { type: :file, name: 'random_file' },
#   {
#     type: :directory,
#     name: 'bilbloup',
#     children: [
#       {
#         type: :directory,
#         name: 'master_tree',
#         children: [
#           { type: :file, name: 'file1', ref: 'ref_file1' }
#         ]
#       },
#       { type: :file, name: 'normal_file' },
#       { type: :symlink, name: 'link_to_file1', to: 'ref_file1' }
#     ]
#   }
# ]
class FileStructure
  attr_reader :structure, :mountpoint

  def initialize(structure)
    Contract.assert(valid_file_structure?(structure), 'invalid file structure')

    @structure = structure
    @mountpoint = nil
  end

  def mount(dirname)
    Contract.assert(Dir.exist?(File.absolute_path(dirname)),
                    'directory does not exist')
    Contract.assert(!mounted?, 'file structure is already mounted')

    full_path = File.absolute_path(dirname)
    create_file_structure(full_path, @structure)
    @mountpoint = full_path
  end

  def unmount
    Contract.assert(mounted?, 'file structure is not mounted')

    FileUtils.rm_r(Dir.glob("#{@mountpoint}/*"))
    @mountpoint = nil
  end

  def mounted?
    !!@mountpoint
  end

  # Get the full path for a file in the mounted file structure.
  #
  # @example
  #   path_for(:foo, :bar, :file)
  #   # => "/path/to/mountpoint/foo/bar/file"
  #
  # @param args [Symbol, String Array<Symbol, String>]
  def path_for(*args)
    Contract.assert(mounted?, 'file structure is not mounted')

    finder = [*args].flatten.map(&:to_sym)
    build_path(finder, @structure)
  end

  private

  def valid_file_structure?(structure)
    return false unless structure.is_a?(Array)

    structure.all? do |elem|
      return false unless elem.is_a?(Hash)

      case elem[:type]
      when :file
        elem.key?(:name)
      when :symlink
        elem.key?(:name) && elem.key?(:to)
      when :directory
        elem.key?(:name) &&
          elem.key?(:children) &&
          valid_file_structure?(elem[:children])
      else
        false
      end
    end
  end

  # @param finder [Array] such as :foo, :bar
  # @param structure [Array] file structure definition
  # @param path [String] starting path (recursive accumulator)
  def build_path(finder, structure, path = @mountpoint)
    return path if finder.empty? || structure.nil?

    base = structure.find { |item| item[:name].to_s == finder.first.to_s }
    return nil if base.nil?

    build_path(
      finder[1..],
      base[:children],
      File.join(path, base[:name])
    )
  end

  # @param dirname [String] root directory
  # @param structure [Array] file structure definition
  # @param symlinks [Hash] current symlinks refs (recursive accumulator)
  def create_file_structure(dirname, structure, symlinks = {})
    structure.each do |element|
      path = File.join(File.absolute_path(dirname), element[:name])
      case element[:type]
      when :file
        File.write(path, element[:content])
        symlinks.merge!(element[:ref] => path) if element[:ref]
      when :symlink
        FileUtils.symlink(symlinks[element[:to]], path)
      when :directory
        FileUtils.mkdir(path)
        create_file_structure(path, element[:children], symlinks)
      end
    end
  end
end
