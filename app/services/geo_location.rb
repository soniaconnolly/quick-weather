# A GeoLocation holds the information that is returned from GeocodeService that is needed
# by the WeatherService
# It holds a latitude, longitude, country_code, and postal_code
class GeoLocation
  attr_reader :lat, :lon, :country_code, :postal_code

  def initialize(lat:, lon:, country_code:, postal_code:)
    @lat = lat
    @lon = lon
    @country_code = country_code
    @postal_code = postal_code
  end

  # A GeoLocation is valid if latitude and longitude are valid
  def valid?
    valid_coordinate(lat, 90) && valid_coordinate(lon, 180)
  end

  # Return a cache key combining country code and postal code
  # Some countries don't have postal_codes, so return nil in that case
  # Also return nil if country_code is not present
  def key
    return if postal_code.blank? || country_code.blank?

    "#{country_code}/#{postal_code}"
  end

  private

  # Latitude must be a number between -90 and +90
  # Longitude must be a number between -180 and +180
  def valid_coordinate(value, limit)
    value.present? && value.is_a?(Numeric) && value.abs <= limit
  end
end
