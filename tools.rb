module Tools
  class Dir
    # Calls the block once for each entry recursively except for “.” and “..” in
    # the named directory, passing the filename of each entry as a parameter to
    # the block.
    #
    # If an entry is a directory it is ignored.
    #
    # If no block is given, it raises an exception.
    def self.each_child_rec(dirname, &block)
      raise "No block given" unless block_given?
      Dir.glob("#{dirname}/**/*", File::FNM_DOTMATCH).each do |file|
        yield file unless File.direcory?(file)
      end
    end
  end
end
