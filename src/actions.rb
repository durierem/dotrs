# frozen_string_literal: true

module Actions
  require 'fileutils'
  require_relative 'global.rb'
  require_relative 'tools.rb'

  class << self
    def init
      if Dir.exist?(Global::LOCAL_REPO_PATH)
        puts "#{Global::LOCAL_REPO_PATH} already exists."
        exit
      end
      system("git -C #{Dir.home} clone #{ARGV[0]} #{Global::LOCAL_REPO}")
      exit
    end

    def add
      files = Global.options[:add]
      if files.empty?
        puts 'No file given, see `--help` for further details'
        exit
      end
      files.map do |file|
        file = File.expand_path(file)
        FileUtils.mkdir_p(file.delete_suffix(File.basename(file)))
        FileUtils.cp(file, Global::LOCAL_REPO_PATH, verbose: Global.options.include?(:verbose))
      end
    end

    def remove
      files = Global.options[:remove]
      if files.empty?
        puts 'No file given, see `--help` for further details'
        exit
      end
      files.map do |file|
        file = File.expand_path(file)
        FileUtils.rm(file, verbose: Global.options.include?(:verbose))
        ## TODO: remove the reminiscnent directory if it is empty
      end
    end

    def save
      Tools.each_child_rec(Global::LOCAL_REPO_PATH) do |file|
        unless File.expand_path(file).include?('.git')
          FileUtils.cp(file, Tools.original_path(file),
                       verbose: Global.options.include?(:verbose))
        end
      end
    end

    def apply
      Dir.each_child_rec(Global::LOCAL_REPO_PATH) do |file|
        unless File.directory?(file) ||
               File.expand_path(file).include?('.git')
          FileUtils.cp(file, Tools.original_path(file), verbose: Global.options.include?(:verbose))
        end
      end
    end

    def push
      system("git -C #{Global::LOCAL_REPO_PATH} add --all")
      system("git -C #{Global::LOCAL_REPO_PATH} commit -m 'sync'")
      system("git -C #{Global::LOCAL_REPO_PATH} push")
    end

    def pull
      system("git -C #{Global::LOCAL_REPO_PATH} pull")
    end
  end
end
