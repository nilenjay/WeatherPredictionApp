import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  Future<WeatherModel> fetchWeatherByCoords(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon'
          '&hourly=temperature_2m&daily=temperature_2m_max,temperature_2m_min,uv_index_max,sunrise,sunset'
          '&current_weather=true&timezone=auto',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return WeatherModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<WeatherModel> fetchWeatherByCity(String city) async {
    // Step 1: Get coordinates using Open-Meteo Geocoding API
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

    // Step 2: Fetch weather for those coordinates
    final weather = await fetchWeatherByCoords(lat, lon);
    return WeatherModel.fromJson(
      jsonDecode(jsonEncode(weather.toJson())),
      city: city,
    );
  }
}
