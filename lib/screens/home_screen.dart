import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wtf_sliding_sheet/wtf_sliding_sheet.dart';
import '../controllers/weather_controller.dart';

class HomeScreen extends StatelessWidget {
  final WeatherController controller = Get.put(WeatherController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        final weather = controller.weatherData.value;
        if (weather == null) {
          return const Center(child: Text("No weather data available"));
        }

        return Stack(
          children: [
            /// 🔹 Background Image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/Image.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// 🔹 Illustration on top of background
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Image.asset(
                "assets/hut.png", // your illustration
                height: 200,
                fit: BoxFit.contain,
              ),
            ),

            /// 🔹 Top Weather Info (city + temperature) above sliding sheet
            Positioned(
              top: 50,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    weather.city,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${weather.temperature.toStringAsFixed(1)}°C",
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Wind: ${weather.windspeed.toStringAsFixed(1)} km/h",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            /// 🔹 Sliding Sheet with transparency and blur
            SlidingSheet(
              elevation: 0,
              cornerRadius: 30,
              snapSpec: const SnapSpec(
                snap: true,
                snappings: [0.45, 0.75, 1.0],
                positioning: SnapPositioning.relativeToAvailableSpace,
              ),
              // Make sliding sheet start below illustration
              minHeight: MediaQuery.of(context).size.height * 0.45,
              builder: (context, state) {
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      color: Colors.white.withOpacity(0.2), // semi-transparent
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🔹 Hourly Forecast
                          const Text(
                            "Hourly Forecast",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: weather.hourlyTimes.length.clamp(0, 24),
                              itemBuilder: (context, index) {
                                final time = weather.hourlyTimes[index].split('T').last;
                                final temp = weather.hourlyTemps[index];
                                return Container(
                                  width: 70,
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(time, style: const TextStyle(color: Colors.black87)),
                                      const SizedBox(height: 8),
                                      Text(
                                        "${temp.toStringAsFixed(1)}°",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          /// 🔹 Weekly Forecast
                          const Text(
                            "Weekly Forecast",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: weather.dates.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(weather.dates[index], style: const TextStyle(color: Colors.black87)),
                                    Text(
                                      "${weather.tempMax[index].toStringAsFixed(1)}° / ${weather.tempMin[index].toStringAsFixed(1)}°",
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          /// 🔹 Additional Info
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildInfoCard("Humidity", "${weather.humidity.toStringAsFixed(0)}%"),
                              _buildInfoCard("UV Index", "${weather.uvIndex.toStringAsFixed(1)}"),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildInfoCard(
                                "Sunrise",
                                "${weather.sunrise.hour}:${weather.sunrise.minute.toString().padLeft(2, '0')}",
                              ),
                              _buildInfoCard(
                                "Sunset",
                                "${weather.sunset.hour}:${weather.sunset.minute.toString().padLeft(2, '0')}",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }

  /// 🔹 Reusable Info Card Widget
  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 16)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
