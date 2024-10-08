require 'rails_helper'

RSpec.describe 'WeatherService' do
  describe '#call' do
      let(:geolocation) { GeoLocation.new(lat: lat, lon: lon) }
      # Coordinates for test address 2410 Mann St., Des Moines, IA 50310
      let(:lat) { 41.61745 }
      let(:lon) { -93.65158 }

      context 'With a valid lat/lon' do
      it 'returns weather information' do
        expected = { temp: 59.25, temp_max: 61.21, temp_min: 57.38 }
        VCR.use_cassette('weather_valid_location') do
          expect(WeatherService.call(geolocation)).to eq(expected)
        end
      end
    end

    context 'With nil lat' do
      let(:lat) { nil }
      it 'raises an exception' do
        VCR.use_cassette('weather_invalid_location') do
          expect { WeatherService.call(geolocation) }.to raise_error(
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

  describe '#call_with_cache' do
    let(:geolocation) { GeoLocation.new(lat: lat, lon: lon, country_code: country_code, postal_code: postal_code) }
    # Coordinates for test address 2410 Mann St., Des Moines, IA 50310
    let(:country_code) { 'USA' }
    let(:postal_code) { 50310 }
    let(:lat) { 41.61745 }
    let(:lon) { -93.65158 }
    let(:expected) { { temp: 59.25, temp_max: 61.21, temp_min: 57.38, cached: cached } }

    context 'value is not cached' do
      let(:cached) { false }

      it 'makes the network call' do
        VCR.use_cassette('weather_valid_location') do
          allow(Rails.cache).to receive(:exist?).with(geolocation.key).and_return(cached)
          expect(Faraday).to receive(:new).and_call_original
          expect(WeatherService.call_with_cache(geolocation)).to eq(expected)
        end
      end
    end

    context 'value is cached' do
      let(:cached) { true }

      it 'returns the cached value' do
        cached_value = { temp: 59.25, temp_max: 61.21, temp_min: 57.38 }

        allow(Rails.cache).to receive(:exist?).with(geolocation.key).and_return(cached)
        allow(Rails.cache).to receive(:fetch).with(geolocation.key, { expires_in: 30.minutes }).and_return(cached_value)
        expect(Faraday).not_to receive(:new).and_call_original
        expect(WeatherService.call_with_cache(geolocation)).to eq(expected)
      end
    end

    context 'postal_code is nil' do
      # Timor Leste does not have postal_codes
      let(:postal_code) { nil }
      let(:country_code) { 'TLS' }
      let(:lat) { -8.55409 }
      let(:lon) { 125.57033 }
      let(:expected) { { temp: 84.45, temp_max: 84.45, temp_min: 84.45 } }

      it 'makes the network call and does not cache it' do
        VCR.use_cassette('weather_timor_leste') do
          expect(Rails.cache).not_to receive(:exist?)
          expect(Faraday).to receive(:new).and_call_original
          expect(WeatherService.call_with_cache(geolocation)).to eq(expected)
        end
      end
    end
  end
end
