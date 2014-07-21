describe EcomDev::ChefSpec::Resource::Matcher::Helper do

  def create_method_body
    Proc.new do |argument|
      argument*argument
    end
  end

  describe '#add' do
    after(:each) { described_class.reset }

    it 'it adds a new method' do
      body = create_method_body

      described_class.add(:my_custom_method, &body)
      described_class.add(:another_custom_method, &body)

      expect(described_class.instance_methods).to contain_exactly(:my_custom_method, :another_custom_method)
    end

    it 'it adds a new method only once' do
      body = create_method_body do |arg|
        arg
      end
      body2 = create_method_body do |arg|
        arg*2
      end

      described_class.add(:another_custom_method, &body)
      described_class.add(:another_custom_method, &body2)

      expect(described_class.instance_methods).to contain_exactly(:another_custom_method)
      klass = described_class
      callable = Class.new do
        include klass
      end
      expect(callable.new.another_custom_method(1)).to equal(1)
    end
  end

  describe '#reset' do
    it 'it removes all defined methods for instance' do
      body = create_method_body

      expect(described_class.instance_methods).to be_empty

      described_class.add(:my_custom_method, &body)
      described_class.add(:another_custom_method, &body)

      expect(described_class.instance_methods).to contain_exactly(:my_custom_method, :another_custom_method)

      described_class.reset
      expect(described_class.instance_methods).to be_empty
    end
  end
end