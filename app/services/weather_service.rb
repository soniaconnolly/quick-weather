# Obtain weather info from the OpenWeatherMap service.
# OpenWeatherMap documentation, including how to get an API key:
#  https://openweathermap.org/appid
# Note that the free tier uses version 2.5, while most of the documentation is for 3.0
# Usage: WeatherService.call(lat: nnn, lon: nnn)
# Usage: WeatherService.call_with_cache(country_code: 3 letter string, postal_code: string, lat: nnn, lon: nnn )

class WeatherService
  # Returns: a hash { temp:, temp_min:, temp_max:, cached: }
  # Temperatures are Farenheit. They can be changed to Celsius by setting units: 'metric'
  # Raises an exception for connection errors, and ambiguous or unexpected/unparseable results
  def self.call(geolocation)
    raise StandardError.new(I18n.t("errors.invalid_location")) unless geolocation.valid?

    conn = Faraday.new("https://api.openweathermap.org") do |f|
      f.request :json # encode req bodies as JSON and automatically set the Content-Type header
      f.request :retry # retry transient failures
      f.response :json # decode response bodies as JSON
    end

    response = conn.get("/data/2.5/weather", {
      appid: ENV["OPENWEATHERMAP_API_KEY"] || "FAKE_OPENWEATHERMAP_API_KEY", # Fake key for specs
      lat: geolocation.lat,
      lon: geolocation.lon,
      units: "imperial"
    })

    raise Faraday::ClientError.new I18n.t("errors.openweathermap_no_response") unless response

    self.parse_response(response.body)
  end

  # Cache the OpenWeatherMap result for 30 minutes by country_code and postal_code
  # Some countries do not have a postal code, so don't cache in that case
  # Returns: a hash { temp:, temp_min:, temp_max:, cached: }
  def self.call_with_cache(geolocation)
    return call(geolocation) if geolocation.key.blank?

    cached = Rails.cache.exist?(geolocation.key)
    result = Rails.cache.fetch(geolocation.key, expires_in: 30.minutes) do
      call(geolocation)
    end
    result[:cached] = cached if result
    result
  end

  # Parse the response from the OpenWeatherMap service.
  # This is only public to allow testing of unexpected responses
  def self.parse_response(body)
    raise StandardError.new(I18n.t("errors.invalid_location")) if body.blank? || body["main"].blank?

    begin
      main = body["main"]
      # Return a hash with symbol keys :temp, :temp_min, :temp_max
      {
        temp: main["temp"],
        temp_min: main["temp_min"],
        temp_max: main["temp_max"]
      }
    rescue ArgumentError, NoMethodError => e
      # If the response doesn't have the format we expect
      raise Faraday::ClientError.new(I18n.t("errors.openweathermap_bad_response"))
    end
  end
end
