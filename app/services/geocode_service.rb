# Geocode an address with the HERE service (ArcGIS doesn't seem to have a free tier anymore.)
# HERE documentation, including how to get an API key:
#  https://www.here.com/docs/bundle/geocoding-and-search-api-developer-guide/page/topics/quick-start.html
#
# Usage: GeocodeService.call(address)
# Returns: { lat:, lon: }, a hash with symbolic keys lat:, lon: (to match OpenWeatherMap args)
# Raises an exception for connection errors, and ambiguous or unexpected/unparseable results
class GeocodeService
  def self.call(address)
    conn = Faraday.new("https://geocode.search.hereapi.com") do |f|
      f.request :json # encode req bodies as JSON and automatically set the Content-Type header
      f.request :retry # retry transient failures
      f.response :json # decode response bodies as JSON
    end
    
    response = conn.get('/v1/geocode', {
      apiKey: ENV['HERE_API_KEY'],
      q: address,
    })

    raise Faraday::ClientError.new I18n.t('errors.geocoder_no_response') unless response

    self.parse_response(response.body)
  end

  # Parse the response from the HERE service.
  # This is only public to allow testing of unexpected responses
  def self.parse_response(body)
    raise StandardError.new(I18n.t('errors.invalid_address')) if body.blank? || body['items'].blank?
    
    begin
      raise StandardError.new(I18n.t('errors.ambiguous_address')) if body['items'].count != 1

      position = body['items'].first['position']
      # Return a hash with symbol keys :lat, :lon
      { lat: position['lat'], lon: position['lng'] }
    rescue ArgumentError, NoMethodError => e
      # If the response doesn't have the format we expect
      raise Faraday::ClientError.new(I18n.t('errors.geocoder_bad_response'))
    end
  end
end