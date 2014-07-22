module EcomDev::ChefSpec::Helpers
  module StringMatcher
    extend self

    def matcher(expected)
      RSpec::Matchers::BuiltIn::Match.new(expected)
    end

    def regexp(match, before ='', after = '')
      unless match.is_a?(::Regexp)
        match = ::Regexp.escape(match).tr_s('\\ ', '\\s')
      else
        match = match.source
      end

      ::Regexp.new(before + match + after, Regexp::MULTILINE)
    end
  end
end