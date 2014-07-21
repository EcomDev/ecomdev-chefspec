module EcomDev::ChefSpec::Stub
  class FileSystem
    class << self
      extend Forwardable
      def_delegators :instance, :allow_recipe, :reset
    end

    include Singleton

    def initialize
      @current_example = nil
      @stubs = {}
    end

    def before_example(example)
      @current_example = example
    end

    def current_example
      @current_example
    end

    def after_example
      @current_example = nil
      @stubs.clear
    end

    # @return [RSpec::Mocks::Matchers::Receive]
    def stub(klass, method, static=false)
      @stubs[static.to_s] ||= {}
      @stubs[static.to_s][klass.to_s] ||= []
      stub_method = static ? :allow : :allow_any_instance_of
      method = method.to_sym
      unless @stubs[static.to_s][klass.to_s].include?(method)
        @stubs[static.to_s][klass.to_s] << method
        current_example.send(stub_method, klass).to current_example.receive(method).and_call_original
      end

      allowance = current_example.receive(method)
      if block_given?
        yield allowance
      end

      current_example.send(stub_method, klass).to allowance
    end

    def file_exists(file, exists = true)
      stub(File, :exists?, true) do |stub|
        stub.with(file).and_return(exists)
      end
    end

    def file_read(file, content, *additional_args)
      stub(File, :read, true) do |stub|
        stub.with(file, *additional_args).and_return(content)
      end
    end

    def dir_glob(path, result = [])
      stub(Dir, :glob, true) do |stub|
        stub.with(path).and_return(result)
      end
    end
  end
end

EcomDev::ChefSpec::Configuration.callback(EcomDev::ChefSpec::Stub::FileSystem.instance)