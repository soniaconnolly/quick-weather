class WeatherInfoController < ApplicationController
  def show
    @address = params['address']

    begin
      if @address
        geocode = GeocodeService.call(@address)
        if geocode
          @weather = WeatherService.call_with_cache(
            country_code: geocode[:country_code],
            postal_code: geocode[:postal_code],
            lat: geocode[:lat],
            lon: geocode[:lon]
          )
        end
      end
    rescue => e
      flash.now['alert'] = e.message
    end
  end
end
