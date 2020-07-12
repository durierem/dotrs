#!/usr/bin/env ruby
# frozen_string_literal: true

## TODO:
#  1. Use Git or Rugged (gems) to handle git operations
#  2. Add options to pull/push/copy only
#  3. Use the name of the user repo instead of forcing '.dotfiles'?
#  4. Backup the original dotfiles before overwriting them?

require 'optparse'
require_relative 'src/actions.rb'
require_relative 'src/config.rb'

VERSION = '1.1.0'

# Set up the options
options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: dotrs COMMAND [OPTION]...\n\n"                         \
                "Straightforward dotfiles management\n\n"                      \
                "Commands:\n"                                                  \
                "\tadd FILE...\t\tAdd FILE to the source repository\n"         \
                "\tapply\t\t\tPull the latest changes and replace all "        \
                "tracked files\n"                                              \
                "\tinit REMOTE\t\tClone the REMOTE source repository\n"        \
                "\tlist\t\t\tList all currently tracked files\n"               \
                "\tremove FILE...\t\tRemove FILE from the source repository\n" \
                "\tsave\t\t\tCopy all tracked files to the source repository " \
                "and push\n\n"                                                 \
                "Options:\n"
  opts.on('--copy-only', 'Copy files, but don\'t push nor pull') do
    options[:copyonly] = true
  end
  opts.on('--help', 'Display this help and exit') do
    puts opts
    exit(0)
  end
  opts.on('--pull-only', 'Pull the source repository but don\'t copy files') do
    options[:pullonly] = true
  end
  opts.on('--push-only', 'Push the source repository but don\'t copy files') do
    options[:pushonly] = true
  end
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
  puts('dotrs: invalid option.')
  puts('Type `dotrs --help` for a list of available commands.')
  exit(1)
end

# Check if a command has been given
if ARGV.empty?
  puts('dotrs: no command given.')
  puts('Type `dotrs --help` for a list of available commands.')
  exit(1)
end

# Execute actions depending on the command
begin
  case ARGV[0].to_sym
  when :init
    Actions.init(ARGV[1])
  when :add
    Actions.add(ARGV[1..-1], verbose: options[:verbose])
  when :remove
    Actions.remove(ARGV[1..-1], verbose: options[:verbose])
  when :save
    Actions.save_to_source(verbose: options[:verbose]) unless options[:pushonly]
    Actions.push unless options[:copyonly]
  when :apply
    Actions.pull unless options[:copyonly]
    Actions.apply_from_source(verbose: options[:verbose]) unless options[:pullonly]
  when :list
    Actions.list
  else
    puts("dotrs: unknown command '#{ARGV[0]}'.")
    puts('Type `dotrs --help` for a list of available commands.')
    exit(1)
  end
rescue Interrupt
  puts("\ndotrs: interrupted!")
  exit(1)
end
