import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../services/open_meteo_service.dart';

class HomeController extends GetxController {
  final OpenMeteoService _weatherService = OpenMeteoService();

  var isLoading = false.obs;
  var weatherData = Rxn<Map<String, dynamic>>();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWeatherForCurrentLocation();
  }

  Future<void> fetchWeatherForCurrentLocation() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Check permission
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        errorMessage.value = 'Location services are disabled.';
        isLoading.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          errorMessage.value = 'Location permission denied.';
          isLoading.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        errorMessage.value = 'Location permission permanently denied.';
        isLoading.value = false;
        return;
      }


      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final data = await _weatherService.getWeather(position.latitude, position.longitude);

      if (data != null) {
        weatherData.value = data;
      } else {
        errorMessage.value = 'Failed to fetch weather data.';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
