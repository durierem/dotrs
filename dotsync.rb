#!/usr/bin/env ruby

# TODO:
# => Backup the original dotfiles before overwriting them
# => Implement the save commands
# => Implement the verbose option
# => Use FileUtils instead of calls to system
# => Find proper names and refactor this messy code!
# => Test things and handle many potential errors

require 'optparse'
require 'fileutils'

VERSION = "0.0.1"
LOCAL_REPO_NAME = ".dotfiles"
LOCAL_REPO_PATH = File.join(Dir.home, LOCAL_REPO_NAME)

# ----- OPTION PARSING -----

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: dotsync [OPTION] FILE...\n" \
    "   or: dotsync [OPTION]...\n" \
    "   or: dotsync --init GITHUB-REPOSITORY\n" \
    "Manage your dotfiles with a GitHub repository.\n\n"
  opts.on("-i", "--init", "Clone the remote GITHUB-REPOSITORY and exit") do
    options[:init] = ARGV
  end
  opts.on("-a", "--add", "Add FILE to the tracked files") do
    options[:add] = ARGV
  end
  opts.on("-r", "--remove", "Remove FILE from the tracked files") do
    options[:remove] = ARGV
  end
  opts.on("-p", "--push", "Push the local repository of tracked files") do
    options[:push] = nil
  end
  opts.on("-P", "--pull", "Pull the remote repository of tracked files") do
    options[:pull] = nil
  end
  opts.on("-A", "--apply", "Copy all tracked files from the local repository " \
          "to their respective location") do
    options[:apply] = nil
  end
  opts.on("-s", "--save", "Copy all tracked files from their respective " \
          "location to the local repository") do
    options[:save] = nil
  end
  opts.on("-v", "--verbose", "Display what is being done") do
    options[:verbose] = nil
  end
  opts.on("--version", "Display version number and exit") do
    options[:version] = nil
  end
end

# Check for invalid options
begin
  optparse.parse!
rescue OptionParser::InvalidOption
  puts("Invalid option #{options}, see `--help` for supported options.")
  exit
end

# ----- MAIN PROGRAM -----

# Display version number if asked
if options.include?(:version)
  puts "dotsync #{VERSION}"
  exit
end

# Check for existing local repository
if !Dir.exist?(LOCAL_REPO_PATH) && !options.include?(:init)
  puts "No local repository found, please initialize one with:\n\n"            \
       "  dotsync --init GITHUB-REPOSITORY"
  exit
end

# option: -i, --init
if options.include?(:init)
  if Dir.exist?(LOCAL_REPO_PATH)
    puts "#{LOCAL_REPO_PATH} already exists."
    exit
  end
  if ARGV.length == 0
    puts "No argument given, see `--help` for further details"
    exit
  end
  system(" git -C #{Dir.home} clone #{ARGV[0]} #{LOCAL_REPO_NAME}")
  exit
end

# option: -a, --add
if options.include?(:add)
  if options[:add].empty?
    puts "No file given, see `--help` for further details"
    exit
  end
  options[:add].map! { |file| file = File.absolute_path(file) }
  if options.include?(:verbose)
    system("cp -v --parent #{options[:add].join(" ")} #{LOCAL_REPO_PATH}")
  else
    system("cp --parent #{options[:add].join(" ")} #{LOCAL_REPO_PATH}")
  end
end

# option: -r, --remove
if options.include?(:remove)
  if options[:remove].empty?
    puts "No file given, see `--help` for further details"
    exit
  end
  options[:remove].map do |file|
    file = File.absolute_path(file)
    if options.include?(:verbose)
      system("rm -v #{File.join(LOCAL_REPO_PATH, file)}")
    else
      system("rm #{File.join(LOCAL_REPO_PATH, file)}")
    end
  end
end

# option: -p, --push
if options.include?(:push)
  system("git -C #{LOCAL_REPO_PATH} add --all")
  system("git -C #{LOCAL_REPO_PATH} commit -m 'dotsync'")
  system("git -C #{LOCAL_REPO_PATH} push")
end

# option -P, --pull
if options.include?(:pull)
  system("git -C #{LOCAL_REPO_PATH} pull")
end

def for_each_file_recursively(dir, &block)
  Dir.glob("#{dir}/**/*", File::FNM_DOTMATCH).each do |file|
    unless File.directory?(file) || File.absolute_path(file).include?(".git")
      yield file
    end
  end
end

def get_original_path(file)
  File.expand_path(file).delete_prefix(LOCAL_REPO_PATH)
end

# option: -A, --apply
if options.include?(:apply)
  curr_file = nil
  for_each_file_recursively(LOCAL_REPO_PATH) do |file| 
    FileUtils.cp(file, get_original_path(file), verbose: true) 
  end
end

