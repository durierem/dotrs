# frozen_string_literal: true

require 'test_helper'
require 'minitest/autorun'
require 'fileutils'
require_relative 'support/file_structure'

require_relative '../lib/contract'
require_relative '../lib/master_tree'

class MasterTreeSpec < Minitest::Spec
  def initialize(...)
    super(...)
    @test_dir = File.join(Dir.tmpdir, 'dotrs_test')
    @fs = FileStructure.new([
      {
        type: :directory,
        name: 'master_tree',
        children: [
          { type: :file, name: 'file1', ref: 'ref_file1' }
        ]
      },
      { type: :file, name: 'normal_file' },
      { type: :symlink, name: 'link_to_file1', to: 'ref_file1' }
    ])
  end

  before do
    FileUtils.mkdir(@test_dir) unless Dir.exist?(@test_dir)
    @fs.mount(@test_dir)
  end

  after do
    @fs.unmount
  end

  describe '#initialize' do
    describe 'when no depth is given' do
      it 'uses the default depth /' do
        mt = MasterTree.new(@fs[:master_tree])
        expect(mt.depth).must_equal('/')
      end
    end
  end

  describe 'add' do
    describe 'when the file can be added' do
      it 'adds the file to the master tree' do
        @mt.add(file)
        _(@mt.include?(@mt.virtual_path(file))).must_equal true
      end
    end

    describe 'when the file is already in the master tree' do
      it 'raises an AssertionError' do
        _ { @mt.add(file) }.must_raise(Contract::AssertionError)
      end
    end
  end
end
