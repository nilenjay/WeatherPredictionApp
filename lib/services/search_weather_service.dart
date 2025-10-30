import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  /// Fetch weather by coordinates
  Future<WeatherModel> fetchWeatherByCoords(double lat, double lon, {String cityName = "Unknown"}) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
          '?latitude=$lat&longitude=$lon'
          '&current_weather=true'
          '&hourly=temperature_2m,relativehumidity_2m,precipitation,weathercode'
          '&daily=temperature_2m_max,temperature_2m_min,uv_index_max,sunrise,sunset,precipitation_sum'
          '&timezone=auto',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch weather data (${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    return WeatherModel.fromJson(data, city: cityName);
  }

  /// Fetch weather by city name
  Future<WeatherModel> fetchWeatherByCity(String city) async {
   /// Geocoding API to get coordinates
    final geoUrl = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1');
    final geoResponse = await http.get(geoUrl);

    if (geoResponse.statusCode != 200) {
      throw Exception('Failed to get coordinates for $city');
    }

    final geoData = jsonDecode(geoResponse.body);
    if (geoData['results'] == null || geoData['results'].isEmpty) {
      throw Exception('City not found: $city');
    }

    final lat = geoData['results'][0]['latitude'];
    final lon = geoData['results'][0]['longitude'];

    /// Fetch weather using coords
    return fetchWeatherByCoords(lat, lon, cityName: city);
  }
}
