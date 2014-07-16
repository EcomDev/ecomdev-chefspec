module EcomDev
  module ChefSpec
    module Resource
      class Matcher
        module Helper
          def self.reset
            instance_methods.each { |method| remove_method(method) }
          end

          def self.add(method, &block)
            define_method(method, &block)
          end
        end
      end
    end
  end
end