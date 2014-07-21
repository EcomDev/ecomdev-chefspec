describe EcomDev::ChefSpec::Stub::FileSystem do
  describe '#before_example' do
    it 'sets current example before' do
      expect(described_class.instance.instance_variable_get('@current_example')).to eq(self)
    end
  end

  describe '#current_example' do
    it 'returns current example' do
      expect(described_class.instance.current_example).to eq(self)
    end
  end

  describe '#after_example' do
    it 'clears example on after callback' do
      described_class.instance.after_example
      expect(described_class.instance.current_example).to be_nil
    end

    it 'clears stubs array on after callback' do
      described_class.instance.stub(Dir, :glob, true)
      described_class.instance.after_example
      expect(described_class.instance.instance_variable_get(:@stubs)).to be_instance_of(Hash).and be_empty
    end
  end

  describe '#stub' do
    it 'returns a receiver matcher for object' do
      described_class.instance.stub(Dir, :glob, true) do |stub|
        expect(stub).to be_instance_of(RSpec::Mocks::Matchers::Receive)
      end
    end

    it 'stubs glob calls only with required parameters and the rest are calling original' do
      described_class.instance.stub(Dir, :glob, true) do |stub|
        stub.with('test_dir/*.rb').and_return(%w(test_dir/file.rb))
      end

      # Default behaviour
      expect(Dir.glob(__FILE__)).to contain_exactly(__FILE__)
      # Stubbed behaviour
      expect(Dir.glob('test_dir/*.rb')).to contain_exactly('test_dir/file.rb')
    end
  end

  describe '#file_exists' do
    it 'stubs File.exists method' do
      described_class.instance.file_exists('test-file-non-exists-in-real-system')
      described_class.instance.file_exists(__FILE__, false)

      expect(File.exists?(__FILE__)).to eq(false)
      expect(File.exists?('test-file-non-exists-in-real-system')).to eq(true)
      expect(File.exists?(File.dirname(__FILE__))).to eq(true)
    end
  end

  describe '#dir_glob' do
    it 'stubs Dir.glob method' do
      described_class.instance.dir_glob('test/match*.rb', %w(test/match-file.rb))
      described_class.instance.dir_glob('test.rb')

      expect(Dir.glob('test/match*.rb')).to contain_exactly('test/match-file.rb')
      expect(Dir.glob('test.rb')).to be_instance_of(Array).and be_empty
    end
  end

  describe '#file_read' do
    it 'stubs File.read method' do
      described_class.instance.file_read('test.rb', 'test content')
      expect(File.read('test.rb')).to eq('test content')
    end

    it 'allows to pass additional arguments for File.read' do
      described_class.instance.file_read('test.rb', 'est c', 1, 5, 'r')
      expect(File.read('test.rb', 1, 5, 'r')).to eq('est c')
    end
  end
end