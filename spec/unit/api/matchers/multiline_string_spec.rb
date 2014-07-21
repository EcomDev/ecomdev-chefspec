
describe ChefSpec::API::EcomDevMatcherMultilineString do
  it 'should allow match line starts with' do
    matcher = start_line_with('My Custom Text')
    expect(matcher).to be_instance_of(RSpec::Matchers::BuiltIn::Match)
    expect(matcher.expected).to eq(/^My\sCustom\sText/m)
  end

  it 'should allow match line ends with' do
    matcher = end_line_with('My Custom Text')
    expect(matcher).to be_instance_of(RSpec::Matchers::BuiltIn::Match)
    expect(matcher.expected).to eq(/My\sCustom\sText$/m)
  end

  it 'should allow match any part of a line with expected content' do
    matcher = contain_line('My Custom Text')
    expect(matcher).to be_instance_of(RSpec::Matchers::BuiltIn::Match)
    expect(matcher.expected).to eq(/^.*My\sCustom\sText.*$/m)
  end

  it 'should allow match whole line with expected content' do
    matcher = contain_full_line('My Custom Text')
    expect(matcher).to be_instance_of(RSpec::Matchers::BuiltIn::Match)
    expect(matcher.expected).to eq(/^\s*My\sCustom\sText\s*$/m)
  end

  context 'when line text is provided it ' do
    let (:some_text) do
      <<-EOF.gsub /^( |\t)+/, ''
          1 Left 1 Middle Right 1
          2 Left 2 Middle Right 2
          3 Left 3 Middle Right 3
          4 Left 4 Middle Right 4
          5 Left 5 Middle Right 5
      EOF
    end

    it 'matches beginning of line correctly' do
       expect(some_text).to start_line_with('1 Left')
       expect(some_text).to start_line_with('2 Left')
       expect(some_text).not_to start_line_with('Right 1')
       expect(some_text).not_to start_line_with('Right 2')
    end

    it 'matches end of line correctly' do
      expect(some_text).to end_line_with('Right 1')
      expect(some_text).to end_line_with('Right 2')

      expect(some_text).not_to end_line_with('1 Left')
      expect(some_text).not_to end_line_with('2 Left')
    end

    it 'matches any part of line correctly' do
      expect(some_text).to contain_line('1 Middle')
      expect(some_text).to contain_line('2 Middle')
      expect(some_text).not_to contain_line('Left Middle 1')
      expect(some_text).not_to contain_line('Left Middle 2')
    end

    it 'matches full line correctly' do
      expect(some_text).to contain_full_line('1 Left 1 Middle Right 1')
      expect(some_text).to contain_full_line('2 Left 2 Middle Right 2')
      expect(some_text).not_to contain_line('1 Left Middle 1 Right 1')
      expect(some_text).not_to contain_line('2 Left Middle 2 Right 2')
    end
  end

end