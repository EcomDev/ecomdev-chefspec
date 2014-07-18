require_relative '../../stub/file_system'

module ChefSpec::API::EcomDevStubsFileSystem
  def stub_file_exists(file, exists = true)
    EcomDev::ChefSpec::Stub::FileSystem.instance.file_exists(file, exists)
  end

  def stub_dir_glob(path, result = [])
    EcomDev::ChefSpec::Stub::FileSystem.instance.dir_glob(path, result)
  end

  def stub_file_read(file, content, *additional_args)
    EcomDev::ChefSpec::Stub::FileSystem.instance.file_read(file, content, *additional_args)
  end

end