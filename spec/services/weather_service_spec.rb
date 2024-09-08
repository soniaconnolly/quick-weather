require 'rails_helper'

RSpec.describe 'WeatherService' do
  describe '#call' do
    context 'With a valid lat/lon' do
      it 'returns weather information' do
        VCR.use_cassette('weather_valid_location') do
          expected = { :temp=>70.14, :temp_max=>71.85, :temp_min=>69.22 }
          # Coordinates for test address 2410 Mann St., Des Moines, IA 50310
          expect(WeatherService.call(lat: 41.61745, lon: -93.65158)).to eq(expected)
        end
      end
    end

    context 'With nil lat' do
      it 'raises an exception' do
        VCR.use_cassette('weather_invalid_location') do
          expect { WeatherService.call(lat: nil, lon: -93.65158) }.to raise_error(
            StandardError,
            I18n.t('errors.invalid_location'),
          )
        end
      end
    end
  end

  describe '#parse_response' do
    context 'OpenWeatherMap response is missing information' do
      it 'raises a bad response exception' do
        body = { 'main' => {} }

        expect { WeatherService.parse_response(body) }.to raise_error(
          StandardError,
          I18n.t('errors.invalid_location'),
        )
      end
    end
  end
end