# frozen_string_literal: true

# actions.rb: contain all the actions related to the management of dotfiles.
module Actions
  module_function

  require 'fileutils'
  require_relative 'config.rb'
  require_relative 'tools.rb'

  # Clone the given remote repository in $HOME under the name of ".dotfiles".
  def init(remote)
    if Dir.exist?(Config::SOURCE_REPO_PATH)
      puts "#{Config::SOURCE_REPO_PATH} already exists."
      exit(1)
    end
    system("git -C #{Dir.home} clone #{remote} #{Config::SOURCE_REPO}")
  end

  # Copy the given files and their parent directories to the source repository.
  def add(files, verbose: false)
    files.each do |file|
      file = File.expand_path(file)
      parent_directory = File.join(Config::SOURCE_REPO_PATH,
                                   file.delete_suffix(File.basename(file)))
      begin
        FileUtils.mkdir_p(parent_directory) unless Dir.exist?(parent_directory)
        FileUtils.cp(file, parent_directory, verbose: verbose)
      rescue StandardError
        puts("Unable to add #{Tools.original_path(file)} to tracked files")
        exit(1)
      end
    end
  end

  # Delete the copies of the given files that found in the source repository.
  def remove(files, verbose: false)
    files.each do |file|
      file = File.expand_path(file)
      begin
        FileUtils.rm(File.join(Config::SOURCE_REPO_PATH, file), verbose: verbose)
      rescue StandardError
        puts("Unable to remove #{Tools.original_path(file)} from tracked files")
        exit(1)
      end
      ## TODO: remove the reminiscnent directory if it is empty
    end
  end

  # Copy each of the tracked files into the source repository, replacing any
  # copy already existing.
  def save(verbose: false)
    Tools.each_child_rec(Config::SOURCE_REPO_PATH) do |file|
      next if File.expand_path(file).include?('.git')

      FileUtils.cp(Tools.original_path(file), file, verbose: verbose)
    end
  end

  # Copy each of the tracked files from the source repositroy to their respective
  # original location in the filesystem.
  def apply(verbose: false)
    Tools.each_child_rec(Config::SOURCE_REPO_PATH) do |file|
      next File.expand_path(file).include?('.git')

      parent_directory = Tools.original_path(file)
                              .delete_suffix(File.basename(file))
      FileUtils.mkdir_p(parent_directory) unless Dir.exist?(parent_directory)
      FileUtils.cp(file, Tools.original_path(file), verbose: verbose)
    end
  end

  # Push the source repository.
  def push
    system("git -C #{Config::SOURCE_REPO_PATH} add --all")
    system("git -C #{Config::SOURCE_REPO_PATH} commit -m 'sync'")
    system("git -C #{Config::SOURCE_REPO_PATH} push")
  end

  # Pull the source repository.
  def pull
    system("git -C #{Config::SOURCE_REPO_PATH} pull")
  end

  # Display a list of the tracked files.
  def list
    Tools.each_child_rec(Config::SOURCE_REPO_PATH) do |file|
      path = Tools.original_path(file)
      puts(path) unless path.include?('.git')
    end
  end
end
