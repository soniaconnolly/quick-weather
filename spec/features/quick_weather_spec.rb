require 'rails_helper'

RSpec.describe 'Quick Weather' do
  it 'shows temperatures for an address' do
    address = '2410 Mann Ave, Des Moines, IA 50310'
    visit root_url
    fill_in 'address', with: address
    VCR.use_cassette('quick_weather') do
      click_button I18n.t('weather_info.labels.submit')
    end

    expect(page).to have_text(I18n.t('weather_info.labels.current_temp', temp: 59.25))
    expect(page).to have_text(I18n.t('weather_info.labels.min_temp', temp: 57.38))
    expect(page).to have_text(I18n.t('weather_info.labels.max_temp', temp: 61.21))
  end

  it 'shows a message for an ambiguous address' do
    address = 'Springfield'
    visit root_url
    fill_in 'address', with: address
    VCR.use_cassette('quick_weather_ambiguous') do
      click_button I18n.t('weather_info.labels.submit')
    end

    expect(page).to have_text(I18n.t('errors.ambiguous_address'))
  end
end
