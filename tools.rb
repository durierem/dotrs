# frozen_string_literal: true

module Tools
  module_function

  require_relative 'config.rb'

  def original_path(file)
    File.expand_path(file).delete_prefix(Config::LOCAL_REPO_PATH)
  end

  def each_child_rec(dirname)
    raise 'No block given' unless block_given?

    Dir.glob("#{dirname}/**/*", File::FNM_DOTMATCH).each do |file|
      next if file == '.' || file == '..' || File.directory?(file)
      yield file
    end
  end
end
