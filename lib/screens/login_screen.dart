import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
              onPressed: authController.isLoading.value
                  ? null
                  : () {
                authController.login(
                    emailController.text, passwordController.text);
              },
              child: authController.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Login"),
            )),
            const SizedBox(height: 10),
            Obx(() => ElevatedButton.icon(
              onPressed: authController.isLoading.value
                  ? null
                  : () {
                authController.loginWithGoogle();
              },
              icon: const Icon(Icons.login),
              label: const Text("Continue with Google"),
            )),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Get.to(() => SignupScreen());
              },
              child: const Text("Don't have an account? Sign Up"),
            )
          ],
        ),
      ),
    );
  }
}
