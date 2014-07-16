require_relative '../stub/include_recipe'

module ChefSpec::API
  module EcomDevIncludeRecipe
     def allow_recipe(*recipe_name)
       recipe_name.flatten.each do |recipe|
          EcomDev::ChefSpec::Stub::IncludeRecipe.allow_recipe(recipe)
       end
     end
  end
end

EcomDev::ChefSpec::Configuration.callback(EcomDev::ChefSpec::Stub::IncludeRecipe)