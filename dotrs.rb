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

VERSION = '1.0.1'

# Set up the options
options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Straightforward dofiles management\n\n"                       \
                "Usage: dotrs [-v] OPTION\n\n"                                 \
                "Options:\n"

  opts.on('-a', '--add FILE[,...]', Array,
          'Add FILE to the local repository') do |file|
    options[:add] = file
  end
  opts.on('-A', '--apply', 'Pull and replace the target files') do
    options[:apply] = true
  end
  opts.on('-h', '--help', 'Display this help and exit') do
    puts opts
    exit
  end
  opts.on('-i', '--init REMOTE', 'Initiliaze dotrs by cloning REMOTE') do |link|
    options[:init] = link
  end
  opts.on('-l', '--list', 'List all currently tracked files') do
    options[:list] = true
  end
  opts.on('-r', '--remove FILE[,...]', Array,
          'Remove FILE from the local repository ') do |files|
    options[:remove] = files
  end
  opts.on('-s', '--save', 'Copy and push the local files.') do
    options[:save] = true
  end
  options[:verbose] = false
  opts.on('-v', '--verbose', 'Display what is being done') do
    options[:verbose] = true
  end
  opts.on('--version', 'Display version number and exit') do
    puts "dotrs #{VERSION}"
    exit
  end
end

# Parse and check for invalid options
begin
  optparse.parse!
rescue OptionParser::InvalidOption
  puts('Invalid option, see `--help` for a further informations.')
  exit
rescue OptionParser::MissingArgument
  puts('No argument given, see `--help` for further informations')
  exit
end

# Do one and only one thing depending on what the user asked (yeah it's ugly)
# TODO: code properly
if options.include?(:init)
  Actions.init(options[:init])
elsif options.include?(:add)
  Actions.add(options[:add], verbose: options[:verbose])
elsif options.include?(:remove)
  Actions.remove(options[:remove], verbose: options[:verbose])
elsif options.include?(:save)
  Actions.save(verbose: options[:verbose])
  Actions.push
elsif options.include?(:apply)
  Actions.pull
  Actions.apply(verbose: options[:verbose])
elsif options.include?(:list)
  Actions.list_tracked
end
