require 'spec_helper'

describe EcomDev::ChefSpec::Configuration do
  before(:each) do
    Singleton.__init__(described_class)
  end

  def callback_klass
    Class.new
  end

  describe '#cookbook_path' do
    it 'it adds a new cookbook path to path stack' do
      described_class.cookbook_path('test/path')
      expect(described_class.instance.cookbook_paths).to contain_exactly('test/path')
    end

    it 'it adds cookbook path only once' do
      described_class.cookbook_path('test/path')
      described_class.cookbook_path('test/path')
      expect(described_class.instance.cookbook_paths).to contain_exactly('test/path')
    end
  end

  describe '#callback' do
    it 'it adds a new callback' do
      callback = callback_klass.new
      described_class.callback(callback)
      expect(described_class.instance.callbacks).to contain_exactly(callback)
    end

    it 'it adds a new callback only once' do
      callback = callback_klass.new
      described_class.callback(callback)
      described_class.callback(callback)
      callback2 = callback_klass.new
      described_class.callback(callback2)
      expect(described_class.instance.callbacks).to contain_exactly(callback, callback2)
    end
  end

  describe '#reset' do
    it 'it removes all callbacks and cookbook_paths' do
      described_class.cookbook_path('test')
      described_class.cookbook_path('test2')
      described_class.callback(callback_klass.new)
      described_class.callback(callback_klass.new)

      expect(described_class.instance.callbacks).not_to be_empty
      expect(described_class.instance.cookbook_paths).not_to be_empty

      described_class.reset

      expect(described_class.instance.callbacks).to be_empty
      expect(described_class.instance.cookbook_paths).to be_empty
    end
  end

  describe '#setup!' do
    it 'modifies cookbook path for RSpec configuration' do
      described_class.cookbook_path('test')
      described_class.cookbook_path('test2')

      expect(RSpec.configuration).to receive(:cookbook_path).and_return(nil)
      expect(RSpec.configuration).to receive(:cookbook_path=).with(%w(test test2))

      described_class.setup!
    end

    it 'add cookbook_paths after previously defined value' do
      described_class.cookbook_path('test')
      described_class.cookbook_path('test2')

      expect(RSpec.configuration).to receive(:cookbook_path).and_return('value')
      expect(RSpec.configuration).to receive(:cookbook_path=).with(%w(value test test2))

      described_class.setup!
    end

    it 'merges cookbook_path with previously defined values' do
      described_class.cookbook_path('test')
      described_class.cookbook_path('test2')
      described_class.cookbook_path('value3')

      expect(RSpec.configuration).to receive(:cookbook_path).and_return(%w(value value2 value3))
      expect(RSpec.configuration).to receive(:cookbook_path=).with(%w(value value2 value3 test test2))

      described_class.setup!
    end


    it 'does not modify cookbook path if it is empty' do
      expect(RSpec.configuration).not_to receive(:cookbook_path)

      described_class.setup!
    end

    it 'calls a callback method setup! if it exists' do
      callback = double('callback')

      allow(callback).to receive(:respond_to?).with(:setup!).and_return(true)
      expect(callback).to receive(:setup!)
      described_class.callback(callback)
      described_class.setup!
    end

    it 'does not call a callback method setup! if it is not defined' do
      callback = double('callback')

      allow(callback).to receive(:respond_to?).with(:setup!).and_return(false)
      expect(callback).not_to receive(:setup!)

      described_class.callback(callback)
      described_class.setup!
    end
  end

  describe '#teardown!' do
    it 'calls a callback method teardown! if it exists' do
      callback = double('callback')

      allow(callback).to receive(:respond_to?).with(:teardown!).and_return(true)
      expect(callback).to receive(:teardown!)
      described_class.callback(callback)
      described_class.teardown!
    end

    it 'does not call a callback method teardown! if it is not defined' do
      callback = double('callback')

      allow(callback).to receive(:respond_to?).with(:teardown!).and_return(false)
      expect(callback).not_to receive(:teardown!)

      described_class.callback(callback)
      described_class.teardown!
    end
  end
end