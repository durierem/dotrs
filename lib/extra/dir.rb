# frozen_string_literal: true

class Dir
  def self.each_child_r(dirname)
    skippable = ['.', '..']
    Dir.glob("#{dirname}/**/*", File::FNM_DOTMATCH).each do |filename|
      yield filename unless skippable.include?(File.basename(filename))
    end
  end

  def each_child_r(&block)
    Dir.each_child_r(path, &block)
  end
end
