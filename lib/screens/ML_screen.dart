import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/ml_controller.dart';

class MLScreen extends StatelessWidget {
  final MLController controller = Get.put(MLController());

  MLScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/SearchBG 3.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground UI
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage.isNotEmpty) {
              return Center(
                child: Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            final current = controller.currentWeather;
            final list = controller.weeklyForecast;

            if (current.isEmpty && list.isEmpty) {
              return const Center(
                child: Text(
                  "No forecast data available",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            // Safely get today's weather
            final tempMax = current['temp_max_c'] ?? 0.0;
            final tempMin = current['temp_min_c'] ?? 0.0;
            final humidity = current['humidity_percent'] ?? 0.0;
            final wind = current['wind_speed_ms'] ?? 0.0;
            final condition = current['condition'] ?? "Clear";
            final feelsLike = ((tempMax + tempMin) / 2).toStringAsFixed(1);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // City + Date
                  const Text(
                    "Seattle",
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('EEEE, MMM d').format(DateTime.now()),
                    style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Manrope',
                        fontSize: 16),
                  ),
                  const SizedBox(height: 25),

                  // Current Weather Card
                  _gradientCard(
                    width: screenWidth * 0.9,
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    child: Column(
                      children: [
                        Text(
                          "$tempMax°C",
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            color: Colors.white,
                            fontSize: 72,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          condition,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 20,
                            fontFamily: 'Manrope',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "H: $tempMax°C   L: $tempMin°C",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Combined Info Card: Humidity, Feels Like, Wind
                  _gradientCard(
                    width: screenWidth * 0.9,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _smallInfo("Humidity", "${humidity.toStringAsFixed(0)}%"),
                        _smallInfo("Feels Like", "$feelsLike°C"),
                        _smallInfo("Wind", "${wind.toStringAsFixed(1)} km/h"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Weekly Forecast Title
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Weekly Forecast",
                      style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Weekly Forecast Row
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final day = list[index];
                        final date = DateTime.parse(day['date']);
                        final tempMax = day['temp_max_c'] ?? 0;
                        final tempMin = day['temp_min_c'] ?? 0;
                        final condition = day['condition'] ?? "Clear";

                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                Color.fromRGBO(46, 51, 90, 0.26),
                                Color.fromRGBO(28, 27, 51, 0.26),
                              ],
                            ),
                            border: Border.all(color: Colors.white24, width: 1),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('EEE').format(date),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Icon(
                                _getWeatherIcon(condition),
                                color: Colors.yellowAccent,
                                size: 28,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "$tempMax° / $tempMin°",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w500,
                                ),
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
        ],
      ),
    );
  }

  Widget _gradientCard({
    required Widget child,
    double? width,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: width,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.fromRGBO(46, 51, 90, 0.26),
            Color.fromRGBO(28, 27, 51, 0.26),
          ],
        ),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: child,
    );
  }

  Widget _smallInfo(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Manrope',
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Manrope',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('sun') || condition.contains('clear')) return Icons.wb_sunny;
    if (condition.contains('cloud')) return Icons.cloud;
    if (condition.contains('rain')) return Icons.grain;
    if (condition.contains('storm') || condition.contains('thunder')) return Icons.thunderstorm;
    if (condition.contains('snow')) return Icons.ac_unit;
    if (condition.contains('fog') || condition.contains('mist')) return Icons.foggy;
    return Icons.wb_cloudy;
  }
}
