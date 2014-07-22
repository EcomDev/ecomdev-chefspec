module EcomDev::ChefSpec::Helpers
  def self.helper(helper)
    File.join(File.dirname(__FILE__), 'helpers', helper)
  end

  autoload :RunnerProxy, helper('runner_proxy')
  autoload :StringMatcher, helper('string_matcher')
  autoload :Platform, helper('platform')
end