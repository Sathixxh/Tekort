

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekort/Presentation/Employee/employeedashboard.dart';
import 'package:tekort/Presentation/admin/admindashboard.dart';
import 'package:tekort/core/core/common/loading.dart';
import 'package:tekort/core/core/utils/styles.dart';
import 'package:tekort/main.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isloding=false;
    ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
isInternetConnected()
;
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) async {
          // Check if neither mobile nor wifi are active
          if (!results.any((result) =>
              result == ConnectivityResult.mobile ||
              result == ConnectivityResult.wifi)) {
            // If there's no internet, show the snackbar
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // showSnackbar(context, "No internet", Colors.red);
               ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("No internet"),
      backgroundColor: Colors.red,
    ),
  );
            });
          }
        },
      );

  }


Future<void> login() async {
  bool isConnected = await isInternetConnected();
  if (!isConnected) {
    noInternetConnectAlertDialog(context, login);
    return;
  }

  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: Center(child: loadingWidget()),
      ),
    );

    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    String role = userDoc['role'];
    String uid = userCredential.user!.uid;
    String email = emailController.text.trim();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setString('email', email);
    await prefs.setString('role', role);

    // ✅ Get FCM token
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': fcmToken,
      });
      print("FCM Token saved: $fcmToken");
    }

    Navigator.of(context).pop();

    // ✅ Show local notification on login success
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'login_channel',
      'Login Notifications',
      channelDescription: 'Notification when login is successful',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Login Successful',
      'Welcome back!',
      platformChannelSpecifics,
    );

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
  } catch (e) {
    Navigator.of(context).pop();

    String errorMessage = "Something went wrong. Please try again.";

    if (e is FirebaseAuthException) {
      switch (e.code) {
        case "invalid-email":
          errorMessage = "The email address is not valid.";
          break;
        case "user-disabled":
          errorMessage = "This account has been disabled.";
          break;
        case "user-not-found":
          errorMessage = "No user found with this email.";
          break;
        case "wrong-password":
          errorMessage = "Wrong password. Please try again.";
          break;
        case "network-request-failed":
          errorMessage = "Network error. Please check your internet connection.";
          break;
        default:
          errorMessage = e.message ?? errorMessage;
      }
    }

    print("Login Error: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
      return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Theme.of(context).brightness == Brightness.dark?Image.asset("assets/images/TEKORT LOGO.png"):
              Image.asset("assets/images/TEKORT LOGO1.png"),
              TextFormField(
                 validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'Email is required';
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value))
                    return 'Enter a valid email';
                  return null;
                },
                controller: emailController,
                decoration: InputDecoration(hintText: 'Email'),
              ),
              SizedBox(height: 20,),
              TextFormField(
                 validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'Password is required';
                  if (value.length < 6)
                    return 'Password must be at least 6 characters';
                  return null;
                },
                controller: passwordController,
                decoration: InputDecoration(hintText: 'Password'),
              ),
                SizedBox(height: 20,),
              MaterialButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.all(Radius.circular(10))),
                child: Text("Login"),
                color: primaryColor,
                onPressed: (){
login();

              }),
                SizedBox(height: 10,),
           
            ],
          ),
        ),
      ),
    );
  }
}



Future<bool> isInternetConnected() async {
  // Check connectivity result, which might now return a list
  var connectivityResult = await (Connectivity().checkConnectivity());

  // If it's a list, check if any result indicates mobile or wifi
  return connectivityResult.any((result) =>
      result == ConnectivityResult.mobile || result == ConnectivityResult.wifi);
}

noInternetConnectAlertDialog(context, retryFunction) {
  // throw Exception("ethavathu   ");
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Oops..!",
                  style: TextStyle(
                      letterSpacing: -3.0,
                      fontSize: 40.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.black),
                ),
                Icon(
                  Icons.cell_tower,
                  size: 100,
                  color: primaryColor,
                ),
                Text(
                  "No Internet Connection",
                  style: TextStyle(
                      fontSize: 18.0,
                      color: primaryColor,
                      fontFamily: 'inter',
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                SizedBox(
                  // height: 42.0,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0))),
                          backgroundColor:
                              MaterialStatePropertyAll(primaryColor)),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await Future.delayed(const Duration(milliseconds: 600));
                        retryFunction();
                      },
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                            fontFamily: 'inter',
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )),
                ),
                // const SizedBox(
                //   height: 20.0,
                // )
              ],
            ),
          ),
        ),
      );
    },
  );
}
