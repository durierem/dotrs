#!/usr/bin/env ruby

# TODO:
# => Backup the original dotfiles before overwriting them
# => Implement the pull/apply/save commands
# => Implement the versbose option

require 'optparse'

VERSION = "0.0.1"
LOCAL_REPO_NAME = ".dotfiles"
LOCAL_REPO_PATH = File.join(Dir.home, LOCAL_REPO_NAME)

# ----- OPTION PARSING -----

options = {}
OptionParser.new do |opts|
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
end.parse!

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
    puts "*** ERROR: #{LOCAL_REPO_PATH} already exists."
    exit
  end
  if ARGV.length == 0
    puts "*** ERROR: No argument given, see --help for further details"
    exit
  end
  system("git -C #{Dir.home} clone #{ARGV[0]} #{LOCAL_REPO_NAME}")
  exit
end

# option: -a, --add
if options.include?(:add)
  if options[:add].empty?
    puts "No file given, see --help for further details"
    exit
  end
  options[:add].map! { |file| file = File.absolute_path(file) }
  system("cp -v --parent #{options[:add].join(" ")} #{LOCAL_REPO_PATH}")
end

# option: -r, --remove
if options.include?(:remove)
  if options[:remove].empty?
    puts "No file given, see --help for further details"
    exit
  end
  options[:remove].map do |file|
    file = File.absolute_path(file)
    system("rm -v #{File.join(LOCAL_REPO_PATH, file)}")
  end
end

# option: -p, --push
if options.include?(:push)
  system("git -C #{LOCAL_REPO_PATH} add --all")
  system("git -C #{LOCAL_REPO_PATH} commit -m 'dotsync'")
  system("git -C #{LOCAL_REPO_PATH} push")
end
