class WeatherInfoController < ApplicationController
  # If there is an address parameter, call GeocodeService to get lat/long info,
  # and WeatherService to get current, high, and low temperatures.
  def show
    @address = params["address"]

    begin
      if @address.present?
        geolocation = GeocodeService.call(@address)
        if geolocation
          @weather = WeatherService.call_with_cache(geolocation)
        end
      end
    rescue => e
      flash.now["alert"] = e.message
    end
  end
end
