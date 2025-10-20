import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/weather_controller.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final WeatherController controller = Get.put(WeatherController());
  final TextEditingController cityController = TextEditingController();

  String getWeatherIcon(int code) {
    if (code == 0) return '☀️'; // Clear sky
    if (code == 1 || code == 2 || code == 3) return '⛅'; // Partly cloudy
    if (code == 45 || code == 48) return '🌫️'; // Fog
    if (code == 51 || code == 53 || code == 55) return '🌦️'; // Drizzle
    if (code == 61 || code == 63 || code == 65) return '🌧️'; // Rain
    if (code == 66 || code == 67) return '🌨️'; // Freezing rain
    if (code == 71 || code == 73 || code == 75) return '❄️'; // Snow
    if (code == 77) return '🌨️'; // Snow grains
    if (code == 80 || code == 81 || code == 82) return '🌧️'; // Rain showers
    if (code == 95) return '⛈️'; // Thunderstorm
    if (code == 96 || code == 99) return '⛈️🌧️'; // Thunderstorm with hail
    return '🌡️'; // Default
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 10),

            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                final city = cityController.text.trim();
                if (city.isNotEmpty) {
                  controller.fetchWeather(city);
                } else {
                  Get.snackbar('Error', 'Please enter a city name');
                }
              },
              child: controller.isLoading.value
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text('Get Weather'),
            )),

            const SizedBox(height: 20),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(
                          color: Colors.red, fontSize: 16),
                    ),
                  );
                }

                if (controller.weatherData.value == null) {
                  return const Center(
                      child: Text('Enter a city to get weather data.'));
                }

                final data = controller.weatherData.value!;

                final cityName = data['city'] ?? '';
                final currentTemp =
                (data['current_weather']['temperature'] as num).toDouble();
                final currentCode = data['current_weather']['weathercode'];
                final currentIcon = getWeatherIcon(currentCode);

                final dailyDates = data['daily']['time'] as List;
                final dailyMax = data['daily']['temperature_2m_max'] as List;
                final dailyMin = data['daily']['temperature_2m_min'] as List;
                final dailyCode = data['daily']['weathercode'] as List;

                return Column(
                  children: [
                    Text(
                      cityName,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentIcon,
                      style: const TextStyle(fontSize: 60),
                    ),
                    Text(
                      "${currentTemp.toStringAsFixed(1)}°C",
                      style: const TextStyle(fontSize: 26),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '7-Day Forecast',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    Expanded(
                      child: ListView.builder(
                        itemCount: dailyDates.length,
                        itemBuilder: (context, index) {
                          final date =
                          DateTime.parse(dailyDates[index] as String);
                          final maxTemp = (dailyMax[index] as num).toDouble();
                          final minTemp = (dailyMin[index] as num).toDouble();
                          final code = dailyCode[index];
                          final icon = getWeatherIcon(code);

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: Text(icon, style: const TextStyle(fontSize: 28)),
                              title:
                              Text(DateFormat('EEE, MMM d').format(date)),
                              subtitle: Text(
                                  'Min: ${minTemp.toStringAsFixed(1)}°C | Max: ${maxTemp.toStringAsFixed(1)}°C'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
