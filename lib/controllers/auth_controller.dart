import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../screens/home_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;

  // 🔹 SIGN UP (with Firestore name storage)
  Future<void> signUp(String name, String email, String password) async {
    isLoading.value = true;
    try {
      // Create Firebase Auth account
      final UserCredential userCredential =
      await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Save user details in Firestore
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Navigate to Home
      Get.offAll(() => HomeScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Sign Up Error",
        e.message ?? "Unknown Error",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      // Always stop loading no matter what
      isLoading.value = false;
    }
  }

  // 🔹 LOGIN (Email & Password)
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      Get.offAll(() => HomeScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Login Error",
        e.message ?? "Unknown Error",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 🔹 LOGIN WITH GOOGLE
  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        Get.snackbar(
          "Login Cancelled",
          "Google Sign-In was cancelled",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await auth.signInWithCredential(credential);

      // Save user to Firestore if new
      final userDoc =
      firestore.collection('users').doc(userCredential.user!.uid);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'name': userCredential.user!.displayName ?? "Unnamed User",
          'email': userCredential.user!.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      Get.offAll(() => HomeScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Google Sign-In Error",
        e.message ?? "Unknown Error",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 🔹 SIGN OUT
  Future<void> signOut() async {
    try {
      await auth.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      Get.snackbar(
        "Sign Out Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
