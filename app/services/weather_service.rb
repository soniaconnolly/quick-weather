# Obtain weather info from the OpenWeatherMap service.
# OpenWeatherMap documentation, including how to get an API key:
#  https://openweathermap.org/appid
# Note that the free tier uses version 2.5, while most of the documentation is for 3.0
# Usage: WeatherService.call(lat: nnn, lon: nnn)
# Returns: { temp:, temp_min:, temp_max: }, a hash with symbolic keys temp:, temp_min:, temp_max:
# Temperatures are Farenheit. They can be changed to Celsius by setting units: 'metric'
# Raises an exception for connection errors, and ambiguous or unexpected/unparseable results
class WeatherService
  def self.call(lat:, lon:)
    conn = Faraday.new("https://api.openweathermap.org") do |f|
      f.request :json # encode req bodies as JSON and automatically set the Content-Type header
      f.request :retry # retry transient failures
      f.response :json # decode response bodies as JSON
    end

    response = conn.get('/data/2.5/weather', {
      appid: ENV['OPENWEATHERMAP_API_KEY'],
      lat: lat,
      lon: lon,
      units: 'imperial',
    })

    raise Faraday::ClientError.new I18n.t('errors.openweathermap_no_response') unless response

    self.parse_response(response.body)
  end

  # Parse the response from the OpenWeatherMap service.
  # This is only public to allow testing of unexpected responses
  def self.parse_response(body)
    raise StandardError.new(I18n.t('errors.invalid_location')) if body.blank? || body['main'].blank?
    
    begin
      main = body['main']
      # Return a hash with symbol keys :temp, :temp_min, :temp_max
      {
        temp: main['temp'],
        temp_min: main['temp_min'],
        temp_max: main['temp_max'],
      }
    rescue ArgumentError, NoMethodError => e
      # If the response doesn't have the format we expect
      raise Faraday::ClientError.new(I18n.t('errors.openweathermap_bad_response'))
    end
  end
end