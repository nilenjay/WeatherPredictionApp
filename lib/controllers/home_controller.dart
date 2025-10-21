import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class HomeController extends GetxController {
  var weatherData = Rxn<WeatherModel>(); // ✅ Typed variable instead of Map
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final WeatherService _weatherService = WeatherService();

  @override
  void onInit() {
    super.onInit();
    fetchWeatherForCurrentLocation();
  }

  /// ✅ Fetch weather for current location
  Future<void> fetchWeatherForCurrentLocation() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      Position position = await _determinePosition();
      final data = await _weatherService.fetchWeatherByCoords(
        position.latitude,
        position.longitude,
      );

      weatherData.value = data;
    } catch (e) {
      errorMessage.value = 'Failed to fetch location weather: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Fetch weather by city name (for SearchScreen)
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

  /// ✅ Determine user location
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }

    return await Geolocator.getCurrentPosition();
  }
}
