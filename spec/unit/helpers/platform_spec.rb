describe EcomDev::ChefSpec::Helpers::Platform do
  before (:each) do
    described_class.platform_path = nil
    described_class.platform_file = nil
  end

  let (:json_data) { '{"os": {"ubuntu": [14.01, 12.04], "debian": 6, "freebsd": 3.4}, "family": {"debian": ["ubuntu", "debian", "unknown"], "freebsd": ["freebsd"]}}' }
  let (:os) { {ubuntu: %w(14.01 12.04), debian: %w(6), freebsd: %w(3.4)} }
  let (:family) { {debian: [:ubuntu, :debian], freebsd: [:freebsd]}}

  describe '#platform_path' do
    it 'equals to rspec directory by default' do
      expect(described_class.platform_path).to eq(RSpec.configuration.default_path)
    end

    it 'makes possible to read from default path' do
      expect(File.directory?(described_class.platform_path)).to eq(true)
    end
  end

  describe '#platform_path=' do
    it 'sets platform path to relative path within specs directory' do
      described_class.platform_path = 'relative'
      expect(described_class.platform_path).to eq(File.join(RSpec.configuration.default_path, 'relative'))
    end

    it 'sets platform path to absolute path if absolute path value is specified' do
      described_class.platform_path = '~/chefspec'
      expect(described_class.platform_path).to eq('~/chefspec')
    end
  end

  describe '#platform_file' do
    it 'equals to platform.json by default' do
      expect(described_class.platform_file).to eq('platform.json')
    end
  end

  describe '#platform_file=' do
    it 'equals to platform.json by default' do
      described_class.platform_file = 'custom.json'
      expect(described_class.platform_file).to eq('custom.json')
    end
  end

  describe '#initialize' do
    it 'loads platform list from JSON file' do
      expect(described_class).to receive(:platform_file).and_return('custom.json')
      expect(described_class).to receive(:platform_path).and_return('/custom/files')

      expect(File).to receive(:readable?).with(File.join('/custom/files', 'custom.json')).and_return(true)
      expect(File).to receive(:read).with(File.join('/custom/files', 'custom.json'))
                      .and_return(json_data)
      expect_any_instance_of(described_class).to receive(:load_json).with(json_data)
      described_class.new
    end

    it 'loads platform list from JSON file specified in arguments' do
      expect(described_class).not_to receive(:platform_file)
      expect(described_class).to receive(:platform_path).and_return('/custom/files')

      expect(File).to receive(:readable?).with(File.join('/custom/files', 'custom.json')).and_return(true)
      expect(File).to receive(:read).with(File.join('/custom/files', 'custom.json'))
                      .and_return(json_data)
      expect_any_instance_of(described_class).to receive(:load_json).with(json_data)
      described_class.new('custom.json')
    end

    it 'loads platform list from JSON file that is specified in arguments with path' do
      expect(described_class).not_to receive(:platform_file)
      expect(described_class).not_to receive(:platform_path)

      expect(File).to receive(:readable?).with(File.join('/custom/files', 'custom.json')).and_return(true)
      expect(File).to receive(:read).with(File.join('/custom/files', 'custom.json'))
                      .and_return(json_data)
      expect_any_instance_of(described_class).to receive(:load_json).with(json_data)
      described_class.new('custom.json', '/custom/files')
    end

    it 'does not load any json file, if file is not readable' do
      expect(described_class).to receive(:platform_file).and_return('custom.json')
      expect(described_class).to receive(:platform_path).and_return('/custom/files')

      expect(File).to receive(:readable?).with(File.join('/custom/files', 'custom.json')).and_return(false)
      expect_any_instance_of(described_class).not_to receive(:load_json)
      described_class.new
    end
  end

  describe '#load_json' do
    it 'loads json structure into os and family properties' do
      platform = described_class.new

      expect(platform.instance_variable_get(:@os)).to be_instance_of(Hash).and be_empty
      expect(platform.instance_variable_get(:@family)).to be_instance_of(Hash).and be_empty

      platform.load_json(json_data)

      expect(platform.instance_variable_get(:@os)).to eq(os)
      expect(platform.instance_variable_get(:@family)).to eq(family)
    end
  end

  describe '#filter' do
    it 'it filters by os names in string' do
      platform = described_class.new
      platform.instance_variable_set(:@os, os)
      platform.instance_variable_set(:@family, family)

      expect(platform.filter('ubuntu', :debian)).to eq([{os: :ubuntu, version: '14.01'},
                                                        {os: :ubuntu, version: '12.04'},
                                                        {os: :debian, version: '6'}])


    end

    it 'it filters by os name and version' do
      platform = described_class.new
      platform.instance_variable_set(:@os, os)
      platform.instance_variable_set(:@family, family)

      expect(platform.filter('debian', '6')).to eq([os: :debian, version: '6'])
    end

    it 'it filters by os version hash' do
      platform = described_class.new
      platform.instance_variable_set(:@os, os)
      platform.instance_variable_set(:@family, family)

      expect(platform.filter(:os => :debian, :version => '6')).to eq([{os: :debian, version: '6'}])
    end

    it 'accepts multiple hashes' do
      platform = described_class.new
      platform.instance_variable_set(:@os, os)
      platform.instance_variable_set(:@family, family)

      expect(platform.filter(
                 {:os => :debian, :version => '6'},
                 {:os => :freebsd}
             )).to eq([{os: :debian, version: '6'}, {os: :freebsd, version: '3.4'}])
    end

    it 'accepts multiple string symbol conditions' do
      platform = described_class.new
      platform.instance_variable_set(:@os, os)
      platform.instance_variable_set(:@family, family)

      expect(platform.filter(:debian, '6', 'freebsd')).to eq([{os: :debian, version: '6'}, {os: :freebsd, version: '3.4'}])
    end


    it 'it filters by os family' do
      platform = described_class.new
      platform.instance_variable_set(:@os, os)
      platform.instance_variable_set(:@family, family)

      expect(platform.filter(:family => :debian)).to eq([{os: :ubuntu, version: '14.01'},
                                                         {os: :ubuntu, version: '12.04'},
                                                         {os: :debian, version: '6'}])

      expect(platform.filter(:family => [:debian, :freebsd])).to eq([{os: :ubuntu, version: '14.01'},
                                                                     {os: :ubuntu, version: '12.04'},
                                                                     {os: :debian, version: '6'},
                                                                     {os: :freebsd, version: '3.4'}])
    end
  end

  describe '#list' do
    it 'it lists all os systems' do
      platform = described_class.new
      platform.instance_variable_set(:@os, os)
      platform.instance_variable_set(:@family, family)

      expect(platform.list).to eq([{os: :ubuntu, version: '14.01'},
                                   {os: :ubuntu, version: '12.04'},
                                   {os: :debian, version: '6'},
                                   {os: :freebsd, version: '3.4'}])

    end

    it 'it lists only latest os versions' do
      platform = described_class.new
      platform.instance_variable_set(:@os, os)
      platform.instance_variable_set(:@family, family)

      # NOTE: it should return last item of array, not latest version by number
      expect(platform.list(true)).to eq([{os: :ubuntu, version: '12.04'},
                                         {os: :debian, version: '6'},
                                         {os: :freebsd, version: '3.4'}])
    end
  end
end