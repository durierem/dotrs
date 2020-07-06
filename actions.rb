# frozen_string_literal: true

module Actions
  module_function

  require 'fileutils'
  require_relative 'config.rb'
  require_relative 'tools.rb'

  def init(remote)
    if Dir.exist?(Config::LOCAL_REPO_PATH)
      puts "#{Config::LOCAL_REPO_PATH} already exists."
      exit
    end
    system("git -C #{Dir.home} clone #{remote} #{Config::LOCAL_REPO}")
    exit
  end

  def add(files, verbose: false)
    files.each do |file|
      file = File.expand_path(file)
      parent_directory = File.join(Config::LOCAL_REPO_PATH,
                         file.delete_suffix(File.basename(file)))
      begin
        FileUtils.mkdir_p(parent_directory) unless Dir.exist?(parent_directory)
        FileUtils.cp(file, parent_directory, verbose: verbose)
      rescue
        puts("Unable to add #{Tools.original_path(file)} to tracked files")
        exit
      end
    end
  end

  def remove(files, verbose: false)
    files.each do |file|
      file = File.expand_path(file)
      begin
        FileUtils.rm(File.join(Config::LOCAL_REPO_PATH, file), verbose: verbose)
      rescue
        puts("Unable to remove #{Tools.original_path(file)} from tracked files")
        exit
      end
      ## TODO: remove the reminiscnent directory if it is empty
    end
  end

  def save(verbose: false)
    Tools.each_child_rec(Config::LOCAL_REPO_PATH) do |file|
      unless File.expand_path(file).include?('.git')
        FileUtils.cp(file, Tools.original_path(file), verbose: verbose)
      end
    end
  end

  def apply(verbose: false)
    Tools.each_child_rec(Config::LOCAL_REPO_PATH) do |file|
      unless File.directory?(file) ||
             File.expand_path(file).include?('.git')
        parent_directory = Tools.original_path(file).delete_suffix(
          File.basename(file))
        FileUtils.mkdir_p(parent_directory) unless Dir.exist?(parent_directory)
        FileUtils.cp(file, parent_directory, verbose: verbose)
      end
    end
  end

  def push
    system("git -C #{Config::LOCAL_REPO_PATH} add --all")
    system("git -C #{Config::LOCAL_REPO_PATH} commit -m 'sync'")
    system("git -C #{Config::LOCAL_REPO_PATH} push")
  end

  def pull
    system("git -C #{Config::LOCAL_REPO_PATH} pull")
  end

  def list_tracked
    Tools.each_child_rec(Config::LOCAL_REPO_PATH) do |file|
      path = Tools.original_path(file)
      puts(path) unless path.include?('.git')
    end
  end
end
