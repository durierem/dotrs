# frozen_string_literal: true

module Tools
  require_relative 'global.rb'

  class << self
    def original_path(file)
      File.expand_path(file).delete_prefix(Global::LOCAL_REPO_PATH)
    end

    # Calls the block once for each entry recursively except for . and .. in
    # the named directory, passing the filename of each entry as a parameter to
    # the block.
    # If an entry is a directory it is ignored.
    # If no block is given, it raises an exception.
    def each_child_rec(dirname)
      raise 'No block given' unless block_given?

      Dir.glob("#{dirname}/**/*", File::FNM_DOTMATCH).each do |file|
        yield file unless File.directory?(file)
      end
    end
  end
end
