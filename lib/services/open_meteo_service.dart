import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class OpenMeteoService {
  Future<WeatherModel> fetchWeatherData(String city) async {
    // 🔹 Temporary coordinates — replace with dynamic ones later
    const lat = 28.6139; // Delhi latitude
    const lon = 77.2090; // Delhi longitude

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
          '?latitude=$lat&longitude=$lon'
          '&current_weather=true'
          '&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max'
          '&hourly=relative_humidity_2m,precipitation,weathercode'
          '&timezone=auto',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load weather data');
    }

    final data = jsonDecode(response.body);
    return WeatherModel.fromJson(data, city: city);
  }
}
