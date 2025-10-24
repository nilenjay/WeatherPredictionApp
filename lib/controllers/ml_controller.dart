import 'package:get/get.dart';
import '../services/custom_weather_service.dart';

class MLController extends GetxController {
  final SeattleWeatherService _service = SeattleWeatherService();

  var isLoading = false.obs;
  var currentWeather = <String, dynamic>{}.obs;
  var weeklyForecast = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _service.getWeatherData();
      if (data != null) {
        currentWeather.assignAll(data['current'] ?? {});
        weeklyForecast.assignAll(data['weekly'] ?? []);
      } else {
        errorMessage.value = 'No forecast data found.';
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch forecast: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
