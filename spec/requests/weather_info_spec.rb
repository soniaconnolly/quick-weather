require 'rails_helper'

RSpec.describe "WeatherInfo", type: :request do
  describe 'GET /show' do
    it 'returns http success' do
      address = '2410 Mann St., Des Moines, IA 50310'
      get weather_info_show_url, params: { address: address }
      expect(response).to have_http_status(:success)
    end
  end
end
