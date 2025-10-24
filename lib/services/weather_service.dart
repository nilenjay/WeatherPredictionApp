
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  Future<WeatherModel> fetchWeatherByCoords(double lat, double lon) async {

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
          '?latitude=$lat&longitude=$lon'
          '&hourly=temperature_2m,relativehumidity_2m,precipitation'
          '&daily=temperature_2m_max,temperature_2m_min,uv_index_max,sunrise,sunset,precipitation_sum'
          '&current_weather=true&timezone=auto',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return WeatherModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to load weather data (${response.statusCode})');
    }
  }

  Future<WeatherModel> fetchWeatherByCity(String city) async {
    // Geocoding to get coords
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

    final weather = await fetchWeatherByCoords(lat, lon);

    // Return with city name set
    return WeatherModel.fromJson(jsonDecode(jsonEncode(weather.toJson())), city: city);
  }
}
