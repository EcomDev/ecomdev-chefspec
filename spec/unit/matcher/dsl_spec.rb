describe EcomDev::ChefSpec::Resource::Matcher::DSL do
  let(:instance) { described_class.new }
  let(:matcher) { EcomDev::ChefSpec::Resource::Matcher }

  describe '#matcher' do
    it 'calls matcher method on resource matcher instance' do
      expect_any_instance_of(matcher).to receive(:matcher).with(:my_matcher, :create)
      instance.matcher(:my_matcher, :create)
    end

    it 'calls matcher method on resource matcher instance with array arguments' do
      expect_any_instance_of(matcher).to receive(:matcher).with([:my_matcher, :my_matcher2], [:create, :delete])
      instance.matcher([:my_matcher, :my_matcher2], [:create, :delete])
    end
  end

  describe '#runner' do
    it 'calls runner method on resource matcher instance' do
      expect_any_instance_of(matcher).to receive(:runner).with(:my_matcher)
      instance.runner(:my_matcher)
    end

    it 'calls runner method on resource matcher instance with array arguments' do
      expect_any_instance_of(matcher).to receive(:runner).with([:my_matcher, :my_matcher2])
      instance.runner([:my_matcher, :my_matcher2])
    end
  end

  describe '#load' do
    it 'loads file dsl content' do
      allow(File).to receive(:read).with('file.rb').and_return('
      runner :my_custom_runner
      matcher :my_custom_action, :create
      matcher :another_action, [:create, :delete]')

      expect_any_instance_of(matcher).to receive(:runner).with(:my_custom_runner)
      expect_any_instance_of(matcher).to receive(:matcher).with(:my_custom_action, :create)
      expect_any_instance_of(matcher).to receive(:matcher).with(:another_action, [:create, :delete])

      expect(described_class.load('file.rb')).to be_instance_of(described_class)
    end
  end
end