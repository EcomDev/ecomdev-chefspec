
describe ChefSpec::API::EcomDevHelpersRunner do
  it 'returns a chef runner proxy class' do
    expect(chef_run_proxy).to eq(EcomDev::ChefSpec::Helpers::RunnerProxy)
  end
end