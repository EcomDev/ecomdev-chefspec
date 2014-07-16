module EcomDev
  module ChefSpec
    class Configuration
      class << self
        extend Forwardable
        def_delegators :instance, :reset, :setup!, :teardown!, :cookbook_path, :callback
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

            def setup!
              old_setup!
              EcomDev::ChefSpec::Configuration.setup!
            end
          end
        else
          RSpec.configure do
            before(:suite) { EcomDev::ChefSpec::Configuration.setup! }
          end
        end
      end

      private
        def invoke_callbacks(method)
          callbacks.select { |c| c.respond_to?(method) }.each { |c| c.send(method) }
        end
    end
  end
end