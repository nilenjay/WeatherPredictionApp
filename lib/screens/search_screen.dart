import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../models/weather_model.dart';
import 'home_screen.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final HomeController controller = Get.put(HomeController());
  final TextEditingController cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search City'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                hintText: 'Enter city name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final cityName = cityController.text.trim();
                if (cityName.isNotEmpty) {
                  await controller.fetchWeatherForCity(cityName);
                  Get.to(() => HomeScreen());
                }
              },
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.isNotEmpty) {
                  return Center(
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                }

                final WeatherModel? data = controller.weatherData.value;
                if (data == null) {
                  return const Center(child: Text('Search for a city.'));
                }

                // ✅ Use dot notation instead of [] operator
                final cityName = data.city;
                final temperature = data.temperature;
                final windSpeed = data.windspeed;
                final humidity = data.humidity;
                final uvIndex = data.uvIndex;
                final sunrise = data.sunrise;
                final sunset = data.sunset;
                final dailyDates = data.dates;
                final dailyMax = data.tempMax;
                final dailyMin = data.tempMin;

                return ListView(
                  children: [
                    Text(
                      cityName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "$temperature°C",
                      style: const TextStyle(fontSize: 40),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Wind: $windSpeed km/h | Humidity: $humidity% | UV: $uvIndex",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Sunrise: ${sunrise.hour}:${sunrise.minute} | Sunset: ${sunset.hour}:${sunset.minute}",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "7-Day Forecast",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    for (int i = 0; i < dailyDates.length; i++)
                      Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(dailyDates[i]),
                          subtitle: Text(
                              "Min: ${dailyMin[i]}°C | Max: ${dailyMax[i]}°C"),
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
