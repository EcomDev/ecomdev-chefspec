
describe EcomDev::ChefSpec::Resource::Matcher do
  before(:each) do
    Singleton.__init__(described_class)
  end

  describe '#initialize' do
    it 'should set matchers to empty hash' do
      expect(described_class.instance.matchers).to be_kind_of(Hash).and be_empty
    end

    it 'should set runners to empty array' do
      expect(described_class.instance.runners).to be_kind_of(Array).and be_empty
    end

    it 'should set possible_directories to expected list' do
      expect(described_class.instance.possible_directories)
      .to be_kind_of(Array)
          .and contain_exactly(
                   File.join('spec', 'matchers.rb'),
                   File.join('spec', 'matchers', '*.rb'),
                   File.join('spec', 'libraries', 'matchers.rb'),
                   File.join('spec', 'libraries', 'matchers', '*.rb')
               )
    end
  end

  describe '#search_patterns' do
    it 'should include cookbook_path if it is a string' do
      RSpec.configure do |config|
        config.cookbook_path = File.join('test', 'directory')
      end
      expect(described_class.instance.search_patterns)
      .to be_kind_of(Array)
          .and contain_exactly(
                   File.join('test', 'directory', '*', 'spec', 'matchers.rb'),
                   File.join('test', 'directory', '*', 'spec', 'matchers', '*.rb'),
                   File.join('test', 'directory', '*', 'spec', 'libraries', 'matchers.rb'),
                   File.join('test', 'directory', '*', 'spec', 'libraries', 'matchers', '*.rb')
               )
    end

    it 'should include cookbook_path if it is an array' do
      RSpec.configure do |config|
        config.cookbook_path = File.join('test', 'directory')
      end
      expect(described_class.instance.search_patterns)
      .to be_kind_of(Array)
          .and contain_exactly(
                   File.join('test', 'directory', '*', 'spec', 'matchers.rb'),
                   File.join('test', 'directory', '*', 'spec', 'matchers', '*.rb'),
                   File.join('test', 'directory', '*', 'spec', 'libraries', 'matchers.rb'),
                   File.join('test', 'directory', '*', 'spec', 'libraries', 'matchers', '*.rb')
               )
    end

    it 'should not include any cookbook in path if it is nil' do
      RSpec.configure do |config|
        config.cookbook_path = nil
      end
      expect(described_class.instance.search_patterns)
      .to be_kind_of(Array)
          .and be_empty
    end

    it 'should not include any cookbook in path if it is empty string' do
      RSpec.configure do |config|
        config.cookbook_path = ''
      end
      expect(described_class.instance.search_patterns)
      .to be_kind_of(Array)
          .and be_empty
    end
  end

  describe '#load_matchers' do
    it 'loads matcher files from configured values' do
      RSpec.configure do |config|
        config.cookbook_path = 'test'
      end

      matcher_paths = {
          File.join('test', '*', 'matchers.rb') => [
              File.join('test', 'magento', 'matchers.rb'),
              File.join('test', 'nginx', 'matchers.rb')
          ],
          File.join('test', '*', 'matchers', '*.rb') => [
              File.join('test', 'custom', 'matchers', 'matcher1.rb'),
              File.join('test', 'custom', 'matchers', 'matcher2.rb')
          ]
      }

      matcher_paths.each_pair do |key, value|
        allow(Dir).to receive(:glob).with(key).and_return(value)
        value.each do |file|
          expect_any_instance_of(described_class).to receive(:load_matcher_file).with(file).and_return(true)
        end
      end

      described_class.instance.possible_directories = ['matchers.rb', File.join('matchers', '*.rb')]
      described_class.instance.load_matchers
    end
  end

  describe '#load_matcher_file' do
    it 'loads file as matcher DSL' do
      dsl_class = EcomDev::ChefSpec::Resource::Matcher::DSL
      expect(dsl_class).to receive(:load).with('file.rb').and_return(dsl_class.new)
      described_class.instance.load_matcher_file('file.rb')
    end
  end

  describe '#setup!' do
    it 'loads matcher files and extends api' do
      expect(described_class.instance).to receive(:load_matchers).and_return([])
      expect(described_class.instance).to receive(:extend_api).and_return(described_class.instance)
      described_class.setup!
    end
  end

  describe '#extend_api' do
    after(:each) { EcomDev::ChefSpec::Resource::Matcher::Helper.reset }
    it 'should add new instance methods to helper' do
      described_class.matcher(:test, :create)
      described_class.instance.extend_api

      expect(EcomDev::ChefSpec::Resource::Matcher::Helper.instance_methods).to contain_exactly(:create_test)
    end

    it 'should define runner method in ChefSpec::SoloRunner 'do
      described_class.runner(:test_resource)
      described_class.instance.extend_api

      expect(::ChefSpec.matchers.keys).to include(:test_resource)
    end
  end

  describe '#teardown!' do
    it 'clears matchers and runners' do
      described_class.matcher(:test, :test)
      described_class.runner(:test)
      described_class.setup!
      described_class.teardown!
      expect(described_class.instance.runners).to be_empty
      expect(described_class.instance.matchers).to be_empty
      expect(EcomDev::ChefSpec::Resource::Matcher::Helper.instance_methods).to be_empty
    end
  end

  describe '#matcher' do
     it 'adds matcher if resource and action are symbols' do
       described_class.matcher(:my_custom_matcher, :create)
       expect(described_class.instance.matchers).to eq(create_my_custom_matcher: {action: :create, resource: :my_custom_matcher})
     end

     it 'adds matcher if resource and action are strings' do
       described_class.matcher('my_custom_matcher', 'create')
       expect(described_class.instance.matchers).to eq(create_my_custom_matcher: {action: :create, resource: :my_custom_matcher})
     end

     it 'adds multiple matchers if actions is an array of symbols' do
       described_class.matcher(:my_custom_matcher, [:create, :delete])
       expect(described_class.instance.matchers).to eq(
                                                        create_my_custom_matcher: {
                                                            action: :create,
                                                            resource: :my_custom_matcher
                                                        },
                                                        delete_my_custom_matcher: {
                                                            action: :delete,
                                                            resource: :my_custom_matcher
                                                        }
                                                    )
     end

     it 'adds multiple matchers if actions is an array of strings' do
       described_class.matcher(:my_custom_matcher, %w(create delete))
       expect(described_class.instance.matchers).to eq(
                                                        create_my_custom_matcher: {
                                                            action: :create,
                                                            resource: :my_custom_matcher
                                                        },
                                                        delete_my_custom_matcher: {
                                                            action: :delete,
                                                            resource: :my_custom_matcher
                                                        }
                                                    )
     end

     it 'adds multiple matchers if resource is an array' do
       described_class.matcher([:my_custom_matcher, :another_matcher], %w(create delete))
       expect(described_class.instance.matchers).to eq(
                                                        create_my_custom_matcher: {
                                                            action: :create,
                                                            resource: :my_custom_matcher
                                                        },
                                                        delete_my_custom_matcher: {
                                                            action: :delete,
                                                            resource: :my_custom_matcher
                                                        },
                                                        create_another_matcher: {
                                                            action: :create,
                                                            resource: :another_matcher
                                                        },
                                                        delete_another_matcher: {
                                                            action: :delete,
                                                            resource: :another_matcher
                                                        }
                                                    )
     end

     it 'adds matcher only once' do
       described_class.matcher('my_custom_matcher', 'create')
       described_class.matcher('my_custom_matcher', 'create')
       expect(described_class.instance.matchers).to eq(
                                                        create_my_custom_matcher: {
                                                            action: :create,
                                                            resource: :my_custom_matcher
                                                        }
                                                    )
     end
  end

  describe '#runner' do
    it 'adds runner if resource is a symbol' do
      described_class.runner(:my_custom_matcher)
      expect(described_class.instance.runners).to contain_exactly(:my_custom_matcher)
    end

    it 'adds matcher if resource is a string' do
      described_class.runner('my_custom_matcher')
      expect(described_class.instance.runners).to contain_exactly(:my_custom_matcher)
    end

    it 'adds multiple runners if resource is an array of symbols' do
      described_class.runner([:my_custom_matcher, :antoher_matcher])
      expect(described_class.instance.runners).to contain_exactly(
                                                       :my_custom_matcher,
                                                       :antoher_matcher
                                                   )
    end

    it 'adds multiple runners if resource is an array of strings' do
      described_class.runner(%w(my_custom_matcher antoher_matcher))
      expect(described_class.instance.runners).to contain_exactly(
                                                       :my_custom_matcher,
                                                       :antoher_matcher
                                                   )
    end

    it 'adds runner only once' do
      described_class.runner('my_custom_matcher')
      described_class.runner('my_custom_matcher')
      expect(described_class.instance.runners).to contain_exactly(:my_custom_matcher)
    end
  end
end
