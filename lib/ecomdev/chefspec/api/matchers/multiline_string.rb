module ChefSpec::API
  module EcomDevMatcherMultilineString

    module Matcher
      extend self

      def matcher(expected)
        RSpec::Matchers::BuiltIn::Match.new(expected)
      end

      def regexp(match, before ='', after = '')
        unless match.is_a?(Regexp)
          match = ::Regexp.escape(match).tr_s('\\ ', '\\s')
        else
          match = match.source
        end

        ::Regexp.new(before + match + after, Regexp::MULTILINE)
      end
    end

    def start_line_with(match)
      Matcher::matcher(Matcher::regexp(match, '^'))
    end

    def end_line_with(match)
      Matcher::matcher(Matcher::regexp(match, '', '$'))
    end

    def contain_line(match)
      Matcher::matcher(Matcher::regexp(match, '^.*', '.*$'))
    end

    def contain_full_line(match)
      Matcher::matcher(Matcher::regexp(match, '^\s*', '\s*$'))
    end
  end
end