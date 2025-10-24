import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:wtf_sliding_sheet/wtf_sliding_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/weather_controller.dart';
import '../controllers/navigation_controller.dart'; // ✅ new
import 'search_screen.dart';
import 'profile_screen.dart';

// Import your ML screen
import 'ml_screen.dart'; // If you’ve created it separately

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final WeatherController controller = Get.put(WeatherController());
  final NavigationController navController = Get.put(NavigationController());

  final List<Widget> _screens = [
    const _HomeContent(),
    SearchScreen(),
    MLScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      body: _screens[navController.selectedIndex.value],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 28, 27, 51),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: navController.selectedIndex.value,
        onTap: navController.changeTab,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph_rounded),
            label: "ML",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),
    ));
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({super.key});

  IconData getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code == 1 || code == 2) return Icons.wb_sunny_outlined;
    if (code == 3) return Icons.cloud;
    if (code == 45 || code == 48) return Icons.foggy;
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) return Icons.grain;
    if (code >= 71 && code <= 77) return Icons.ac_unit;
    if (code >= 95 && code <= 99) return Icons.thunderstorm_outlined;
    return Icons.wb_cloudy;
  }

  @override
  Widget build(BuildContext context) {
    final WeatherController controller = Get.find();
    final screenHeight = MediaQuery.of(context).size.height;
    final dateFormatter = DateFormat('hh:mm a');

    return Obx(() {
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

          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Image.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Hut Illustration
          Positioned(
            top: 300,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/hut.png",
              height: 300,
              fit: BoxFit.contain,
            ),
          ),

          Positioned(
            top: 100,
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
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      getWeatherIcon(weather.weatherCode),
                      size: 48,
                      color: Colors.yellowAccent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${weather.temperature.toStringAsFixed(1)}°C",
                      style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w300,
                          color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Wind: ${weather.windspeed.toStringAsFixed(1)} km/h",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),

          SlidingSheet(
            elevation: 0,
            color: Colors.transparent,
            cornerRadius: 30,
            snapSpec: const SnapSpec(
              snap: true,
              snappings: [0.35, 0.65, 0.95],
              positioning: SnapPositioning.relativeToAvailableSpace,
            ),
            minHeight: screenHeight * 0.35,
            builder: (context, state) {
              return ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(30)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                      border: Border.all(
                          color: const Color.fromARGB(77, 255, 255, 255),
                          width: 1.2),
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color.fromARGB(66, 46, 51, 90),
                          Color.fromARGB(66, 28, 27, 51)
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          final isHourly = controller.isHourlyView.value;
                          return Row(
                            children: [
                              _toggleButton("Hourly Forecast", isHourly,
                                      () {
                                    controller.toggleForecastView(true);
                                  }),
                              const SizedBox(width: 12),
                              _toggleButton("Weekly Forecast", !isHourly,
                                      () {
                                    controller.toggleForecastView(false);
                                  }),
                              const Spacer(),
                              IconButton(
                                onPressed: () =>
                                    controller.fetchWeatherByLocation(),
                                icon: const Icon(Icons.refresh,
                                    color: Colors.white70),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 10),

                        Obx(() {
                          final isHourly = controller.isHourlyView.value;
                          final items =
                          isHourly ? weather.hourlyTimes : weather.dates;
                          final tempsMax =
                          isHourly ? weather.hourlyTemps : weather.tempMax;
                          final tempsMin =
                          isHourly ? null : weather.tempMin;
                          final pageController =
                          PageController(viewportFraction: 0.3);

                          return SizedBox(
                            height: 120,
                            child: PageView.builder(
                              controller: pageController,
                              itemCount: items.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return AnimatedBuilder(
                                  animation: pageController,
                                  builder: (context, child) {
                                    double scale = 1.0;
                                    if (pageController
                                        .position.hasContentDimensions) {
                                      double page = pageController.page ??
                                          pageController.initialPage.toDouble();
                                      scale = (1 -
                                          (page - index).abs() * 0.2)
                                          .clamp(0.8, 1.0);
                                    }
                                    return Transform.scale(
                                        scale: scale, child: child);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          80, 28, 27, 51),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                            getWeatherIcon(
                                                weather.weatherCode),
                                            color: Colors.yellowAccent,
                                            size: 28),
                                        const SizedBox(height: 6),
                                        Text(
                                          isHourly
                                              ? items[index].split('T').last
                                              : items[index],
                                          style: const TextStyle(
                                              color: Colors.white70),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isHourly
                                              ? "${tempsMax[index].toStringAsFixed(1)}°"
                                              : "${tempsMax[index].toStringAsFixed(1)}° / ${tempsMin![index].toStringAsFixed(1)}°",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 16),

                        Center(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                              const Color.fromARGB(80, 28, 27, 51),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                const Text("Air Quality (AQI)",
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 14)),
                                const SizedBox(height: 8),
                                Text("${weather.airQuality}",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _infoCard("UV Index",
                                  weather.uvIndex.toStringAsFixed(1)),
                              _infoCard("Humidity",
                                  "${weather.humidity.toStringAsFixed(0)}%"),
                              _infoCard("Sunrise",
                                  dateFormatter.format(weather.sunrise)),
                              _infoCard("Rainfall",
                                  "${weather.rainfall.toStringAsFixed(1)} mm"),
                            ],
                          ),
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
    });
  }

  Widget _toggleButton(String title, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? const Color.fromARGB(140, 255, 255, 255)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: const Color.fromARGB(60, 255, 255, 255)),
          ),
          child: Center(
            child: Text(title,
                style: TextStyle(
                    color: active ? Colors.black : Colors.white70,
                    fontWeight:
                    active ? FontWeight.bold : FontWeight.w500)),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(80, 28, 27, 51),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
