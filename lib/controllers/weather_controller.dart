import 'package:get/get.dart';
import '../services/weather_service.dart';

class WeatherController extends GetxController {
  final WeatherService _weatherService = WeatherService();

  var city = ''.obs;
  var isLoading = false.obs;
  var weatherData = Rxn<Map<String, dynamic>>();
  var errorMessage = ''.obs;

  Future<void> fetchWeather(String cityName) async {
    city.value = cityName;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final data = await _weatherService.getWeather(cityName);

      if (data != null) {
        weatherData.value = data;
      } else {
        weatherData.value = null;
        errorMessage.value = 'City not found or unable to fetch weather.';
      }
    } catch (e) {
      weatherData.value = null;
      errorMessage.value = 'Failed to fetch weather data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWeatherByCoordinates(
      double lat, double lon, String cityName) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final data = await _weatherService.getWeatherByCoordinates(lat, lon, cityName);

      if (data != null) {
        weatherData.value = data;
        city.value = cityName;
      } else {
        weatherData.value = null;
        errorMessage.value = 'Unable to fetch weather for your location.';
      }
    } catch (e) {
      weatherData.value = null;
      errorMessage.value = 'Failed to fetch weather data: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
