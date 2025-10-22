// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(AuthController());

  User? user = FirebaseAuth.instance.currentUser;

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: user != null ? HomeScreen() : LoginScreen(),
      getPages: [
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/search', page: () => SearchScreen()),
        GetPage(name: '/profile', page: () => ProfileScreen()),
      ],
    ),
  );
}
