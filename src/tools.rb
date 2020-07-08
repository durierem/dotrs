# frozen_string_literal: true

# tools.rb: contain utility methods.
module Tools
  module_function

  require_relative 'config.rb'

  # Return the original file path in the filesystem.
  def original_path(file)
    File.expand_path(file).delete_prefix(Config::LOCAL_REPO_PATH)
  end

  # Return the modified file path to include the local repository.
  def dotrs_path(file)
    File.join(Config::LOCAL_REPO_PATH, File.expand_path(file))
  end

  # Calls the block once for each entry except for '.' and '..' in this
  # directory, passing the filename of each entry as a parameter to the block.
  def each_child_rec(dirname)
    raise 'No block given' unless block_given?

    Dir.glob("#{dirname}/**/*", File::FNM_DOTMATCH).each do |file|
      next if file == '.' || file == '..' || File.directory?(file)

      yield file
    end
  end
end
