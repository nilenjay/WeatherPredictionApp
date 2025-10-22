// lib/models/weather_model.dart
class WeatherModel {
  final String city;
  final double temperature;
  final double windspeed;
  final int weatherCode;
  final double humidity;    // relative humidity percentage
  final double uvIndex;
  final DateTime sunrise;
  final DateTime sunset;
  final double rainfall;    // daily precipitation sum (mm)
  final int airQuality;     // numeric AQI (mock / placeholder)
  final List<String> dates;
  final List<double> tempMin;
  final List<double> tempMax;
  final List<String> hourlyTimes;
  final List<double> hourlyTemps;
  final List<double>? hourlyPrecipitation;
  final List<double>? hourlyHumidity;

  WeatherModel({
    required this.city,
    required this.temperature,
    required this.windspeed,
    required this.weatherCode,
    required this.humidity,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.rainfall,
    required this.airQuality,
    required this.dates,
    required this.tempMin,
    required this.tempMax,
    required this.hourlyTimes,
    required this.hourlyTemps,
    this.hourlyPrecipitation,
    this.hourlyHumidity,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, {String city = "Unknown"}) {
    final current = json['current_weather'] ?? {};
    final daily = json['daily'] ?? {};
    final hourly = json['hourly'] ?? {};

    // parse daily values with safety
    double parsedUv = 0;
    try {
      parsedUv = (daily['uv_index_max']?[0] ?? 0).toDouble();
    } catch (_) {
      parsedUv = 0;
    }

    double parsedRainfall = 0;
    try {
      parsedRainfall = (daily['precipitation_sum']?[0] ?? 0).toDouble();
    } catch (_) {
      parsedRainfall = 0;
    }

    // Attempt to get a representative humidity value from hourly data (first entry)
    double parsedHumidity = 50;
    try {
      if (hourly['relativehumidity_2m'] != null && hourly['relativehumidity_2m'].isNotEmpty) {
        parsedHumidity = (hourly['relativehumidity_2m'][0] ?? 50).toDouble();
      } else {
        parsedHumidity = 50;
      }
    } catch (_) {
      parsedHumidity = 50;
    }

    // Simple deterministic placeholder AQI calculation:
    // NOTE: This is a placeholder. Replace with a real AQI API later.
    // We combine humidity and uv to create a number in a plausible AQI range.
    int placeholderAqi = (parsedHumidity * 0.6 + parsedUv * 4 + 10).round();
    if (placeholderAqi < 0) placeholderAqi = 0;
    if (placeholderAqi > 500) placeholderAqi = 500;

    return WeatherModel(
      city: city,
      temperature: (current['temperature'] ?? 0).toDouble(),
      windspeed: (current['windspeed'] ?? 0).toDouble(),
      weatherCode: (current['weathercode'] ?? 0).toInt(),
      humidity: parsedHumidity,
      uvIndex: parsedUv,
      sunrise: DateTime.parse(daily['sunrise']?[0] ?? DateTime.now().toIso8601String()),
      sunset: DateTime.parse(daily['sunset']?[0] ?? DateTime.now().toIso8601String()),
      rainfall: parsedRainfall,
      airQuality: placeholderAqi,
      dates: List<String>.from(daily['time'] ?? []),
      tempMin: List<double>.from((daily['temperature_2m_min'] ?? []).map((e) => (e ?? 0).toDouble())),
      tempMax: List<double>.from((daily['temperature_2m_max'] ?? []).map((e) => (e ?? 0).toDouble())),
      hourlyTimes: List<String>.from(hourly['time'] ?? []),
      hourlyTemps: List<double>.from((hourly['temperature_2m'] ?? []).map((e) => (e ?? 0).toDouble())),
      hourlyPrecipitation: (hourly['precipitation'] != null)
          ? List<double>.from((hourly['precipitation'] ?? []).map((e) => (e ?? 0).toDouble()))
          : null,
      hourlyHumidity: (hourly['relativehumidity_2m'] != null)
          ? List<double>.from((hourly['relativehumidity_2m'] ?? []).map((e) => (e ?? 0).toDouble()))
          : null,
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
    "rainfall": rainfall,
    "airQuality": airQuality,
    "dates": dates,
    "tempMin": tempMin,
    "tempMax": tempMax,
    "hourlyTimes": hourlyTimes,
    "hourlyTemps": hourlyTemps,
    "hourlyPrecipitation": hourlyPrecipitation,
    "hourlyHumidity": hourlyHumidity,
  };
}
