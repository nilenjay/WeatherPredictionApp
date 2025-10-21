import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherController extends GetxController {
  var weatherData = Rxn<WeatherModel>(); // reactive model
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final WeatherService _weatherService = WeatherService();

  @override
  void onInit() {
    super.onInit();
    fetchWeatherByLocation(); // auto-fetch on start
  }

  /// ✅ Fetch weather using current location
  Future<void> fetchWeatherByLocation() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        errorMessage.value = 'Location services are disabled.';
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          errorMessage.value = 'Location permissions are denied.';
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        errorMessage.value = 'Location permissions are permanently denied.';
        return;
      }

      // ✅ Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // ✅ Fetch weather from service
      final data = await _weatherService.fetchWeatherByCoords(
        position.latitude,
        position.longitude,
      );

      weatherData.value = data;
    } catch (e) {
      errorMessage.value = 'Failed to fetch weather: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Fetch weather by city name (used in search)
  Future<void> fetchWeatherForCity(String city) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await _weatherService.fetchWeatherByCity(city);
      weatherData.value = data;
    } catch (e) {
      errorMessage.value = 'Failed to fetch weather for $city: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
