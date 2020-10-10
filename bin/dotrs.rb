# frozen_string_literal: true

$LOAD_PATH << '../lib/'
require 'git'
require 'optparse'
require 'master_tree'

EXIT_SUCCESS = 0
EXIT_FAILURE = 1

VERSION = '2.0.0-alpha'
REPO_PATH = File.join(Dir.home, '.dotfiles')

# Set up the options
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: dotrs COMMAND\n\n"                                     \
                "Straightforward dotfiles management\n\n"                      \
                "Commands:\n"                                                  \
                "\tadd FILE...\t\tAdd FILE to the tracked files\n"             \
                "\tapply\t\t\tLink all tracked files to their real location\n" \
                "\tinit REMOTE\t\tClone the REMOTE repository\n"               \
                "\tlist\t\t\tList all currently tracked files\n"               \
                "\tremove FILE...\t\tRemove FILE from being tracked\n"         \
                "\tpull\t\t\tPull the latest changes\n"                        \
                "\tpush\t\t\tPush local changes\n"                             \
                "Options:\n"
  opts.on('--help', 'Display this help and exit') do
    puts opts
    exit(EXIT_SUCCESS)
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

cmd = ARGV[0].to_sym

if cmd == :init
  begin
    Git.clone(ARGV[1], REPO_PATH)
  rescue Git::GitExecuteError
    puts('dotrs: an error occured while cloning.')
    exit(EXIT_FAILURE)
  end
  exit(EXIT_SUCCESS)
end

unless Dir.exist?(REPO_PATH)
  puts('dotrs: not initialized')
  puts('Type `dotrs --help` for a list of available commands.')
  exit(EXIT_FAILURE)
end

begin
  mt = MasterTree.new(REPO_PATH)
  repo = Git.open(REPO_PATH)
  case cmd
  when :add
    ARGV[1..-1].each { |file| mt.add(file) }
  when :apply
    mt.link_all
  when :list
    mt.list.each { |file| puts(file) }
  when :remove
    ARGV[1..-1].each { |file| mt.remove(file) }
  when :pull
    repo.pull
  when :push
    repo.add(all: true)
    repo.commit('sync')
    repo.push
  else
    puts("dotrs: unknown command '#{ARGV[0]}'.")
    puts('Type `dotrs --help` for a list of available commands.')
    exit(EXIT_FAILURE)
  end
rescue Interrupt
  puts("\ndotrs: interrupted!")
  exit(EXIT_FAILURE)
end
