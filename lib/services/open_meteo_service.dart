import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenMeteoService {
  final String baseUrl = "https://api.open-meteo.com/v1/forecast";

  Future<Map<String, dynamic>?> fetchWeatherData({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.parse(
        "$baseUrl?latitude=$latitude&longitude=$longitude"
            "&current=temperature_2m,apparent_temperature,weathercode,wind_speed_10m,precipitation"
            "&hourly=temperature_2m,weathercode,precipitation,wind_speed_10m"
            "&daily=temperature_2m_max,temperature_2m_min,weathercode,sunrise,sunset,uv_index_max,precipitation_sum,wind_speed_10m_max"
            "&timezone=auto",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("⚠️ Failed to load weather data: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching weather data: $e");
      return null;
    }
  }
}
