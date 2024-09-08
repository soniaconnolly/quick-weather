module WeatherInfoHelper
  # Display a message telling the user whether the info is cached or not.
  def show_cache_message(is_cached)
    is_cached ? t("weather_info.labels.cached")
              : t("weather_info.labels.not_cached")
  end
end
