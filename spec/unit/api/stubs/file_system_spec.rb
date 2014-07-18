require 'spec_helper'

describe ChefSpec::API::EcomDevStubsFileSystem do
  describe '#file_exists' do
    it 'stubs File.exists method' do
      stub_file_exists('test-file-non-exists-in-real-system')
      stub_file_exists(__FILE__, false)

      expect(File.exists?(__FILE__)).to eq(false)
      expect(File.exists?('test-file-non-exists-in-real-system')).to eq(true)
      expect(File.exists?(File.dirname(__FILE__))).to eq(true)
    end
  end

  describe '#dir_glob' do
    it 'stubs Dir.glob method' do
      stub_dir_glob('test.rb')
      stub_dir_glob('test/match*.rb', %w(test/match-file.rb))

      expect(Dir.glob('test/match*.rb')).to contain_exactly('test/match-file.rb')
      expect(Dir.glob('test.rb')).to be_instance_of(Array).and be_empty
    end
  end

  describe '#file_read' do
    it 'stubs File.read method' do
      stub_file_read('test.rb', 'test content')
      expect(File.read('test.rb')).to eq('test content')
    end

    it 'allows to pass additional arguments for File.read' do
      stub_file_read('test.rb', 'est c', 1, 5, 'r')
      expect(File.read('test.rb', 1, 5, 'r')).to eq('est c')
    end
  end
end