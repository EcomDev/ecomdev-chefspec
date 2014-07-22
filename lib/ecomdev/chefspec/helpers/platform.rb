require 'pathname'
require 'json'

module EcomDev::ChefSpec::Helpers
  class Platform
    def initialize(file = nil, path = nil)
      @os = {}
      @family = {}

      path ||= self.class.platform_path
      file ||= self.class.platform_file

      json_path = File.join(path, file)

      if File.readable?(json_path)
        load_json(File.read(json_path))
      end
    end

    def load_json(json_str)
      json = JSON.load(json_str)
      if json.key?('os') && json['os'].is_a?(Hash)
        json['os'].each_pair do |os, version|
          @os[os.to_sym] ||= Array.new
          unless version.is_a?(Array)
            version = [version]
          end
          version.flatten.map {|v| v.to_s }.each do |v|
            @os[os.to_sym] << v unless @os[os.to_sym].include?(v)
          end
        end
      end

      if json.key?('family') && json['family'].is_a?(Hash)
        json['family'].each_pair do |family, os|
          @family[family.to_sym] ||= Array.new
          unless os.is_a?(Array)
            os = [os]
          end
          os.flatten.map { |v| v.to_sym }.select { |v| @os.key?(v) }.each do |v|
            @family[family.to_sym] << v unless @family[family.to_sym].include?(v)
          end
        end
      end
    end

    # Returns list of available os versions filtered by conditions
    #
    # Each condition is treated as OR operation
    # If no condition is specified all items are listed
    # If TrueClass is supplied as one of the arguments it filters only last versions
    #
    def filter(*conditions)
      latest = !conditions.select {|item| item === true }.empty?
      filters = translate_conditions(conditions)
      items = list(latest)
      unless filters.empty?
        items = items.select do |item|
          !filters.select {|filter| match_filter(filter, item) }.empty?
        end

      end
      items
    end

    def translate_conditions(conditions)
      conditions.flatten!
      previous_filter = previous_condition = nil
      filters = []

      reset_options = Proc.new do
        previous_filter = previous_condition = nil
      end

      conditions.each do |condition|
        unless condition.is_a?(Hash)
          if is_version(condition) && is_os(previous_condition) && previous_filter
            previous_filter[:version] ||= Array.new
            previous_filter[:version] << condition.to_s
          elsif is_os(condition)
            previous_filter = {os: condition.to_sym}
            filters << previous_filter
          else
            reset_options.call
          end
        else
          reset_options.call
          if condition.key?(:family)
            condition[:family] = [condition[:family]] unless condition[:family].is_a?(Array)
            condition[:family].select {|family| @family.key?(family) }.each do |family|
              @family[family].each { |os| filters << {os: os} }
            end
          elsif condition.key?(:os)
            condition[:version] ||= []
            condition[:version] = [condition[:version]] if condition[:version].is_a?(String)
            filters << condition
          end
        end
      end
      filters
    end

    # Returns `true` if provided value is a version string
    # @param string [String, Symbol] value to check
    # @return [TrueClass, FalseClass]
    def is_version(string)
      return false if string === false || string === true || string.nil?
      string.to_s.match(/^\d+[\d\.a-zA-Z\-_~]*/)
    end

    # Returns `true` if provided value is a registered OS
    # @param string [String, Symbol] value to check
    # @return [TrueClass, FalseClass]
    def is_os(string)
      return false if string === false || string === true || string.nil?
      @os.key?(string.to_sym)
    end

    # Returns true if item matches filter conditions
    # @param filter [Hash{Symbol => String, Symbol}]
    # @param item [Hash{Symbol => String, Symbol}]
    # @return [true, false]
    def match_filter(filter, item)
      filter.each_pair do |key, value|
        unless item.key?(key)
          return false
        end
        unless value.is_a?(Array)
          return false if value != item[key]
        else
          return true if value.empty?
          return false unless value.include?(item[key])
        end
      end
      true
    end

    # Mark as private internal methods
    private :is_os, :is_version, :translate_conditions, :match_filter

    # Returns list of available os versions
    # @param [TrueClass, FalseClass] latest specify if would like to receive only latest
    # @return [Array<Hash{Symbol => String, Symbol}>] list of os versions in view of hash
    def list(latest = false)
      result = []
      @os.map do |os, versions|
        unless latest
          versions.each { |version| result << {os: os, version: version}}
        else
          result << {os: os, version: versions.last} if versions.length > 0
        end
      end
      result
    end

    class << self
      def platform_path
        @platform_path ||= RSpec.configuration.default_path
      end

      def platform_path=(value)
        unless value.nil?
          value = Pathname.new value

          if value.relative? && value.to_path[0] != '~'
            value = Pathname.new File.join(RSpec.configuration.default_path, value.to_path)
          end

          value = value.to_path
        end

        @platform_path = value
      end

      def platform_file
        @platform_file ||= 'platform.json'
      end

      def platform_file=(value)
        @platform_file = value
      end
    end
  end
end