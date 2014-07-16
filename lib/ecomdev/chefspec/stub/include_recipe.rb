module EcomDev::ChefSpec::Stub
  class IncludeRecipe
    class << self
      extend Forwardable
      def_delegators :instance, :teardown!, :setup!, :allow_recipe, :reset
    end

    include Singleton

    attr_accessor :allowed_recipes, :loaded_recipes

    def initialize
      @allowed_recipes = []
      @loaded_recipes = []
    end

    def allow_recipe(recipe)
      @allowed_recipes << recipe
    end

    def reset
      @allowed_recipes = []
      @loaded_recipes = []
    end

    def before_example(object)
      stub_include(object) unless allowed_recipes.empty?
    end

    def stub_include(object)
      # Don't worry about external cookbook dependencies
      object.allow_any_instance_of(Chef::Cookbook::Metadata).to object.receive(:depends)

      # Test each recipe in isolation, regardless of includes
      object.allow_any_instance_of(Chef::RunContext).to object.receive(:loaded_recipe?) do |run_context, recipe_name|
        run_context.loaded_recipes.include?(recipe_name)
      end

      object.allow_any_instance_of(Chef::RunContext).to object.receive(:include_recipe) do |run_context, *recipe_names|
        recipe_names.flatten.each do |recipe_name|
          @loaded_recipes << recipe_name
          if allowed_recipes.include?(recipe_name)
            run_context.load_recipe(recipe_name)
          end
        end
        loaded_recipes
      end

      object.allow_any_instance_of(Chef::RunContext).to object.receive(:loaded_recipes) do
        loaded_recipes
      end
    end

    def after_example(object)
      reset
    end
  end
end

RSpec.configure do |c|
  c.before(:each) do
    if respond_to?(:described_recipe) && described_recipe.match(/^[a-z_0-9]+::[a-z_0-9]+$/)
      EcomDev::ChefSpec::Stub::IncludeRecipe.allow_recipe described_recipe
    end
    EcomDev::ChefSpec::Stub::IncludeRecipe.instance.before_example(self)
  end

  c.after(:each) do
    EcomDev::ChefSpec::Stub::IncludeRecipe.instance.after_example(self)
  end
end