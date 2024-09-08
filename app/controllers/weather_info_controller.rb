class WeatherInfoController < ApplicationController
  def show
    @address = params['address']

    begin
      if @address
        geolocation = GeocodeService.call(@address)
        if geolocation
          @weather = WeatherService.call_with_cache(geolocation)
        end
      end
    rescue => e
      flash.now['alert'] = e.message
    end
  end
end
