module EcomDev
  module ChefSpec
    module Resource
      class Matcher
        class DSL
           def matcher(resource, action)
             EcomDev::ChefSpec::Resource::Matcher.matcher(resource, action)
           end

           def runner(resource)
             EcomDev::ChefSpec::Resource::Matcher.runner(resource)
           end

           def self.load(filename)
             dsl = new
             content = File.read(filename)
             content.taint
             dsl.instance_eval(content, filename)
             dsl
           end
        end
      end
    end
  end
end
