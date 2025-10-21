import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/home_controller.dart';
import 'search_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController controller = Get.put(HomeController());
  final user = FirebaseAuth.instance.currentUser; // Logged-in user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App (${user?.email ?? ''})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Get.to(() => SearchScreen());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.offAll(() => LoginScreen()); // Return to login
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: controller.fetchWeatherForCurrentLocation,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.weatherData.value == null) {
            return const Center(
              child: Text('Fetching weather for your location...'),
            );
          }

          final data = controller.weatherData.value!;
          final city = data['city'] ?? 'Your Location';
          final current = data['current_weather'];
          final daily = data['daily'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                city,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "${current['temperature']}°C",
                style:
                const TextStyle(fontSize: 48, fontWeight: FontWeight.w600),
              ),
              Text("Wind: ${current['windspeed']} km/h"),
              const SizedBox(height: 20),
              const Text(
                "7-Day Forecast",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: daily['time'].length,
                  itemBuilder: (context, index) {
                    final date = DateTime.parse(daily['time'][index]);
                    final max = daily['temperature_2m_max'][index];
                    final min = daily['temperature_2m_min'][index];
                    return Card(
                      child: ListTile(
                        title: Text(DateFormat('EEE, MMM d').format(date)),
                        subtitle: Text("Min: $min°C | Max: $max°C"),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
