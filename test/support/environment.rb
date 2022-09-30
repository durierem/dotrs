# frozen_string_literal: true

require 'fileutils'

module Support
  class Environment
    TEST_DIR = '/tmp/dotrs_test'
    MASTER_TREE_ROOT = File.join(TEST_DIR, 'master_tree')

    FileStructure.new({
      type: :directory,
      name: 'dotrs',
      children: [
        {
          type: :directory,
          name: 'master_tree',
          children: [
            { type: :file, name: 'file1', ref: 'ref_file1' }
          ]
        },
        { type: :file, name: 'normal_file' },
        { type: :symlink, name: 'link_to_file1', to: 'ref_file1' }
      ]
    })

    file_structure.mount('/tmp')
    file_structure.unmount

    FILE_SYSTEM = {
      active_file_symlink: File.join(TEST_DIR, 'active_file_symlink'),
      dead_symlink: File.join(TEST_DIR, 'dead_symlink'),
      inactive_file: File.join(TEST_DIR, 'inactive_file'),
      other_file: File.join(TEST_DIR, 'other_file')
    }.freeze

    MASTER_TREE = {
      inactive_file: File.join(MASTER_TREE_ROOT, FILE_SYSTEM[:inactive_file]),
      active_file: File.join(MASTER_TREE_ROOT, FILE_SYSTEM[:active_file_symlink]),
      empty_dir: File.join(MASTER_TREE_ROOT, 'foo', 'bar')
    }.freeze

    FILES = { file_system: FILE_SYSTEM, master_tree: MASTER_TREE }.freeze

    def self.setup
      setup_master_tree
      setup_file_system
    end

    def self.teardown
      FileUtils.rm_r(TEST_DIR)
    end

    def self.setup_master_tree
      FileUtils.mkdir_p(MASTER_TREE_ROOT)
      FileUtils.touch(FILES[:master_tree][:inactive_file])
      FileUtils.touch(FILES[:master_tree][:active_file])
      FileUtils.mkdir_p(FILES[:master_tree][:empty_dir])
    end

    def self.setup_file_system
      FileUtils.ln_s(FILES[:master_tree][:active_file],
                     FILES[:file_system][:active_file_symlink],
                     force: true)
      FileUtils.ln_s('/tmp/dead',
                     FILES[:file_system][:dead_symlink],
                     force: true)
      FileUtils.touch(FILES[:file_system][:inactive_file_copy])
      FileUtils.touch(FILES[:file_system][:other_file])
    end
  end
end
