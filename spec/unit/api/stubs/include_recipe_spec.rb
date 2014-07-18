require 'spec_helper'

describe 'test::test' do
  let (:instance) { EcomDev::ChefSpec::Stub::IncludeRecipe.instance }

  it 'should add test::test to allowed recipes' do
    expect(instance.allowed_recipes).to contain_exactly('test::test')
  end

  it 'should have an available allow_recipe method over API' do
    allow_recipe('my_custom::recipe')
    expect(instance.allowed_recipes).to contain_exactly('test::test', 'my_custom::recipe')
  end

  it 'allow recipe should allow multiple arguments as recipe names' do
    allow_recipe('my_custom::recipe', 'recipe::another')
    expect(instance.allowed_recipes).to contain_exactly('test::test', 'my_custom::recipe', 'recipe::another')
  end

  it 'allow recipe should allow multiple arguments as recipe names' do
    allow_recipe(%w(my_custom::recipe recipe::another), 'recipe::third')
    expect(instance.allowed_recipes).to contain_exactly('test::test', 'my_custom::recipe', 'recipe::another', 'recipe::third')
  end

  context 'when defined in hook it' do
    before (:each) { allow_recipe('before::recipe') }

    it 'calls allow_recipe as well' do
      expect(instance.allowed_recipes).to contain_exactly('test::test', 'before::recipe')
    end
  end


end