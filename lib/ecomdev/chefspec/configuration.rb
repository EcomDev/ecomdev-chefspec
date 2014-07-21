module EcomDev
  module ChefSpec
    class Configuration
      class << self
        extend Forwardable
        def_delegators :instance, :reset, :setup!, :teardown!, :before_example, :after_example, :cookbook_path, :callback
      end

      include Singleton

      attr_accessor :cookbook_paths
      attr_accessor :callbacks

      def initialize
        @cookbook_paths = []
        @callbacks = []
      end

      def setup!
        unless cookbook_paths.empty?
          original_path = RSpec.configuration.cookbook_path
          if original_path.nil?
            original_path = []
          elsif original_path.is_a?(String)
            original_path = [original_path]
          end

          cookbook_paths.each do |path|
            original_path << path unless original_path.include?(path)
          end

          RSpec.configuration.cookbook_path = original_path
        end

        invoke_callbacks(__method__)
      end

      def teardown!
        invoke_callbacks(__method__)
      end

      def before_example(example)
        invoke_callbacks(__method__, example)
      end

      def after_example(example)
        invoke_callbacks(__method__, example)
      end

      def reset
        @cookbook_paths = []
        @callbacks = []
      end

      def cookbook_path(path)
        @cookbook_paths << path unless cookbook_paths.include?(path)
      end

      def callback(callback)
        @callbacks << callback unless callbacks.include?(callback)
      end

      def self.register
        if defined?(ChefSpec::Berkshelf)
          klass = ChefSpec::Berkshelf
        elsif defined?(ChefSpec::Librarian)
          klass = ChefSpec::Librarian
        else
          klass = false
        end

        if klass
          klass.class_exec do
            alias_method :old_setup!, :setup!
            alias_method :old_teardown!, :teardown!

            def setup!
              old_setup!
              EcomDev::ChefSpec::Configuration.setup!
            end

            def teardown!
              old_teardown!
              EcomDev::ChefSpec::Configuration.teardown!
            end
          end
        else
          RSpec.configure do |config|
            config.before(:suite) { EcomDev::ChefSpec::Configuration.setup! }
            config.after(:suite) { EcomDev::ChefSpec::Configuration.teardown! }
          end
        end

        RSpec.configure do |config|
          config.before(:each) { EcomDev::ChefSpec::Configuration.before_example(self) }
          config.after(:each) { EcomDev::ChefSpec::Configuration.after_example(self) }
        end
      end

      private
        def invoke_callbacks(method, *args)
          callbacks.select { |c| c.respond_to?(method) }.each do |c|
             method_instance = c.class.instance_method(method)
             number_of_args = method_instance.arity < 0 ? (method_instance.arity + 1).abs : method_instance.arity
             if args.length > number_of_args
               pass_args = args.slice(0, number_of_args)
             else
               pass_args = args
             end
             c.send(method, *pass_args)
          end
        end
    end
  end
end

EcomDev::ChefSpec::Configuration.register