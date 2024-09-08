class WeatherInfoController < ApplicationController
  def show
    @address = params['address']

    begin
      if @address
        position = GeocodeService.call(@address)
        if position
          @weather = WeatherService.call(lat: position[:lat], lon: position[:lon])
        end
      end
    rescue => e
      flash.now['alert'] = e.message
    end
  end
end
