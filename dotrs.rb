#!/usr/bin/env ruby

# TODO:
# => Backup the original dotfiles before overwriting them
# => Implement the save commands
# => Implement the verbose option
# => Use FileUtils instead of calls to system
# => Use Git or Rugged (gems) to handle git operations
# => Find proper names and refactor this messy code!
# => Prevent incompatible options to be / use proper commands
# => Use the name of the repo instead of forcing '.dotfiles'
# => Create missing directories when applying

require 'optparse'
require 'fileutils'

VERSION = "0.0.1"
# ----- OPTION PARSING -----

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: dotrs [OPTION]\n"                                      \
                "   or: dotrs init REMOTE-URL\n"                               \
                "   or: dotrs <add | remove> [OPTION]... FILE...\n"            \
                "   or: dotrs <save | apply> [OPTION]...\n\n"                  \
                "Commands:\n"                                                  \
                "\tadd\t\t\t     Add a file to the local repository.\n"        \
                "\tapply\t\t\t     Pull and replace the target files by those" \
                " in the local repository\n"                                   \
                "\tremove\t\t\t     Remove a file from the local repository\n" \
                "\tsave\t\t\t     Copy the target files to the local "         \
                "repository and push\n\n"                                      \
                "Options:\n"
  opts.on("init") do
    options[:init] = ARGV
  end
  opts.on("add") do
    options[:add] = ARGV
  end
  opts.on("remove") do
    options[:remove] = ARGV
  end
  opts.on("apply") do
    options[:apply] = true
  end
  opts.on("save") do
    options[:save] = true
  end
  opts.on("-h", "--help", "Display this help and exit") do
    puts opts
  end
  opts.on("-v", "--verbose", "Display what is being done") do
    options[:verbose] = true
  end
  opts.on("--version", "Display version number and exit") do
    options[:version] = true
  end
end

# Check for invalid options
begin
  optparse.parse!
rescue OptionParser::InvalidOption
  puts("Invalid option #{options}, see `--help` for supported .")
  exit
end

# ----- MAIN PROGRAM -----

# Display version number if asked
if options.include?(:version)
 puts "dotrs #{VERSION}"
 exit
end

# option: -a, --add
if options.include?(:add)
 if options[:add].empty?
   puts "No file given, see `--help` for further details"
   exit
 end
 Actions.add(options[:add])
end

# option: -r, --remove
if options.include?(:remove)
 if options[:remove].empty?
   puts "No file given, see `--help` for further details"
   exit
 end
 Actions.remove(options[:remove])
end

# option: -s, --save
if options.include?(:save)
 for_each_file_recursively(LOCAL_REPO_PATH) do |file|
   FileUtils.cp(get_original_path(file), file, verbose: true)
 end
end

# for_each_file_rec
def for_each_file_rec(dir, &block)
 Dir.glob("#{dir}/**/*", File::FNM_DOTMATCH).each do |file|
   yield file
 end
end

def original_path(file)
 File.expand_path(file).delete_prefix(LOCAL_REPO_PATH)
end

# option: -A, --apply
if options.include?(:apply)
 for_each_file_rec(LOCAL_REPO_PATH) do |file|
   unless File.directory?(file) || File.absolute_path(file).include?(".git")
     FileUtils.cp(file, original_path(file), verbose: true)
   end
 end
end

# option: -p, --push
if options.include?(:push)
 system("git -C #{LOCAL_REPO_PATH} add --all")
 system("git -C #{LOCAL_REPO_PATH} commit -m 'dotrs'")
 system("git -C #{LOCAL_REPO_PATH} push")
end

# option -P, --pull
if options.include?(:pull)
 system("git -C #{LOCAL_REPO_PATH} pull")
end
