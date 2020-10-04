# frozen_string_literal: true

require 'test/unit'
require 'fileutils'
require_relative '../lib/master_tree'
require_relative '../lib/assertion_error'

class TestMasterTree < Test::Unit::TestCase
  TMP_DIR = '/tmp'
  TMP_MASTER_TREE_NAME = File.join(TMP_DIR, 'master_tree')
  TMP_FILE_NAME = File.join(TMP_DIR, 'foo')
  TMP_FILE_NAME_1 = File.join(TMP_DIR, 'bar')
  TMP_FILE_NAME_LN = "#{TMP_FILE_NAME}_ln"

  def setup
    FileUtils.mkdir(TMP_MASTER_TREE_NAME)
    FileUtils.touch(TMP_FILE_NAME)
    FileUtils.touch(TMP_FILE_NAME_1)
    FileUtils.ln_s(TMP_FILE_NAME, TMP_FILE_NAME_LN)
  end

  def teardown
    FileUtils.rm(TMP_FILE_NAME)
    FileUtils.rm(TMP_FILE_NAME_1)
    FileUtils.rm(TMP_FILE_NAME_LN)
    FileUtils.rm_r(TMP_MASTER_TREE_NAME)
  end

  def test_new
    assert_raise(AssertionError) { MasterTree.new(nil) }
    assert_raise(AssertionError) { MasterTree.new('invalid/directory') }
    assert_nothing_raised { (MasterTree.new(TMP_MASTER_TREE_NAME)) }
  end

  def test_add
    t = MasterTree.new(TMP_MASTER_TREE_NAME)
    assert_raise(AssertionError) { t.add(nil) }
    assert_raise(AssertionError) { t.add('unknown_file') }
    assert_raise(AssertionError) { t.add(TMP_FILE_NAME_LN)}
    t.add(TMP_FILE_NAME)
    assert(File.exist?(File.join(TMP_MASTER_TREE_NAME, TMP_FILE_NAME)) &&
           !File.symlink?(File.join(TMP_MASTER_TREE_NAME, TMP_FILE_NAME)))
    assert(File.exist?(TMP_FILE_NAME) && File.symlink?(TMP_FILE_NAME))
  end

  def test_list
    t = MasterTree.new(TMP_MASTER_TREE_NAME)
    t.add(TMP_FILE_NAME)
    t.add(TMP_FILE_NAME_1)
    assert_not_nil(t.list)
    assert_instance_of(Array, t.list)
    assert(t.list.sort == [TMP_FILE_NAME_1, TMP_FILE_NAME])
  end

  def test_remove
    t = MasterTree.new(TMP_MASTER_TREE_NAME)
    t.add(TMP_FILE_NAME)
    assert_raise(AssertionError) { t.remove(nil) }
    assert_raise(AssertionError) { t.remove('unknown_file') }
    assert_raise(AssertionError) { t.remove(TMP_FILE_NAME) }
    t.remove(TMP_FILE_NAME_LN)
    assert(File.exist?(TMP_FILE_NAME) && !File.symlink?(TMP_FILE_NAME))
    assert(!File.exist?(File.join(TMP_MASTER_TREE_NAME, TMP_FILE_NAME)))
  end
end
