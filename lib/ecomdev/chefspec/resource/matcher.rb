require_relative 'matcher/dsl'
require_relative 'matcher/helper'

module EcomDev
  module ChefSpec
    module Resource
      class Matcher
        class << self
          extend Forwardable
          def_delegators :instance, :setup!, :teardown!, :register, :matcher, :runner
        end

        include Singleton

        attr_reader :matchers, :runners
        attr_accessor :possible_directories

        def initialize
          @matchers = {}
          @runners = []
          @possible_directories = [
              File.join('spec', 'matchers.rb'),
              File.join('spec', 'matchers', '*.rb'),
              File.join('spec', 'libraries', 'matchers.rb'),
              File.join('spec', 'libraries', 'matchers/*.rb')
          ]
        end

        def setup!
          load_matchers
          extend_api
        end

        def teardown!
          @matchers = {}
          @runners = []
          Helper.reset
        end

        def extend_api
          matchers.each do |method, info|
            Helper.add(method) do |identity|
              ::ChefSpec::Matchers::ResourceMatcher.new(info[:resource], info[:action], identity)
            end
          end

          runners.each do |runner|
            ::ChefSpec.define_matcher(runner.to_sym)
          end
        end

        def matcher(resource_name, action)
          if resource_name.is_a?(Array)
            resource_name.each do |r|
              matcher(r, action)
            end
          elsif action.is_a?(Array)
            action.each do |a|
              matcher(resource_name, a)
            end
          else
            add_matcher(resource_name, action)
          end
        end

        def runner(resource_name)
          if resource_name.is_a?(Array)
            resource_name.each do |r|
              runner(r)
            end
          else
            add_runner(resource_name)
          end
        end

        def load_matchers
          files = search_patterns.map { |pattern| Dir.glob(pattern) }.flatten
          files.each {|file| load_matcher_file(file) }
        end

        def load_matcher_file(file)
          DSL.load(file)
        end

        def search_patterns
          cookbook_path = RSpec.configuration.cookbook_path
          if cookbook_path.nil? ||
              cookbook_path.is_a?(String) && cookbook_path.empty?
            return []
          end

          cookbook_path = [cookbook_path] if cookbook_path.is_a?(String)

          search_patterns = []
          possible_directories.each do |directory|
            cookbook_path.each do |cookbook_path|
              search_patterns << File.join(cookbook_path, '*', directory)
            end
          end
          search_patterns
        end

        def register
          EcomDev::ChefSpec::Configuration.callback(self.class.instance)

          RSpec.configure do |config|
            config.include Helper
          end
        end

        private
        def add_matcher(resource, action)
          resource_name = resource.to_s
          action_name = action.to_s
          matcher_name = action_name + '_' + resource_name
          matcher = matcher_name.to_sym
          unless @matchers.key?(matcher)
            @matchers[matcher] = {action: action_name.to_sym, resource: resource_name.to_sym}
          end
        end

        def add_runner(resource_name)
          resource = resource_name.to_sym
          @runners << resource unless @runners.include?(resource)
        end
      end
    end
  end
end

EcomDev::ChefSpec::Resource::Matcher.register