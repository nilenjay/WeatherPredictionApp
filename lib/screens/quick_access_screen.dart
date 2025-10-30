import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/quick_access_controller.dart';

class QuickAccessScreen extends StatelessWidget {
  final String city;
  QuickAccessScreen({super.key, required this.city});

  final QuickAccessController controller = Get.put(QuickAccessController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    controller.fetchWeather(city);

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

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    controller.city.value,
                    style: const TextStyle(
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

                  _gradientCard(
                    width: screenWidth * 0.9,
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    child: Column(
                      children: [
                        Text(
                          "${controller.temperature.value.toStringAsFixed(1)}°C",
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            color: Colors.white,
                            fontSize: 72,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _getCondition(controller.weatherCode.value),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 20,
                            fontFamily: 'Manrope',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "H: ${controller.tempMax.isNotEmpty ? controller.tempMax[0].toStringAsFixed(1) : '0'}°  "
                              "L: ${controller.tempMin.isNotEmpty ? controller.tempMin[0].toStringAsFixed(1) : '0'}°",
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

                  _gradientCard(
                    width: screenWidth * 0.9,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _smallInfo("Humidity", "${controller.humidity.value.toStringAsFixed(0)}%"),
                        _smallInfo("UV Index", "${controller.uvIndex.value.toStringAsFixed(1)}"),
                        _smallInfo("Wind", "${controller.windspeed.value.toStringAsFixed(1)} km/h"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

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

                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.dates.length,
                      itemBuilder: (context, index) {
                        final date = DateTime.tryParse(controller.dates[index]) ?? DateTime.now();
                        final tempMax = controller.tempMax.length > index ? controller.tempMax[index] : 0;
                        final tempMin = controller.tempMin.length > index ? controller.tempMin[index] : 0;
                        final weatherCode = controller.dailyWeatherCodes.length > index ? controller.dailyWeatherCodes[index] : 0;

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
                                _getWeatherIcon(weatherCode),
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

  String _getCondition(int code) {
    switch (code) {
      case 0: return 'Clear';
      case 1: return 'Mainly Clear';
      case 2: return 'Partly Cloudy';
      case 3: return 'Cloudy';
      case 61: return 'Rain';
      case 63: return 'Heavy Rain';
      case 71: return 'Snow';
      default: return 'Clear';
    }
  }

  IconData _getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code == 1 || code == 2) return Icons.cloud;
    if (code == 3) return Icons.cloud_queue;
    if (code == 61 || code == 63) return Icons.grain;
    if (code == 71) return Icons.ac_unit;
    return Icons.wb_cloudy;
  }
}
