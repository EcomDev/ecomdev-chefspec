require 'spec_helper'

describe EcomDev::ChefSpec::Stub::IncludeRecipe do
  describe '#allow_recipe' do
    it 'should add recipe to the list of allowed' do
       described_class.allow_recipe('test_my::test')
       described_class.allow_recipe('test_two::test')
       expect(described_class.instance.allowed_recipes).to contain_exactly('test_my::test', 'test_two::test')
    end
  end

  describe '#each_exameple' do
    context 'when there is no described recipe it' do
      it 'does not stub any include of recipe' do
        expect { Chef::Cookbook::Metadata.new.depends }.to raise_error(ArgumentError)
      end
    end

    context 'when there is a described recipe', :allow_recipe => true do
      let (:runner) { ChefSpec::Runner.new }
      let (:described_recipe) { 'test::test' }

      it 'loaded recipes should be empty in the beginning' do
        expect(described_class.instance.loaded_recipes).to be_empty
      end

      it 'should call original load method on allowed recipes' do
        described_class.allow_recipe('test2::test')
        expect_any_instance_of(Chef::RunContext).to receive(:load_recipe).with('test::test').exactly(1).times
        expect_any_instance_of(Chef::RunContext).to receive(:load_recipe).with('test2::test').exactly(1).times
        expect_any_instance_of(Chef::Client).to receive(:assert_cookbook_path_not_empty)

        runner.converge
        runner.run_context.include_recipe('test::test')
        runner.run_context.include_recipe('test2::test')

        expect(runner.run_context.loaded_recipe?('test::test')).to eq(true)
        expect(runner.run_context.loaded_recipe?('test2::test')).to eq(true)
      end

      it 'should mark as included recipes that are not allowed, but do not load them' do
        allow_any_instance_of(Chef::RunContext).to receive(:load_recipe).and_call_original
        expect_any_instance_of(Chef::RunContext).not_to receive(:load_recipe).with('dummy::test')
        expect_any_instance_of(Chef::Client).to receive(:assert_cookbook_path_not_empty)

        runner.converge
        runner.run_context.include_recipe('dummy::test')

        expect(runner.run_context.loaded_recipes).to contain_exactly('dummy::test')
        expect(runner.run_context.loaded_recipe?('dummy::test')).to eq(true)
        expect(runner.run_context.loaded_recipe?('test::test')).to eq(false)
      end
    end
  end
end