
describe ChefSpec::API::EcomDevHelpersRunner do
  it 'returns a chef runner proxy class' do
    expect(chef_run_proxy).to eq(described_class::RunnerProxy)
  end
end