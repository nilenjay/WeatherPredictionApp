class WeatherModel {
  final String city;
  final double temperature;
  final double windspeed;
  final int windDirection;
  final double humidity;
  final double uvIndex;
  final String weatherDescription;
  final DateTime sunrise;
  final DateTime sunset;

  WeatherModel({
    required this.city,
    required this.temperature,
    required this.windspeed,
    required this.windDirection,
    required this.humidity,
    required this.uvIndex,
    required this.weatherDescription,
    required this.sunrise,
    required this.sunset,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, String city) {
    final current = json['current_weather'] ?? {};
    final daily = json['daily'] ?? {};
    final hourly = json['hourly'] ?? {};

    return WeatherModel(
      city: city,
      temperature: (current['temperature'] ?? 0).toDouble(),
      windspeed: (current['windspeed'] ?? 0).toDouble(),
      windDirection: (current['winddirection'] ?? 0).toInt(),
      humidity: (hourly['relative_humidity_2m']?[0] ?? 0).toDouble(),
      uvIndex: (daily['uv_index_max']?[0] ?? 0).toDouble(),
      weatherDescription: (current['weathercode']?.toString() ?? 'Unknown'),
      sunrise: DateTime.tryParse(daily['sunrise']?[0] ?? '') ?? DateTime.now(),
      sunset: DateTime.tryParse(daily['sunset']?[0] ?? '') ?? DateTime.now(),
    );
  }
}
