module ChefSpec::API
  module EcomDevMatcherMultilineString

    def start_line_with(match)
      EcomDev::ChefSpec::Helpers::StringMatcher.instance_eval do
        matcher(regexp(match, '^'))
      end
    end

    def end_line_with(match)
      EcomDev::ChefSpec::Helpers::StringMatcher.instance_eval do
          matcher(regexp(match, '', '$'))
      end
    end

    def contain_line(match)
      EcomDev::ChefSpec::Helpers::StringMatcher.instance_eval do
        matcher(regexp(match, '^.*', '.*$'))
      end
    end

    def contain_full_line(match)
      EcomDev::ChefSpec::Helpers::StringMatcher.instance_eval do
        matcher(regexp(match, '^\s*', '\s*$'))
      end
    end
  end
end