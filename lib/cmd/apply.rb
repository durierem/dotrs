# frozen_string_literal: true

require_relative '../config'
require_relative '../master_tree'

# Internal: Apply command
class Apply
  include Config

  def initialize
    @mt = MasterTree.new(Config.master_tree_path, Dir.home)
  end

  def perform
    @mt.link_all
    return unless Config.options[:verbose]

    @mt.list.each do |file|
      puts("'#{file}' -> '#{File.join(@mt.path, file)}'")
    end
  end
end
