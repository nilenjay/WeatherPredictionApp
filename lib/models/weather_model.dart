class WeatherModel {
  final String city;
  final double temperature;
  final double windspeed;
  final int weatherCode;
  final double humidity;
  final double uvIndex;
  final DateTime sunrise;
  final DateTime sunset;
  final List<String> dates;
  final List<double> tempMin;
  final List<double> tempMax;
  final List<String> hourlyTimes;
  final List<double> hourlyTemps;

  WeatherModel({
    required this.city,
    required this.temperature,
    required this.windspeed,
    required this.weatherCode,
    required this.humidity,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.dates,
    required this.tempMin,
    required this.tempMax,
    required this.hourlyTimes,
    required this.hourlyTemps,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, {String city = "Unknown"}) {
    final current = json['current_weather'];
    final daily = json['daily'];
    final hourly = json['hourly'];

    return WeatherModel(
      city: city,
      temperature: (current['temperature'] ?? 0).toDouble(),
      windspeed: (current['windspeed'] ?? 0).toDouble(),
      weatherCode: (current['weathercode'] ?? 0).toInt(),
      humidity: 50, // placeholder (Open-Meteo doesn't provide humidity in current_weather)
      uvIndex: (daily['uv_index_max'][0] ?? 0).toDouble(),
      sunrise: DateTime.parse(daily['sunrise'][0]),
      sunset: DateTime.parse(daily['sunset'][0]),
      dates: List<String>.from(daily['time']),
      tempMin: List<double>.from(daily['temperature_2m_min'].map((e) => e.toDouble())),
      tempMax: List<double>.from(daily['temperature_2m_max'].map((e) => e.toDouble())),
      hourlyTimes: List<String>.from(hourly['time']),
      hourlyTemps: List<double>.from(hourly['temperature_2m'].map((e) => e.toDouble())),
    );
  }

  Map<String, dynamic> toJson() => {
    "city": city,
    "temperature": temperature,
    "windspeed": windspeed,
    "weatherCode": weatherCode,
    "humidity": humidity,
    "uvIndex": uvIndex,
    "sunrise": sunrise.toIso8601String(),
    "sunset": sunset.toIso8601String(),
    "dates": dates,
    "tempMin": tempMin,
    "tempMax": tempMax,
    "hourlyTimes": hourlyTimes,
    "hourlyTemps": hourlyTemps,
  };
}
