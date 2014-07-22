module RSpec::Core::MemoizedHelpers::ClassMethods
  def platform_load(file = nil, path = nil)
    @platform = EcomDev::ChefSpec::Helpers::Platform.new(file, path)
  end

  def platform(*args)
    if @platform.nil?
      platform_load
    end

    platforms = @platform.filter(*args)
    unless block_given?
      return platforms
    end

    platforms.each do |platform|
      yield platform[:os].to_s, platform[:version].to_s
    end
  end
end