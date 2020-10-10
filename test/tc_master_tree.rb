# frozen_string_literal: true

$LOAD_PATH << '.'
$LOAD_PATH << '../lib/'

require 'test/unit'
require 'fileutils'
require 'master_tree'
require 'assertion_error'
require 'test_environment'

# Internal: Unit test for the MasterTree class.
class TestMasterTree < Test::Unit::TestCase
  include TestEnvironment

  def setup
    TestEnvironment.setup
  end

  def teardown
    TestEnvironment.teardown
  end

  def test_pre_new
    assert_raise(AssertionError) { MasterTree.new(nil) }
    assert_raise(AssertionError) { MasterTree.new('invalid/directory') }
  end

  def test_new
    assert_nothing_raised { MasterTree.new(MT_DIR) }
  end

  def test_pre_add
    mt = MasterTree.new(MT_DIR)
    assert_raise(AssertionError) { mt.add(nil) }
    assert_raise(AssertionError) { mt.add('invalid_file') }
    assert_raise(AssertionError) { mt.add(FILES[:link_sa]) }
    assert_raise(AssertionError) { mt.add(FILES[:file_mt]) }
  end

  def test_add
    mt = MasterTree.new(MT_DIR)
    assert_nothing_raised { mt.add(FILES[:file_std]) }
  end

  def test_post_add
    mt = MasterTree.new(MT_DIR)
    mt.add(FILES[:file_std])
    moved_file = File.join(MT_DIR, FILES[:file_std])
    assert(File.exist?(moved_file) && !File.symlink?(moved_file))
    assert(File.exist?(FILES[:file_std]) && File.symlink?(FILES[:file_std]))
  end

  def test_pre_remove
    mt = MasterTree.new(MT_DIR)
    assert_raise(AssertionError) { mt.remove(nil) }
    assert_raise(AssertionError) { mt.remove('inalid_file') }
    assert_raise(AssertionError) { mt.remove(FILES[:file_sa]) }
    assert_raise(AssertionError) { mt.remove(FILES[:link_sa]) }
    assert_raise(AssertionError) { mt.remove(FILES[:file_mt]) }
  end

  def test_remove
    mt = MasterTree.new(MT_DIR)
    mt.add(FILES[:file_std])
    assert_nothing_raised { mt.remove(FILES[:file_std]) }
  end

  def test_post_remove
    assert(File.exist?(FILES[:file_std]) && !File.symlink?(FILES[:file_std]))
    assert(!File.exist?(File.join(MT_DIR, FILES[:file_std])))
    assert(!Dir.exist?(File.join(MT_DIR, STD_DIR)))
  end

  def test_list
    mt = MasterTree.new(MT_DIR)
    mt.add(FILES[:file_std])
    list = mt.list
    assert_not_nil(list)
    assert_instance_of(Array, list)
    assert(list.each { |file| !file.include?(MT_DIR) })
  end
end