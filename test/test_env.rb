# frozen_string_literal: true

require 'fileutils'

module TestEnv
  TEST_DIR = '/tmp'
  MASTER_TREE = File.join(TEST_DIR, 'master_tree')

  DIRECTORIES = {
    dir_0: File.join(TEST_DIR, 'dir_0'),
    dir_1: File.join(TEST_DIR, 'dir_1'),
    dir_10: File.join(TEST_DIR, 'dir_1', 'dir_10')
  }

  FILES = {
    file_00: File.join(DIRECTORIES[:dir_0], 'file_00'),
    file_01: File.join(DIRECTORIES[:dir_0], 'file_01'),
    file_10: File.join(DIRECTORIES[:dir_1], 'file_10'),
    file_11: File.join(DIRECTORIES[:dir_1], 'file_11'),
    file_100: File.join(DIRECTORIES[:dir_10], 'file_100')
  }

  LINKS = {
    file_00: File.join(TEST_DIR, 'file_00_ln')
  }

  def self.setup
    FileUtils.mkdir(MASTER_TREE)
    DIRECTORIES.each_value do |dir|
      FileUtils.mkdir_p(dir)
    end
    FILES.each_value do |file|
      FileUtils.touch(file)
    end

    LINKS.each do |key, link|
      FileUtils.ln_s(FILES[key], link)
    end
  end

  def self.teardown
    FileUtils.rm_r(MASTER_TREE)
    DIRECTORIES.each_value do |dir|
      FileUtils.rm_r(dir) if Dir.exist?(dir)
    end
    LINKS.each_value do |link|
      FileUtils.rm(link)
    end
  end
end
