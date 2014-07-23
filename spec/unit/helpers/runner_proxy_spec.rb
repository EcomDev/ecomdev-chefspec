
describe EcomDev::ChefSpec::Helpers::RunnerProxy do
  it 'does not create any method unless method of runner is executed' do
    runner_proxy = described_class.new
    expect(runner_proxy.instance_variable_get('@target')).to be_nil
  end

  it 'passes constructor options to original constructor' do
    runner_proxy = described_class.new(platform: 'ubuntu')

    expect_any_instance_of(ChefSpec::Runner).to receive(:initialize).with({platform: 'ubuntu'}).and_call_original
    allow_any_instance_of(ChefSpec::Runner).to receive(:node).and_return('fake')

    # Call node method of proxied object
    expect(runner_proxy.node).to eq('fake')
  end

  it 'allows specifying options for constructor later' do
    runner_proxy = described_class.new
    runner_proxy.options(platform: 'ubuntu')
    expect(runner_proxy.instance_variable_get('@args')).to contain_exactly(platform: 'ubuntu')
    expect(runner_proxy.instance_variable_get('@target')).to be_nil
  end

  it 'allows overriding options for constructor later' do
    runner_proxy = described_class.new(version: '14.0')
    runner_proxy.options({platform: 'ubuntu'}, true)
    expect(runner_proxy.instance_variable_get('@args')).to contain_exactly(platform: 'ubuntu')
    expect(runner_proxy.instance_variable_get('@target')).to be_nil
  end

  it 'adds a before method wrapper' do
    runner_proxy = described_class.new
    block = Proc.new { 'test' }
    runner_proxy.before(:method_name, &block)
    runner_proxy.before(:method_name, true,  &block)
    expect(runner_proxy.proxy_blocks[:before]).to eq(method_name: [
        {block: block, instance_eval: false},
        {block: block, instance_eval: true}
    ])
  end

  it 'adds a after method wrapper' do
    runner_proxy = described_class.new
    block = Proc.new { 'test' }
    runner_proxy.after(:method_name, &block)
    runner_proxy.after(:method_name, true,  &block)
    expect(runner_proxy.proxy_blocks[:after]).to eq(method_name: [
        {block: block, instance_eval: false},
        {block: block, instance_eval: true}
    ])
  end

  it 'adds a block as call in method' do
    runner_proxy = described_class.new
    block = Proc.new { 'test' }
    runner_proxy.block(:method_name, &block)
    runner_proxy.block(:method_name, true,  &block)
    expect(runner_proxy.proxy_blocks[:block]).to eq(method_name: [
        {block: block, instance_eval: false},
        {block: block, instance_eval: true}
    ])
  end

  it 'runs added before block in scope of the target class' do
    runner_proxy = described_class.new
    checker = double('test')

    block = Proc.new {
      checker.called(self)
    }

    expect(checker).to receive(:called).with(instance_of(ChefSpec::Runner)).exactly(1).times

    runner_proxy.before(:node, true, &block)
    runner_proxy.node
  end

  it 'runs added after block in scope of the target class and should recieve as an argument an instance of ' do
    runner_proxy = described_class.new
    checker = double('test')

    block = Proc.new { |node, *args|
      checker.called(self)
      checker.node(node)
      checker.args(args)
    }

    expect(checker).to receive(:node).with(instance_of(Chef::Node)).exactly(1).times
    expect(checker).to receive(:args).with(Array.new).exactly(1).times
    expect(checker).to receive(:called).with(instance_of(ChefSpec::Runner)).exactly(1).times

    runner_proxy.after(:node, true, &block)
    runner_proxy.node
  end

  it 'runs added callee block in scope of the target class with initialize method' do
    checker = double('test')

    block = Proc.new { |node|
      checker.called(self, node)
    }

    block_constructor = Proc.new { |node|
      checker.called_constructor(self, node)
    }

    runner_proxy = described_class.new(&block_constructor)

    expect(checker).to receive(:called).with(
                           instance_of(ChefSpec::Runner),
                           instance_of(Chef::Node)
                       ).exactly(1).times
    expect(checker).to receive(:called_constructor).with(
                           instance_of(self.class),
                           instance_of(Chef::Node)
                       ).exactly(1).times

    runner_proxy.block(:initialize, true, &block)
    runner_proxy.node
  end

  it 'runs added callee block in scope of the target class with converge method' do
    checker = double('test')

    block = Proc.new {
      checker.called(self)
    }

    block_converge = Proc.new {
      checker.called_converege(self)
    }

    runner_proxy = described_class.new

    expect(checker).to receive(:called).with(
                           instance_of(ChefSpec::Runner)
                       ).exactly(1).times
    expect(checker).to receive(:called_converege).with(
                           instance_of(self.class)
                       ).exactly(1).times

    allow_any_instance_of(ChefSpec::Runner).to receive(:converge).and_yield
    runner_proxy.block(:initialize, true, &block)
    runner_proxy.converge(&block_converge)
  end

  it 'allows to execute any block outside of the target scope' do
    checker = double('test')

    block = Proc.new { |runner|
      checker.called(self, runner)
    }

    runner_proxy = described_class.new

    expect(checker).to receive(:called).with(
                           instance_of(self.class),
                           instance_of(ChefSpec::Runner)
                       ).exactly(1).times

    allow_any_instance_of(ChefSpec::Runner).to receive(:converge).and_yield
    runner_proxy.block(:initialize, &block)
    runner_proxy.converge
  end

  context 'when in singleton mode' do
    before (:each) { described_class.reset }

    it 'records any method call into @calls property' do
      block = Proc.new { 'test' }

      described_class.some_method('arg1', 'arg2')
      described_class.some_method2('arg1', 'arg2', &block)
      described_class.some_method3('arg1', 'arg2', 'arg3')

      expect(described_class.instance_variable_get(:@calls)).to contain_exactly(
          {method: :some_method, args: %w(arg1 arg2), block: nil},
          {method: :some_method2, args: %w(arg1 arg2), block: block},
          {method: :some_method3, args: %w(arg1 arg2 arg3), block: nil}
      )
    end

    it 'calls recorded methods on instantiation of the chef runner' do
      expect_any_instance_of(described_class).to receive(:some_method).with(*%w(arg1 arg2))
      expect_any_instance_of(described_class).to receive(:some_method2).with(*%w(arg1 arg2)).and_yield
      expect_any_instance_of(described_class).to receive(:some_method3).with(*%w(arg1 arg2 arg3))

      block = Proc.new { 'test' }

      described_class.some_method('arg1', 'arg2')
      described_class.some_method2('arg1', 'arg2', &block)
      described_class.some_method3('arg1', 'arg2', 'arg3')

      expect(described_class.instance(option: 1).options).to eq(option: 1)
    end

    it 'clears method calls after instantiating proxy' do
      expect_any_instance_of(described_class).to receive(:some_method).with(*%w(arg1 arg2))
      described_class.some_method('arg1', 'arg2')

      expect(described_class.instance(option: 1).options).to eq(option: 1)
      expect(described_class.instance_variable_get(:@calls)).to be_empty

    end
  end
end