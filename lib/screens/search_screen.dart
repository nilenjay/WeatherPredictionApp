import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_weather_controller.dart';
import '../models/weather_model.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final SearchWeatherController controller = Get.put(SearchWeatherController());
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController cityController = TextEditingController();

  IconData getInfoIcon(String type) {
    switch (type) {
      case "Wind":
        return Icons.air;
      case "Humidity":
        return Icons.water_drop;
      case "UV":
        return Icons.wb_sunny;
      case "Sunrise":
      case "Sunset":
        return Icons.wb_twilight;
      default:
        return Icons.info;
    }
  }

  IconData getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny; // clear sky
    if (code == 1 || code == 2 || code == 3) return Icons.cloud;
    if (code == 45 || code == 48) return Icons.grain;
    if ([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82].contains(code)) {
      return Icons.umbrella;
    }
    if ([71, 73, 75, 77, 85, 86].contains(code)) return Icons.ac_unit;
    if ([95, 96, 99].contains(code)) return Icons.thunderstorm;
    return Icons.wb_cloudy;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('hh:mm a');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Search City',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/SearchBG 3.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.3),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
            child: Column(
              children: [

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: cityController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter city name',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  onPressed: () async {
                    final cityName = cityController.text.trim();
                    if (cityName.isNotEmpty) {
                      await controller.fetchWeatherForCity(cityName);
                    }
                  },
                  child: const Text(
                    'Search',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                Obx(() {
                  if (controller.weatherData.value == null) return const SizedBox.shrink();

                  return ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: const Icon(Icons.bookmark, color: Colors.white),
                    label: const Text(
                      "Save City",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      await saveCity(controller.weatherData.value!.city);
                    },
                  );
                }),
                const SizedBox(height: 20),

                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (controller.errorMessage.isNotEmpty) {
                      return Center(
                        child: Text(
                          controller.errorMessage.value,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                        ),
                      );
                    }
                    final WeatherModel? data = controller.weatherData.value;
                    if (data == null) {
                      return const Center(
                        child: Text(
                          'Search for a city to view weather details.',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            data.city,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${data.temperature.toStringAsFixed(1)}°C",
                            style: const TextStyle(
                              fontSize: 48,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _infoCard("Wind", "${data.windspeed.toStringAsFixed(1)} km/h"),
                              _infoCard("Humidity", "${data.humidity.toStringAsFixed(0)}%"),
                              _infoCard("UV", "${data.uvIndex.toStringAsFixed(1)}"),
                              _infoCard("Sunrise", dateFormatter.format(data.sunrise)),
                              _infoCard("Sunset", dateFormatter.format(data.sunset)),
                            ],
                          ),
                          const SizedBox(height: 25),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Weekly Forecast",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 140,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: data.dates.length,
                              itemBuilder: (context, index) {
                                final int code = (data.dailyWeatherCodes != null &&
                                    data.dailyWeatherCodes.isNotEmpty &&
                                    index < data.dailyWeatherCodes.length)
                                    ? data.dailyWeatherCodes[index]
                                    : data.weatherCode;

                                return Container(
                                  width: 100,
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(getWeatherIcon(code), color: Colors.yellowAccent, size: 30),
                                      const SizedBox(height: 6),
                                      Text(
                                            () {
                                          try {
                                            final dt = DateTime.parse(data.dates[index]);
                                            return DateFormat.E().format(dt);
                                          } catch (_) {
                                            return data.dates[index];
                                          }
                                        }(),
                                        style: const TextStyle(color: Colors.white70),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${data.tempMax[index].toStringAsFixed(1)}° / ${data.tempMin[index].toStringAsFixed(1)}°",
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(getInfoIcon(title), color: Colors.yellowAccent, size: 28),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> saveCity(String cityName) async {
    final user = _authController.auth.currentUser;
    if (user == null) {
      Get.snackbar("Error", "You must be logged in to save a city", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final userDoc = _authController.firestore.collection('users').doc(user.uid);
      await userDoc.update({
        'savedCities': FieldValue.arrayUnion([cityName])
      });

      Get.snackbar("Saved", "$cityName has been saved to your profile", snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      await _authController.firestore.collection('users').doc(user.uid).set({
        'savedCities': [cityName],
      }, SetOptions(merge: true));

      Get.snackbar("Saved", "$cityName has been saved to your profile", snackPosition: SnackPosition.BOTTOM);
    }
  }
}
