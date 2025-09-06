


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekort/Presentation/Employee/employeedashboard.dart';
import 'package:tekort/Presentation/admin/admindashboard.dart';
import 'package:tekort/core/core/utils/styles.dart';
import 'package:tekort/onboardingscreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    navigateToNext();
  }
  
Future<void> checkConnectivityAndAuth() async {
  var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult == ConnectivityResult.none) {
    // No internet
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('No Internet Connection'),
        content: Text('Please check your connection and try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              checkConnectivityAndAuth(); // Retry
            },
            child: Text('Retry'),
          )
        ],
      ),
    );
    return;
  }
 }
 Future<void> navigateToNext() async {
    await Future.delayed(Duration(seconds: 2)); // Show splash for 2 seconds

    final prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');

    if (role != null) {
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => EmployeeDashboard()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DoorHubOnboardingScreen()),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
     // Optional: set background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/TEKORT LOGO.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            
          ],
        ),
      ),
    );
  }
}
