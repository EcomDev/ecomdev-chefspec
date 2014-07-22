describe 'extends to base example group' do
  platform_load('platforms.json', File.dirname(__FILE__))

  platform(true) do |name, version|
    context 'In scope of ' + name + ' ' + version + ' ' do
      it 'does crazy things' do
        expect(true).to eq(true)
      end
    end
  end

  platform(:ubuntu, :debian) do |name, version|
    context 'In filtered scope of ' + name + ' ' + version + ' ' do
      it 'does another crazy things' do
        expect(true).to eq(true)
      end
    end
  end

  platform(family: [:debian]) do |name, version|
    context 'In family filtered scope of ' + name + ' ' + version + ' ' do
      it 'does another crazy things' do
        expect(true).to eq(true)
      end
    end
  end

  platform({family: [:debian]}, true) do |name, version|
    context 'In family filtered scope of latest ' + name + '' do
      it 'does another crazy things on version ' + version do
        expect(true).to eq(true)
      end
    end
  end
end