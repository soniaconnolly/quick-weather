require 'rails_helper'

RSpec.describe 'GeoLocation' do
  let(:subject) { GeoLocation.new(lat: lat, lon: lon, postal_code: postal_code, country_code: country_code) }

  # Values for test address 2410 Mann St., Des Moines, IA 50310
  let(:country_code) { 'USA' }
  let(:postal_code) { 50310 }
  let(:lat) { 41.61745 }
  let(:lon) { -93.65158 }

  describe '#valid?' do
    context 'lat and lon are numbers in the correct range' do
      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'lat is nil' do
      let(:lat) { nil }

      it 'is not valid' do
        expect(subject).not_to be_valid
      end
    end

    context 'lat is a string' do
      let(:lat) { 'ABC' }

      it 'is not valid' do
        expect(subject).not_to be_valid
      end
    end

    context 'lat is too big' do
      let(:lat) { 1000 }

      it 'is not valid' do
        expect(subject).not_to be_valid
      end
    end

    context 'lon is nil' do
      let(:lon) { nil }

      it 'is not valid' do
        expect(subject).not_to be_valid
      end
    end

    context 'lon is a string' do
      let(:lon) { 'ABC' }

      it 'is not valid' do
        expect(subject).not_to be_valid
      end
    end

    context 'lon is too big' do
      let(:lon) { 1000 }

      it 'is not valid' do
        expect(subject).not_to be_valid
      end
    end
  end

  describe '#key' do
    context 'postal_code and country_code are present' do
      it 'returns a string with the country_code and postal_code' do
        expected = "#{country_code}/#{postal_code}"
        expect(subject.key).to eq(expected)
      end
    end

    context 'postal_code is not present' do
      let(:postal_code) { nil }
      it 'returns nil' do
        expect(subject.key).to be_nil
      end
    end

    context 'country_code is not present' do
      let(:country_code) { nil }
      it 'returns nil' do
        expect(subject.key).to be_nil
      end
    end
  end
end
