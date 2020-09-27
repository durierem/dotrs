#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require_relative 'dotfilerepo.rb'

VERSION = '2.0.0-alpha'

# Exit status
EXIT_SUCCESS = 0
EXIT_FAILURE = 1

# Set up the options
options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: dotrs COMMAND [OPTION]...\n\n"                         \
                "Straightforward dotfiles management\n\n"                      \
                "Commands:\n"                                                  \
                "\tadd FILE...\t\tAdd FILE to the tracked files\n"             \
                "\tapply\t\t\tPull the latest changes\n"                       \
                "\tinit REMOTE\t\tClone the REMOTE source repository\n"        \
                "\tlist\t\t\tList all currently tracked files\n"               \
                "\tremove FILE...\t\tRemove FILE from being tracked\n"         \
                "\tsave\t\t\tPush local changes\n"                             \
                "Options:\n"
  opts.on('--help', 'Display this help and exit') do
    puts opts
    exit(EXIT_SUCCESS)
  end
  opts.on('-v', '--verbose', 'Display what is being done') do
    options[:verbose] = true
  end
  opts.on('--version', 'Display version number and exit') do
    puts "dotrs #{VERSION}"
    exit(EXIT_SUCCESS)
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
  exit(EXIT_FAILURE)
end

# Execute actions depending on the command
begin
  case ARGV[0].to_sym
  when :add
  when :apply
  when :init
    DotfileRepo.new(ARGV[1])
  when :list
  when :remove
  when :save
  else
    puts("dotrs: unknown command '#{ARGV[0]}'.")
    puts('Type `dotrs --help` for a list of available commands.')
    exit(EXIT_FAILURE)
  end
rescue Interrupt
  puts("\ndotrs: interrupted!")
  exit(EXIT_FAILURE)
end
