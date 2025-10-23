import 'package:get/get.dart';

class AppMenuController extends GetxController {
  var isOpen = false.obs;

  void toggleMenu() {
    isOpen.value = !isOpen.value;
  }

  void closeMenu() {
    isOpen.value = false;
  }
}
