import 'package:get/get.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class QuickAccessController extends GetxController {
  final WeatherService _service = WeatherService();

  var isLoading = true.obs;
  var errorMessage = ''.obs;

  var city = ''.obs;
  var temperature = 0.0.obs;
  var windspeed = 0.0.obs;
  var weatherCode = 0.obs;
  var humidity = 0.0.obs;
  var uvIndex = 0.0.obs;
  var sunrise = DateTime.now().obs;
  var sunset = DateTime.now().obs;
  var rainfall = 0.0.obs;
  var airQuality = 0.obs;

  var dates = <String>[].obs;
  var tempMin = <double>[].obs;
  var tempMax = <double>[].obs;
  var dailyWeatherCodes = <int>[].obs;

  Future<void> fetchWeather(String cityName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final WeatherModel data = await _service.fetchWeatherByCity(cityName);

      city.value = data.city;
      temperature.value = data.temperature;
      windspeed.value = data.windspeed;
      weatherCode.value = data.weatherCode;
      humidity.value = data.humidity;
      uvIndex.value = data.uvIndex;
      sunrise.value = data.sunrise;
      sunset.value = data.sunset;
      rainfall.value = data.rainfall;
      airQuality.value = data.airQuality;

      dates.assignAll(data.dates);
      tempMin.assignAll(data.tempMin);
      tempMax.assignAll(data.tempMax);
      dailyWeatherCodes.assignAll(data.dailyWeatherCodes);
    } catch (e) {
      errorMessage.value = 'Failed to fetch weather: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
