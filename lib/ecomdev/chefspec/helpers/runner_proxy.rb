module EcomDev::ChefSpec::Helpers
  class RunnerProxy
    instance_methods.each { |m| undef_method m unless m =~ /(^instance_variable_get|^initialize|^__|^send$|^object_id$)/ }

    def initialize(*args, &before_initialize)
      @args = args
      @constructor_block = before_initialize
      @target = nil
      @blocks = {
          :before => {},
          :block => {},
          :after => {}
      }
    end

    def options(options = {}, override = false)
      if @args.length == 0
        @args << options
        return @args[0]
      end
      if override
        @args[0] = options
      else
        @args[0] = options.merge(@args[0])
      end
      @args[0]
    end

    def before(method, instance_eval = false, &block)
      define_proxy_block(method, :before, instance_eval, &block)
    end

    def after(method, instance_eval = false, &block)
      define_proxy_block(method, :after, instance_eval, &block)
    end

    def block(method, instance_eval = false, &block)
      define_proxy_block(method, :block, instance_eval, &block)
    end

    def proxy_blocks
      @blocks
    end

    def runner
      target
    end

    # Proxied chef runner
    protected
    def define_proxy_block(method, type, instance_eval = false, &block)
      if block_given?
        @blocks[type][method] ||= Array.new
        @blocks[type][method] << {block: block, instance_eval: instance_eval}
      end
    end

    def block_for?(method, type)
      @blocks.key?(type) && @blocks[type].key?(method) && @blocks[type][method].is_a?(Array)
    end

    def invoke_blocks(method, type, *args, &block)
      blocks_to_exec = []
      if block_given?
        blocks_to_exec << {block: block, instance_eval: false, caller_block: true}
      end

      if block_for?(method, type)
        blocks_to_exec.push(@blocks[type][method]).flatten!
      end

      blocks_to_exec.each do |info|
        if info[:instance_eval]
          target.instance_exec(*args, &info[:block])
        else
          calling_args = args.clone
          unless info.key?(:caller_block) && info[:caller_block]
            calling_args.unshift(target)
          end
          info[:block].call(*calling_args)
        end
      end
    end

    def method_missing(name, *args, &block)
      invoke_blocks(name, :before, *args)
      result = target.send(name, *args) do |*block_args|
        invoke_blocks(name, :block, *block_args, &block)
      end
      args.unshift(result)
      invoke_blocks(name, :after, *args)
      result
    end

    def target
      unless @target.nil?
        return @target
      end
      block_args = nil
      @target = ChefSpec::SoloRunner.new(*@args) do |*args|
        block_args = args
      end
      invoke_blocks(:initialize, :block, *block_args, &@constructor_block)
      @target
    end

    class << self
      def instance(*args, &block)
        proxy = self.new(*args, &block)
        proxy_calls.each do |call|
          proxy.send(call[:method], *call[:args], &call[:block])
        end
        reset
        proxy
      end

      def reset
        proxy_calls([])
        self
      end

      def method_missing(method, *args, &block)
        proxy_calls.push({method: method, args: args, block: block})
        self
      end

      private
        def proxy_calls(calls=nil)
          @calls ||= []
          unless calls.nil?
            @calls = calls
          end
          @calls
        end
    end
  end
end