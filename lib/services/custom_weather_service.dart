import 'dart:convert';

import 'package:http/http.dart' as http;

class SeattleWeatherService {
  final String baseUrl = 'https://weatherpredictionapp-2.onrender.com/predict';

  Future<Map<String, dynamic>?> getWeatherData() async {
    try {
      final url = Uri.parse(baseUrl);
      final response = await http.get(url);

      if (response.statusCode != 200) {
        print('❌ Forecast fetch failed: ${response.statusCode}');
        return null;
      }

      final List<dynamic> data = jsonDecode(response.body);

      if (data.isEmpty) return null;

      /// today’s current weather
      final currentWeather = data[0] as Map<String, dynamic>;

      /// Weekly forecast (all days)
      final weeklyForecast = data.cast<Map<String, dynamic>>();

      return {
        'current': currentWeather,
        'weekly': weeklyForecast,
      };
    } catch (e) {
      print('⚠️ Error fetching forecast: $e');
      return null;
    }
  }
}
