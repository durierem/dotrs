# frozen_string_literal: true

module Global
  require 'optparse'

  VERSION = '0.0.1'
  LOCAL_REPO = '.dotfiles'
  LOCAL_REPO_PATH = File.join(Dir.home, LOCAL_REPO)

  class << self
    attr_accessor :options

    def parse_options
      options = {}
      optparse = OptionParser.new do |opts|
        opts.banner = "Usage: dotrs [OPTION]\n"                                \
            "   or: dotrs init REMOTE-URL\n"                                   \
            "   or: dotrs <add | remove> [OPTION]... FILE...\n"                \
            "   or: dotrs <save | apply> [OPTION]...\n\n"                      \
            "Commands:\n"                                                      \
            "\tadd\t\t\t     Add a file to the local repository.\n"            \
            "\tapply\t\t\t     Pull and replace the target files by those"     \
            " in the local repository\n"                                       \
            "\tremove\t\t\t     Remove a file from the local repository\n"     \
            "\tsave\t\t\t     Copy the target files to the local "             \
            "repository and push\n\n"                                          \
            "Options:\n"
        opts.on('init') do
          options[:init] = ARGV
        end
        opts.on('add') do
          options[:add] = ARGV
        end
        opts.on('remove') do
          options[:remove] = ARGV
        end
        opts.on('apply') do
          options[:apply] = true
        end
        opts.on('save') do
          options[:save] = true
        end
        opts.on('-h', '--help', 'Display this help and exit') do
          puts opts
        end
        opts.on('-v', '--verbose', 'Display what is being done') do
          options[:verbose] = true
        end
        opts.on('--version', 'Display version number and exit') do
          options[:version] = true
        end
      end

      # Check for invalid options
      begin
        optparse.parse!
      rescue OptionParser::InvalidOption
        puts("Invalid option #{options}, see `--help` for supported.")
        exit
      end

      Global.options = options
    end
  end
end
