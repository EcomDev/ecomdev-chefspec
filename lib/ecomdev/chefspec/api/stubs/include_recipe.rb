require_relative '../../stub/include_recipe'

module ChefSpec::API
  module EcomDevStubsIncludeRecipe
     def allow_recipe(*recipe_name)
       recipe_name.flatten.each do |recipe|
          EcomDev::ChefSpec::Stub::IncludeRecipe.allow_recipe(recipe)
       end
     end
  end
end