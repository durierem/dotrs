# frozen_string_literal: true

require 'fileutils'

# Internal: Provide a test environment for unit testing.
module TestEnvironment
  TEST_DIR = '/tmp'
  MT_DIR = File.join(TEST_DIR, 'mt_dir')
  STD_DIR = File.join(TEST_DIR, 'dir')

  FILES = {
    file_mt: File.join(MT_DIR, 'file_mt'),
    file_sa: File.join(TEST_DIR, 'file_sa'),
    link_sa: File.join(TEST_DIR, 'file_sa_sl'),
    file_std: File.join(STD_DIR, 'file_std')
  }

  def self.setup
    FileUtils.mkdir_p(MT_DIR)
    FileUtils.mkdir_p(STD_DIR)
    FILES.each_value { |file| FileUtils.touch(file) }
    FileUtils.ln_s(FILES[:file_sa], FILES[:link_sa], force: true)
  end

  def self.teardown
    FileUtils.rm_r(MT_DIR) if Dir.exist?(MT_DIR)
    FileUtils.rm_r(STD_DIR) if Dir.exist?(STD_DIR)
    FILES.each_value { |file| FileUtils.rm(file) if File.exist?(file) }
  end
end
