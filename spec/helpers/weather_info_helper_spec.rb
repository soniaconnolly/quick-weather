require 'rails_helper'

RSpec.describe WeatherInfoHelper do
  describe '#show_cache_message' do
    let(:result) { show_cache_message(is_cached) }

    context 'is_cached is true' do
      let(:is_cached) { true }

      it 'shows the correct message' do
        expect(result).to eq(I18n.t('weather_info.labels.cached'))
      end
    end

    context 'is_cached is false' do
      let(:is_cached) { false }

      it 'shows the correct message' do
        expect(result).to eq(I18n.t('weather_info.labels.not_cached'))
      end
    end
  end
end
