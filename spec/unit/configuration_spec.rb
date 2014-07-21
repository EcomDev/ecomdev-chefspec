describe EcomDev::ChefSpec::Configuration do
  before(:each) do
    @_instance = described_class.instance
    Singleton.__init__(described_class)
  end

  after(:each) do
    described_class.instance_variable_set(:@singleton__instance__, @_instance)
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
      callback = Class.new do
        def setup!
          'test'
        end
      end.new

      expect(callback).to receive(:setup!)
      described_class.callback(callback)
      described_class.setup!
    end
  end

  describe '#teardown!' do
    it 'calls a callback method teardown! if it exists' do
      callback = Class.new do
        def teardown!
          'test'
        end
      end.new

      expect(callback).to receive(:teardown!)
      described_class.callback(callback)
      described_class.teardown!
    end
  end

  describe '#before_example' do
    it 'calls a callback method before_example if it exists with self as an argument' do
      callback = Class.new do
        def before_example(example)
          example
        end
      end.new

      expect(callback).to receive(:before_example).with(self)
      described_class.callback(callback)
      described_class.before_example(self)
    end

    it 'calls a callback method before_example without arguments, if it does not take any' do
      callback = Class.new do
        def before_example
          'test'
        end
      end.new

      expect(callback).to receive(:before_example).with(no_args)
      described_class.callback(callback)
      described_class.before_example(self)
    end


  end

  describe '#after_example' do
    it 'calls a callback method before_example if it exists with self as an argument' do
      callback = Class.new do
        def after_example(example)
          example
        end
      end.new

      expect(callback).to receive(:after_example).with(self)
      described_class.callback(callback)
      described_class.after_example(self)
    end

    it 'calls a callback method before_example without arguments, if it does not take any' do
      callback = Class.new do
        def after_example
          'test'
        end
      end.new

      expect(callback).to receive(:after_example).with(no_args)
      described_class.callback(callback)
      described_class.after_example(self)
    end
  end

  context 'when callbacks are not having defined methods' do
    [:setup!, :teardown!, :before_example, :after_example].each do |method|
      describe '#' + method.to_s do
        it 'does not call a callback method '+ method.to_s + ' if it is not defined' do
          callback = double('callback')

          allow(callback).to receive(:respond_to?).with(anything).and_return(false)
          expect(callback).not_to receive(method)

          described_class.callback(callback)
          if described_class.instance_method(method).arity == 1
            described_class.send(method, self)
          else
            described_class.send(method)
          end
        end
      end
    end
  end

end