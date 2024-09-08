require 'rails_helper'

RSpec.describe 'GeocodeService' do
  describe '#call' do
    context 'With a valid address' do
      it 'returns a lat/long pair' do
        address = '2410 Mann St., Des Moines, IA 50310'

        VCR.use_cassette('geocode_valid_address') do
          expect(GeocodeService.call(address)).to eq({ lat: 41.61745, lon: -93.65158 })
        end
      end
    end

    context 'With an invalid address' do
      it 'returns a parsing error' do
        address = ''

        VCR.use_cassette('geocode_invalid_address') do
          expect { GeocodeService.call(address) }.to raise_error(
            StandardError,
            I18n.t('errors.invalid_address'),
          )
        end
      end
    end

    context 'With an ambiguous address' do
      it 'returns an ambiguous address error' do
        address = 'Springfield'

        VCR.use_cassette('geocode_ambiguous_address') do
          expect { GeocodeService.call(address) }.to raise_error(
            StandardError,
            I18n.t('errors.ambiguous_address'),
          )
        end
      end
    end
  end

  describe '#parse_response' do
    context 'Geocoder returns a blank position' do
      it 'raises a bad response exception' do
        body = { 'items' => [{ 'position' => nil }] }

        expect { GeocodeService.parse_response(body) }.to raise_error(
          Faraday::ClientError,
          I18n.t('errors.geocoder_bad_response'),
        )
      end
    end
  end
end