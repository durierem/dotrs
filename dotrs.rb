#!/usr/bin/env ruby
# frozen_string_literal: true

## TODO:
#  1. Use Git or Rugged (gems) to handle git operations
#  2. Use commands instead of options: 'dotrs add' instead of 'dotrs --add'
#  3. Add options to pull/push/copy only (requires 2)
#  4. Use the name of the user repo instead of forcing '.dotfiles'?
#  5. Backup the original dotfiles before overwriting them?

require 'optparse'
require_relative 'src/actions.rb'
require_relative 'src/config'

VERSION = '1.0.2'

# Set up the options
options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: dotrs COMMAND [OPTION]...\n\n"                         \
                "Straightforward dofiles management\n\n"                       \
                "Commands:\n"                                                  \
                "\tinit REMOTE\t\tClone the source repository\n"               \
                "\tadd FILE...\t\tAdd FILE to the source repository\n"         \
                "\tremove FILE...\t\tRemove FILE from the source repository\n" \
                "\tapply\t\t\tPull the latest changes and replace all "        \
                "targeted files\n"                                             \
                "\tsave\t\t\tCopy all tracked files to the source repository " \
                "and push to remote\n"                                         \
                "\tlist\t\t\tList all currently tracked files\n\n"             \
                "Options:\n"
  opts.on('--help', 'Display this help and exit') do
    puts opts
    exit(0)
  end
  options[:verbose] = false
  opts.on('-v', '--verbose', 'Display what is being done') do
    options[:verbose] = true
  end
  opts.on('--version', 'Display version number and exit') do
    puts "dotrs #{VERSION}"
    exit(0)
  end
end

# Parse and check for invalid options
begin
  optparse.parse!
rescue OptionParser::InvalidOption
  puts('Invalid option, see `--help` for a further informations.')
  exit(1)
rescue OptionParser::MissingArgument
  puts('No argument given, see `--help` for further informations')
  exit(1)
end


