import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenMeteoService {
  Future<Map<String, dynamic>?> getWeather(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
            '?latitude=$lat'
            '&longitude=$lon'
            '&current_weather=true'
            '&daily=temperature_2m_max,temperature_2m_min,weathercode'
            '&timezone=auto',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        print('❌ Error fetching weather: ${response.statusCode}');
        return null;
      }

      return jsonDecode(response.body);
    } catch (e) {
      print('⚠️ Exception: $e');
      return null;
    }
  }
}
