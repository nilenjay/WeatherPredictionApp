import 'package:get/get.dart';
import '../models/weather_model.dart';
import '../services/search_weather_service.dart';

class SearchWeatherController extends GetxController {
  final WeatherService _weatherService = WeatherService();

  var weatherData = Rx<WeatherModel?>(null);
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  /// Fetch weather for a given city name
  Future<void> fetchWeatherForCity(String cityName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      weatherData.value = null;

      final WeatherModel weather = await _weatherService.fetchWeatherByCity(cityName);

      weatherData.value = weather;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear previous search
  void clear() {
    weatherData.value = null;
    errorMessage.value = '';
    isLoading.value = false;
  }
}
