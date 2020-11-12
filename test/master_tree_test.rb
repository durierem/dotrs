# frozen_string_literal: true

require 'fileutils'
require 'minitest/autorun'
require 'minitest/reporters'
require_relative '../lib/assertion_error'
require_relative '../lib/master_tree'
require_relative 'test_environment'

reporter_opt = { color: true }
Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new(reporter_opt)

# Internal: Unit tests for the MasterTree class.
class TestMasterTree < Minitest::Test
  include TestEnvironment

  def setup
    TestEnvironment.setup
  end

  def test_new
    assert_raises(AssertionError) { MasterTree.new(nil) }
    assert_raises(AssertionError) { MasterTree.new(MT_DIR, nil) }

    MasterTree.new(MT_DIR)

    assert(File.exist?(MT_DIR),
           'Expected the master tree directory to exist.')
    assert(File.directory?(MT_DIR),
           'Expected the master tree path to be a directroy.')
  end

  def test_add
    mt = MasterTree.new(MT_DIR)

    assert_raises(AssertionError) { mt.add(nil) }
    assert_raises(AssertionError) { mt.add('invalid_file') }
    assert_raises(AssertionError) { mt.add(FILES[:link_sa]) }
    assert_raises(AssertionError) { mt.add(FILES[:file_mt]) }

    mt.add(FILES[:file_std])

    moved_file = File.join(MT_DIR, FILES[:file_std])
    assert(File.exist?(moved_file),
           'Expected the added file to exist in the master tree.')
    assert(!File.symlink?(moved_file),
           'Expected the added file not to be a symbolic link.')
    assert(File.exist?(FILES[:file_std]),
           'Expected a file at the original file path.')
    assert(File.symlink?(FILES[:file_std]),
           'Expected the file at the original path to be a symbolic link')
  end

  def test_remove
    mt = MasterTree.new(MT_DIR)
    mt.add(FILES[:file_std])

    assert_raises(AssertionError) { mt.remove(nil) }
    assert_raises(AssertionError) { mt.remove('invalid_file') }
    assert_raises(AssertionError) { mt.remove(FILES[:file_sa]) }
    assert_raises(AssertionError) { mt.remove(FILES[:link_sa]) }
    assert_raises(AssertionError) { mt.remove(FILES[:file_mt]) }

    mt.remove(FILES[:file_std])

    assert(File.exist?(FILES[:file_std]),
           'Expected the removed file to exist at its original location.')
    assert(!File.symlink?(FILES[:file_std]),
           'Expected the removed file not to be a symbolic link.')
    assert(!File.exist?(File.join(MT_DIR, FILES[:file_std])),
           'Expected the removed file not to be in the master tree.')
    assert(!Dir.exist?(File.join(MT_DIR, STD_DIR)),
           'Expected no empty directory in the master tree.')
  end

  def test_list
    mt = MasterTree.new(MT_DIR)
    mt.add(FILES[:file_std])

    list = mt.list

    refute_nil(list)
    assert_instance_of(Array, list)
    assert(list.none? { |file| file.include?(MT_DIR) },
           'Expected the files paths not to include the master tree path.')
  end

  def test_link_all
    mt = MasterTree.new(MT_DIR, TEST_DIR)
    mt.add(FILES[:file_std])
    FileUtils.rm(FILES[:file_std])

    mt.link_all

    assert(File.exist?(FILES[:file_std]),
           'Expected links to files in the master tree to be created.')
    assert(File.symlink?(FILES[:file_std]),
           'Expected created files to be symbolic links.')
  end

  def teardown
    TestEnvironment.teardown
  end
end
