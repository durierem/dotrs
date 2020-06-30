module Actions
  require 'filetutils'
  require_relative 'tools.rb'

  LOCAL_REPO = ".dotfiles"
  LOCAL_REPO_PATH = File.join(Dir.home, LOCAL_REPO)

  def init
    if Dir.exist?(LOCAL_REPO_PATH)
      puts "#{LOCAL_REPO_PATH} already exists."
      exit
    end
    system(" git -C #{Dir.home} clone #{ARGV[0]} #{LOCAL_REPO}")
    exit
  end

  def add(files)
    files.map do |file|
      file = File.expand_path(file)
      FileUtils.mkdir_p(file.delete_suffix(File.basename(file)))
      FileUtils.cp(file, LOCAL_REPO_PATH, verbose: options.include?(:verbose))
    end
  end

  def remove(files)
    files.map do |file|
      file = File.expand_path(file)
      FileUtils.rm(file, verbose: options.include?(:verbose))
      ## TODO: remove the reminiscnent directory if it is empty
    end
  end

  def save
    Dir.for_each_file_rec(LOCAL_REPO_PATH) do |file|
      unless File.expand_path(file).include?('.git')
        FileUtils.cp(file, Tools.original_path(file), verbose: options.include?(:verbose))
    end
  end

  def apply
  end

  def push
  end

  def pull
  end

end
