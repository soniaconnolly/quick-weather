require 'rails_helper'

RSpec.describe 'weather_info/show.html.erb', type: :view do
  context 'no params' do
    it 'displays an address field' do
      render

      expect(rendered).to include I18n.t('weather_info.labels.address')
      expect(rendered).to include '<input type="text" name="address" id="address" size="70" />'
    end

    it 'displays the heading' do
      render

      expect(rendered).to include I18n.t('weather_info.heading')
    end
  end

  context '@weather has values' do
    let(:temp) { 60 }
    let(:temp_min) { 50 }
    let(:temp_max) { 70 }
    let(:cached) { false }

    before do
      assign(:weather, { temp: temp, temp_min: temp_min, temp_max: temp_max, cached: cached} )

      render
    end

    it 'displays the current temperature' do
      expect(rendered).to include I18n.t('weather_info.labels.current_temp', temp: temp)
    end

    it 'displays the min temperature' do
      expect(rendered).to include I18n.t('weather_info.labels.min_temp', temp: temp_min)
    end

    it 'displays the current temperature' do
      expect(rendered).to include I18n.t('weather_info.labels.max_temp', temp: temp_max)
    end

    it 'displays the not_cached message' do
      expect(rendered).to include I18n.t('weather_info.labels.not_cached')
    end

    context 'cached is true' do
      let(:cached) { true }

      it 'displays the cached message' do
        expect(rendered).to include I18n.t('weather_info.labels.cached')
      end
    end
  end
end
