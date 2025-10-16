import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {

  Future<Map<String, dynamic>?> getCoordinates(String cityName) async {
    try {
      final url = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=$cityName',
      );
      final response = await http.get(url);

      if (response.statusCode != 200) {
        print('❌ Geocoding failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      if (data['results'] == null || data['results'].isEmpty) return null;

      final firstResult = data['results'][0];
      return {
        'name': firstResult['name'],
        'latitude': firstResult['latitude'],
        'longitude': firstResult['longitude'],
      };
    } catch (e) {
      print('⚠️ Error fetching coordinates: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getWeatherByCoordinates(
      double lat, double lon, String cityName) async {
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=temperature_2m_max,temperature_2m_min,weathercode&current_weather=true&timezone=auto',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        print('❌ Forecast fetch failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      data['city'] = cityName;

      return data;
    } catch (e) {
      print('⚠️ Error fetching weather: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getWeather(String cityName) async {
    final coords = await getCoordinates(cityName);
    if (coords == null) return null;

    return await getWeatherByCoordinates(
      coords['latitude'],
      coords['longitude'],
      coords['name'],
    );
  }
}
