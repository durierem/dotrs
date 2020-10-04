# frozen_string_literal: true

require 'test/unit'
require 'fileutils'
require_relative '../lib/master_tree'
require_relative '../lib/assertion_error'
require_relative 'test_env'

class TestMasterTree < Test::Unit::TestCase
  def setup
    TestEnv.setup
  end

  def teardown
    TestEnv.teardown
  end

  def test_new
    assert_raise(AssertionError) { MasterTree.new(nil) }
    assert_raise(AssertionError) { MasterTree.new('invalid/directory') }
    assert_nothing_raised { (MasterTree.new(TestEnv::MASTER_TREE)) }
  end

  def test_add
    mt = MasterTree.new(TestEnv::MASTER_TREE)
    assert_raise(AssertionError) { mt.add(nil) }
    assert_raise(AssertionError) { mt.add('unknown_file') }
    assert_raise(AssertionError) { mt.add(TestEnv::LINKS[:file_00]) }
    assert_nothing_raised do
      TestEnv::FILES.each_value { |file| mt.add(file) }
    end
    TestEnv::FILES.each_value do |file|
      moved_file = File.join(TestEnv::MASTER_TREE, file)
      assert(File.exist?(moved_file) && !File.symlink?(moved_file))
      assert(File.exist?(file) && File.symlink?(file))
    end
  end

  def test_list
   
  end

  def test_remove
    
  end
end
