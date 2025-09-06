
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:tekort/Presentation/auth/login.dart';
import 'package:tekort/Presentation/auth/splashscreen.dart';
import 'package:tekort/Presentation/notification/nofiticationscren.dart';
import 'package:tekort/Presentation/notification/notificationmodel.dart';
import 'package:tekort/Presentation/notification/notificationprovider.dart';
import 'package:tekort/Providers/attenceprovider.dart';
import 'package:tekort/Providers/batchprovider.dart';
import 'package:tekort/Providers/courseprovider.dart';
import 'package:tekort/Providers/employeeprovider.dart';
import 'package:tekort/Providers/notchprovider.dart';
import 'package:tekort/core/core/themes/apptheme.dart';
import 'package:tekort/core/core/themes/themeprovider/themeprovider.dart';
import 'firebase_options.dart'; 
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _showLocalNotification(message);
}

void _showLocalNotification(RemoteMessage message) {
  if (message.notification != null) {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    flutterLocalNotificationsPlugin.show(
      DateTime.now().microsecond,
      message.notification!.title ?? '',
      message.notification!.body ?? '',
      platformDetails,
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await _requestNotificationPermission();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourseProvider()..fetchCourses()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => BatchProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MyApp(),
    ),
  );

  // 🔹 Now safe to use navigatorKey.currentContext
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📩 Foreground message received: ${message.messageId}");

    _showLocalNotification(message);

    final notification = NotificationModel(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      timestamp: DateTime.now(),
    );

    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      Provider.of<NotificationProvider>(ctx, listen: false)
          .addNotification(notification);
    }
  });

  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      print("📩 App opened from terminated state: ${message.messageId}");
      _showLocalNotification(message);
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    print("📩 App opened from background: ${message.messageId}");
  });
}

Future<void> _requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print("✅ Notification permission granted");
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print("⚠️ Notification permission provisional");
  } else {
    print("❌ Notification permission denied");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeSwitch>(
      create: (_) => ThemeSwitch(),
      child: Consumer<ThemeSwitch>(
        builder: (context, themeSwitch, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Role Based App',
            theme: AppTheme.lightThemeMode(context),
            darkTheme: AppTheme.darkThemeMode(context),
            themeMode: themeSwitch.themeModeValue,
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}









// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   Future<User?> signUp(
//     String email,
//     String password,
//     String role,
//     String phone,
//   ) async {
//     try {
//       UserCredential userCredential = await _auth
//           .createUserWithEmailAndPassword(email: email, password: password);

//       await _firestore.collection('users').doc(userCredential.user!.uid).set({
//         'email': email,
//         'phone': phone,
//         'role': role,
//         'password':password,
//       });
//       return userCredential.user;
//     } catch (e) {
//       print('Sign Up Error: $e');
//       return null;
//     }
//   }

//   Future<Map<String, dynamic>?> login(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       DocumentSnapshot userDoc = await _firestore
//           .collection('users')
//           .doc(userCredential.user!.uid)
//           .get();
//       return userDoc.data() as Map<String, dynamic>;
//     } catch (e) {
//       print('Login Error: $e');
//       return null;
//     }
//   }
// }

// class SignupScreen extends StatefulWidget {
//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final phoneController = TextEditingController();
//    final nameController = TextEditingController();
//   String role = 'employee';
//   void signUp() async {
//     if (!_formKey.currentState!.validate()) return;

//     try {
//       UserCredential userCredential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(
//             email: emailController.text.trim(),
//             password: passwordController.text.trim(),
//           );

//       String uid = userCredential.user!.uid;

//       QuerySnapshot snapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .orderBy('customId', descending: true)
//           .limit(1)
//           .get();
//       String newCustomId = "Tek001";
//       if (snapshot.docs.isNotEmpty) {
//         String lastId = snapshot.docs.first['customId'];
//         int lastNumber = int.parse(lastId.replaceAll(RegExp(r'[^0-9]'), ''));
//         int nextNumber = lastNumber + 1;
//         newCustomId = "Tek${nextNumber.toString().padLeft(3, '0')}";
//       }
//       await FirebaseFirestore.instance.collection('users').doc(uid).set({
//         'uid': uid,
//         'customId': newCustomId,
//         'email': emailController.text.trim(),
//         'phone': phoneController.text.trim(),
//         'password':passwordController.text.trim(),
//         'role': role,
//         'name':phoneController.text.trim(),
//       });

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("User Registered Successfully")));
//       Navigator.pop(context);
//     } catch (e) {
//       print("Signup Error: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: $e")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Signup")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey, // Connect the form
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: emailController,
//                 decoration: InputDecoration(hintText: 'Email'),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty)
//                     return 'Email is required';
//                   if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value))
//                     return 'Enter a valid email';
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(hintText: 'Password'),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty)
//                     return 'Password is required';
//                   if (value.length < 6)
//                     return 'Password must be at least 6 characters';
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: phoneController,
//                 keyboardType: TextInputType.phone,
//                 decoration: InputDecoration(labelText: 'Phone Number'),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty)
//                     return 'Phone is required';
//                   if (!RegExp(r'^\d{10,}$').hasMatch(value))
//                     return 'Enter a valid phone number';
//                   return null;
//                 },
//               ),
//               DropdownButtonFormField<String>(
//                 value: role,
//                 items: ['admin', 'employee']
//                     .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                     .toList(),
//                 onChanged: (val) => setState(() => role = val!),
//                 decoration: InputDecoration(labelText: 'Select Role'),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(onPressed: signUp, child: Text('Sign Up')),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text("Back to login"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // import 'package:cloud_functions/cloud_functions.dart';

// Future<void> sendBatchNotification(List<String> tokens, String taskName) async {
//   final HttpsCallable callable =
//       FirebaseFunctions.instance.httpsCallable('sendTaskNotification');

//   await callable.call(<String, dynamic>{
//     'tokens': tokens,
//     'taskName': taskName,
//   });
// }

class CustomAnimatedTabBar extends StatefulWidget {
  final List<String> tabs;
  final Function(int) onTabChanged;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? containerColor;
  final double? borderRadius;
  final EdgeInsets? padding;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;

  const CustomAnimatedTabBar({
    Key? key,
    required this.tabs,
    required this.onTabChanged,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
    this.containerColor = Colors.white,
    this.borderRadius = 55.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    this.selectedTextStyle,
    this.unselectedTextStyle,
  }) : super(key: key);

  @override
  State<CustomAnimatedTabBar> createState() => _CustomAnimatedTabBarState();
}

class _CustomAnimatedTabBarState extends State<CustomAnimatedTabBar>
    with TickerProviderStateMixin {
  int selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != selectedIndex) {
      setState(() {
        selectedIndex = index;
      });
      _animationController.forward(from: 0);
      widget.onTabChanged(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(widget.borderRadius!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.tabs.asMap().entries.map((entry) {
          int index = entry.key;
          String tab = entry.value;
          bool isSelected = selectedIndex == index;

          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return GestureDetector(
                onTap: () => _onTabTapped(index),
                child: AnimatedContainer(
                  height: 38,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: widget.padding,
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? widget.selectedColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(widget.borderRadius! - 4),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: widget.selectedColor!.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: Duration(milliseconds: 300),
                    style: isSelected
                        ? (widget.selectedTextStyle ??
                            TextStyle(
                           
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ))
                        : (widget.unselectedTextStyle ??
                            TextStyle(
                              color: widget.unselectedColor,
                              fontWeight: FontWeight.normal,
                              fontSize: 15,
                            )),
                    child: Text(tab),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

// Example usage widget
class TabBarExample extends StatefulWidget {
  @override
  State<TabBarExample> createState() => _TabBarExampleState();
}

class _TabBarExampleState extends State<TabBarExample> {
  int currentTab = 0;
  PageController pageController = PageController();

  final List<String> tabs = ['Home', 'Search', 'Profile', 'Settings'];
  
  final List<Widget> pages = [
    Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.home, size: 100, color: Colors.blue),
        SizedBox(height: 20),
        Text('Home Page', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    )),
    Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search, size: 100, color: Colors.green),
        SizedBox(height: 20),
        Text('Search Page', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    )),
    Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person, size: 100, color: Colors.orange),
        SizedBox(height: 20),
        Text('Profile Page', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    )),
    Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.settings, size: 100, color: Colors.purple),
        SizedBox(height: 20),
        Text('Settings Page', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    )),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Custom Animated TabBar'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Custom TabBar
          Container(
            padding: EdgeInsets.all(20),
            child: CustomAnimatedTabBar(
              tabs: tabs,
              onTabChanged: (index) {
                setState(() {
                  currentTab = index;
                });
                pageController.animateToPage(
                  index,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              selectedColor: Colors.deepPurple,
              unselectedColor: Colors.grey[600],
              borderRadius: 20,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          
          // Page Content
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentTab = index;
                });
              },
              children: pages,
            ),
          ),
          
              
          
        
        ],
      ),
    );
  }
}

// Alternative Implementation with Custom Painter for more advanced animations
class AdvancedAnimatedTabBar extends StatefulWidget {
  final List<String> tabs;
  final Function(int) onTabChanged;
  final Color selectedColor;
  final Color unselectedColor;
  final Color backgroundColor;

  const AdvancedAnimatedTabBar({
    Key? key,
    required this.tabs,
    required this.onTabChanged,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  State<AdvancedAnimatedTabBar> createState() => _AdvancedAnimatedTabBarState();
}

class _AdvancedAnimatedTabBarState extends State<AdvancedAnimatedTabBar>
    with TickerProviderStateMixin {
  int selectedIndex = 0;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: Duration(milliseconds: 250),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (index != selectedIndex) {
      setState(() {
        selectedIndex = index;
      });
      _slideController.forward(from: 0);
      widget.onTabChanged(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated background indicator
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return AnimatedPositioned(
                duration: Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: (MediaQuery.of(context).size.width - 40) / widget.tabs.length * selectedIndex + 4,
                top: 4,
                child: Container(
                  width: (MediaQuery.of(context).size.width - 40) / widget.tabs.length - 8,
                  height: 42,
                  decoration: BoxDecoration(
                    color: widget.selectedColor,
                    borderRadius: BorderRadius.circular(21),
                    boxShadow: [
                      BoxShadow(
                        color: widget.selectedColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Tab items
          Row(
            children: widget.tabs.asMap().entries.map((entry) {
              int index = entry.key;
              String tab = entry.value;
              bool isSelected = selectedIndex == index;
              
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTabSelected(index),
                  child: Container(
                    height: 50,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: Duration(milliseconds: 200),
                        style: TextStyle(
                          color: isSelected ? Colors.white : widget.unselectedColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
                        ),
                        child: Text(tab),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}








// class AddCourseScreen22222 extends StatefulWidget {
//   @override
//   State<AddCourseScreen22222> createState() => _AddCourseScreen22222State();
// }

// class _AddCourseScreen22222State extends State<AddCourseScreen22222>
//     with TickerProviderStateMixin {
//   late AnimationController _headerController;
//   late AnimationController _cardController;
//   late AnimationController _floatingController;
//   late Animation<double> _headerAnimation;
//   late Animation<double> _cardAnimation;
//   late Animation<double> _floatingAnimation;

//   final Color primaryColor = Color(0xFF04A888);
//   ScrollController _scrollController = ScrollController();
//   bool _isScrolled = false;

//   @override
//   void initState() {
//     super.initState();
    
//     _headerController = AnimationController(
//       duration: Duration(milliseconds: 1200),
//       vsync: this,
//     );
//     _cardController = AnimationController(
//       duration: Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _floatingController = AnimationController(
//       duration: Duration(milliseconds: 2000),
//       vsync: this,
//     )..repeat(reverse: true);

//     _headerAnimation = CurvedAnimation(
//       parent: _headerController,
//       curve: Curves.easeOutExpo,
//     );
//     _cardAnimation = CurvedAnimation(
//       parent: _cardController,
//       curve: Curves.elasticOut,
//     );
//     _floatingAnimation = Tween<double>(
//       begin: 0.0,
//       end: 10.0,
//     ).animate(_floatingController);

//     _scrollController.addListener(() {
//       setState(() {
//         _isScrolled = _scrollController.offset > 50;
//       });
//     });

//     Future.microtask(() {
//       Provider.of<CourseProvider>(context, listen: false).fetchCourses();
//       Provider.of<BatchProvider>(context, listen: false).fetchBatches();
      
//       _headerController.forward();
//       Future.delayed(Duration(milliseconds: 300), () {
//         _cardController.forward();
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _headerController.dispose();
//     _cardController.dispose();
//     _floatingController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF8FFFE),
//       body: CustomScrollView(
//         controller: _scrollController,
//         physics: BouncingScrollPhysics(),
//         slivers: [
//           _buildSliverAppBar(),
//           SliverToBoxAdapter(
//             child: Consumer2<CourseProvider, BatchProvider>(
//               builder: (context, courseProvider, batchProvider, _) {
//                 final courses = courseProvider.courses;
//                 final batches = batchProvider.batches;
                
//                 return Column(
//                   children: [
//                     _buildStatsOverview(),
//                     _buildQuickActions(),
//                     _buildTasksSection(),
//                     _buildCoursesSection(courses),
//                     _buildBatchesSection(batches),
//                     SizedBox(height: 100),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
     
//     );
//   }

//   Widget _buildSliverAppBar() {
//     return SliverAppBar(
//       expandedHeight: 200,
//       floating: false,
//       pinned: true,
//       elevation: 0,
//       backgroundColor: _isScrolled ? Colors.white : Colors.transparent,
//       automaticallyImplyLeading: false,
//       flexibleSpace: FlexibleSpaceBar(
//         background: AnimatedBuilder(
//           animation: _headerAnimation,
//           builder: (context, child) {
//             return Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     primaryColor,
//                     primaryColor.withOpacity(0.8),
//                     Color(0xFF00BFA5),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//               child: Stack(
//                 children: [
//                   // Animated background pattern
//                   Positioned(
//                     top: -50,
//                     right: -50,
//                     child: Transform.scale(
//                       scale: _headerAnimation.value,
//                       child: Container(
//                         width: 200,
//                         height: 200,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.white.withOpacity(0.1),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: 50,
//                     left: -30,
//                     child: Transform.scale(
//                       scale: _headerAnimation.value * 0.7,
//                       child: Container(
//                         width: 100,
//                         height: 100,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.white.withOpacity(0.08),
//                         ),
//                       ),
//                     ),
//                   ),
//                   // Content
//                   SafeArea(
//                     child: Padding(
//                       padding: EdgeInsets.all(20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               SlideTransition(
//                                 position: Tween<Offset>(
//                                   begin: Offset(-1, 0),
//                                   end: Offset.zero,
//                                 ).animate(_headerAnimation),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Good Morning! 👋',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         color: Colors.white.withOpacity(0.9),
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                     Text(
//                                       'Dashboard',
//                                       style: TextStyle(
//                                         fontSize: 32,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                         letterSpacing: -0.5,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SlideTransition(
//                                 position: Tween<Offset>(
//                                   begin: Offset(1, 0),
//                                   end: Offset.zero,
//                                 ).animate(_headerAnimation),
//                                 child: Stack(
//                                   children: [
//                                     Container(
//                                       padding: EdgeInsets.all(12),
//                                       decoration: BoxDecoration(
//                                         color: Colors.white.withOpacity(0.2),
//                                         borderRadius: BorderRadius.circular(16),
//                                         border: Border.all(
//                                           color: Colors.white.withOpacity(0.3),
//                                         ),
//                                       ),
//                                       child: Icon(
//                                         Icons.notifications_outlined,
//                                         color: Colors.white,
//                                         size: 24,
//                                       ),
//                                     ),
//                                     Positioned(
//                                       top: 8,
//                                       right: 8,
//                                       child: Container(
//                                         width: 8,
//                                         height: 8,
//                                         decoration: BoxDecoration(
//                                           color: Color(0xFFFF6B6B),
//                                           shape: BoxShape.circle,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Spacer(),
//                           FadeTransition(
//                             opacity: _headerAnimation,
//                             child: Text(
//                               'Manage your educational ecosystem',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.white.withOpacity(0.8),
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsOverview() {
//     return AnimatedBuilder(
//       animation: _cardAnimation,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(0, 50 * (1 - _cardAnimation.value)),
//           child: Opacity(
//             opacity: _cardAnimation.value.clamp(0.0, 1.0),
//             child: Container(
//               margin: EdgeInsets.fromLTRB(20, 30, 20, 20),
//               padding: EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: primaryColor.withOpacity(0.1),
//                     blurRadius: 30,
//                     offset: Offset(0, 15),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.trending_up,
//                         color: primaryColor,
//                         size: 24,
//                       ),
//                       SizedBox(width: 8),
//                       Text(
//                         'Overview',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF1A1A1A),
//                         ),
//                       ),
//                       Spacer(),
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: primaryColor.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           'Live',
//                           style: TextStyle(
//                             color: primaryColor,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 24),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildStatCard(
//                           '1,234',
//                           'Total Students',
//                           Icons.people_outline,
//                           Color(0xFF667EEA),
//                           0,
//                         ),
//                       ),
//                       SizedBox(width: 16),
//                       Expanded(
//                         child: _buildStatCard(
//                           '48',
//                           'Active Courses',
//                           Icons.school_outlined,
//                           Color(0xFFFF6B6B),
//                           1,
//                         ),
//                       ),
//                       SizedBox(width: 16),
//                       Expanded(
//                         child: _buildStatCard(
//                           '12',
//                           'Batches',
//                           Icons.group_work_outlined,
//                           Color(0xFFFFB74D),
//                           2,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildStatCard(String value, String label, IconData icon, Color color, int index) {
//     return TweenAnimationBuilder<double>(
//       duration: Duration(milliseconds: 800 + (index * 200)),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, animation, child) {
//         return Transform.scale(
//           scale: 0.8 + (0.2 * animation),
//           child: Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: color.withOpacity(0.2),
//               ),
//             ),
//             child: Column(
//               children: [
//                 Icon(icon, color: color, size: 28),
//                 SizedBox(height: 8),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: color,
//                   ),
//                 ),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.w500,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildQuickActions() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Quick Actions',
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF1A1A1A),
//             ),
//           ),
//           SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(child: _buildActionButton('Add Course', Icons.add_box, 0)),
//               SizedBox(width: 12),
//               Expanded(child: _buildActionButton('New Batch', Icons.group_add, 1)),
//               SizedBox(width: 12),
//               Expanded(child: _buildActionButton('Analytics', Icons.analytics, 2)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton(String title, IconData icon, int index) {
//     return TweenAnimationBuilder<double>(
//       duration: Duration(milliseconds: 600 + (index * 150)),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, animation, child) {
//         return Transform.translate(
//           offset: Offset(0, 30 * (1 - animation)),
//           child: Opacity(
//             opacity: animation.clamp(0.0, 1.0),
//             child: Container(
//               padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     primaryColor.withOpacity(0.8),
//                     primaryColor,
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: primaryColor.withOpacity(0.3),
//                     blurRadius: 10,
//                     offset: Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Icon(icon, color: Colors.white, size: 24),
//                   SizedBox(height: 8),
//                   Text(
//                     title,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 13,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTasksSection() {
//     return Container(
//       margin: EdgeInsets.only(top: 32),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20),
//             child: Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: primaryColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(
//                     Icons.task_alt,
//                     color: primaryColor,
//                     size: 20,
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Text(
//                   'Recent Tasks',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1A1A1A),
//                   ),
//                 ),
//                 Spacer(),
//                 TextButton(
//                   onPressed: () {},
//                   child: Text(
//                     'View All',
//                     style: TextStyle(
//                       color: primaryColor,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 16),
//           StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('tasks')
//                 .orderBy('createdAt', descending: true)
//                 .limit(5)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return _buildShimmerList();
//               }
//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                 return _buildEmptyState('No tasks found', Icons.task_alt);
//               }

//               final tasks = snapshot.data!.docs;
//               return Container(
//                 height: 200,
//                 child: ListView.separated(
//                   scrollDirection: Axis.horizontal,
//                   padding: EdgeInsets.symmetric(horizontal: 20),
//                   itemCount: tasks.length,
//                   separatorBuilder: (context, index) => SizedBox(width: 16),
//                   itemBuilder: (context, index) {
//                     return _buildModernTaskCard(tasks[index], index);
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildModernTaskCard(QueryDocumentSnapshot task, int index) {
//     final taskName = task['taskName'] ?? '';
//     final Map<String, dynamic> studentMap =
//         Map<String, dynamic>.from(task['studentMap'] ?? {});
    
//     int pendingCount = 0;
//     int completedCount = 0;
//     studentMap.forEach((key, value) {
//       final status = value['status'] ?? 'Pending';
//       if (status == 'Completed') {
//         completedCount++;
//       } else {
//         pendingCount++;
//       }
//     });

//     final total = pendingCount + completedCount;
//     final progress = total > 0 ? completedCount / total : 0.0;
//     final isHighProgress = progress > 0.7;

//     return TweenAnimationBuilder<double>(
//       duration: Duration(milliseconds: 600 + (index * 100)),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, animation, child) {
//         return Transform.translate(
//           offset: Offset(50 * (1 - animation), 0),
//           child: Opacity(
//             opacity: animation.clamp(0.0, 1.0),
//             child: Container(
//               width: 280,
//               padding: EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 20,
//                     offset: Offset(0, 10),
//                   ),
//                 ],
//                 border: Border.all(
//                   color: isHighProgress ? primaryColor.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: isHighProgress ? primaryColor.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(
//                           isHighProgress ? Icons.check_circle_outline : Icons.pending_actions,
//                           color: isHighProgress ? primaryColor : Colors.orange,
//                           size: 22,
//                         ),
//                       ),
//                       Spacer(),
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: isHighProgress ? primaryColor.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           '${(progress * 100).toInt()}%',
//                           style: TextStyle(
//                             color: isHighProgress ? primaryColor : Colors.orange,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     taskName,
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1A1A1A),
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   Spacer(),
//                   Container(
//                     height: 6,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: FractionallySizedBox(
//                       alignment: Alignment.centerLeft,
//                       widthFactor: progress,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: isHighProgress 
//                                 ? [primaryColor, primaryColor.withOpacity(0.7)]
//                                 : [Colors.orange, Colors.orange.withOpacity(0.7)],
//                           ),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Icon(Icons.check_circle, color: primaryColor, size: 16),
//                       SizedBox(width: 4),
//                       Text(
//                         '$completedCount Done',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: primaryColor,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       Spacer(),
//                       Icon(Icons.access_time, color: Colors.orange, size: 16),
//                       SizedBox(width: 4),
//                       Text(
//                         '$pendingCount Pending',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.orange,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildCoursesSection(List<dynamic> courses) {
//     return Container(
//       margin: EdgeInsets.only(top: 32),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20),
//             child: Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Color(0xFF667EEA).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(
//                     Icons.school,
//                     color: Color(0xFF667EEA),
//                     size: 20,
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Text(
//                   'Popular Courses',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1A1A1A),
//                   ),
//                 ),
//                 Spacer(),
//                 TextButton(
//                   onPressed: () {},
//                   child: Text(
//                     'Explore',
//                     style: TextStyle(
//                       color: Color(0xFF667EEA),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 16),
//           courses.isEmpty
//               ? _buildEmptyState('No courses available', Icons.school)
//               : Container(
//                   height: 220,
//                   child: ListView.separated(
//                     scrollDirection: Axis.horizontal,
//                     padding: EdgeInsets.symmetric(horizontal: 20),
//                     itemCount: courses.length,
//                     separatorBuilder: (context, index) => SizedBox(width: 16),
//                     itemBuilder: (context, index) {
//                       return _buildModernCourseCard(courses[index], index);
//                     },
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }

//   Widget _buildModernCourseCard(dynamic course, int index) {
//     final colors = [
//       [Color(0xFF667EEA), Color(0xFF764BA2)],
//       [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
//       [Color(0xFFFFB74D), Color(0xFFFF8A65)],
//       [primaryColor, Color(0xFF00BFA5)],
//     ];
//     final cardColors = colors[index % colors.length];

//     return TweenAnimationBuilder<double>(
//       duration: Duration(milliseconds: 700 + (index * 100)),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, animation, child) {
//         return Transform.scale(
//           scale: 0.8 + (0.2 * animation),
//           child: Opacity(
//             opacity: animation.clamp(0.0, 1.0),
//             child: Container(
//               width: 200,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: cardColors,
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: cardColors[0].withOpacity(0.3),
//                     blurRadius: 20,
//                     offset: Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Stack(
//                 children: [
//                   Positioned(
//                     top: -20,
//                     right: -20,
//                     child: Container(
//                       width: 80,
//                       height: 80,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.white.withOpacity(0.1),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           padding: EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Icon(
//                             Icons.play_circle_outline,
//                             color: Colors.white,
//                             size: 28,
//                           ),
//                         ),
//                         Spacer(),
//                         Text(
//                           course.title,
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         SizedBox(height: 12),
//                         Row(
//                           children: [
//                             Container(
//                               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(Icons.people, size: 14, color: Colors.white),
//                                   SizedBox(width: 4),
//                                   Text(
//                                     '${course.studentCount}',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Spacer(),
//                             Container(
//                               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 course.duration,
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildBatchesSection(List<dynamic> batches) {
//     return Container(
//       margin: EdgeInsets.only(top: 32),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20),
//             child: Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Color(0xFF96CEB4).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(
//                     Icons.groups,
//                     color: Color(0xFF96CEB4),
//                     size: 20,
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Text(
//                   'Student Batches',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1A1A1A),
//                   ),
//                 ),
//                 Spacer(),
//                 TextButton(
//                   onPressed: () {},
//                   child: Text(
//                     'Manage',
//                     style: TextStyle(
//                       color: Color(0xFF96CEB4),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 16),
//           batches.isEmpty
//               ? _buildEmptyState('No batches available', Icons.groups)
//               : Container(
//                   height: 160,
//                   child: ListView.separated(
//                     scrollDirection: Axis.horizontal,
//                     padding: EdgeInsets.symmetric(horizontal: 20),
//                     itemCount: batches.length,
//                     separatorBuilder: (context, index) => SizedBox(width: 16),
//                     itemBuilder: (context, index) {
//                       return _buildModernBatchCard(batches[index], index);
//                     },
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }

//   Widget _buildModernBatchCard(dynamic batch, int index) {
//     final batchColors = [
//       Color(0xFF96CEB4),
//       Color(0xFF6FAADB),
//       Color(0xFFFFB74D),
//       primaryColor,
//     ];
//     final cardColor = batchColors[index % batchColors.length];

//     return TweenAnimationBuilder<double>(
//       duration: Duration(milliseconds: 500 + (index * 100)),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, animation, child) {
//         return Transform.translate(
//           offset: Offset(30 * (1 - animation), 0),
//           child: Opacity(
//             opacity: animation,
//             child: Container(
//               width: 160,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: cardColor.withOpacity(0.2),
//                   width: 2,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: cardColor.withOpacity(0.1),
//                     blurRadius: 15,
//                     offset: Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: Stack(
//                 children: [
//                   Positioned(
//                     top: -10,
//                     right: -10,
//                     child: Container(
//                       width: 50,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: cardColor.withOpacity(0.1),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(20),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           padding: EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 cardColor.withOpacity(0.8),
//                                 cardColor,
//                               ],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Icon(
//                             Icons.group_work,
//                             color: Colors.white,
//                             size: 24,
//                           ),
//                         ),
//                         SizedBox(height: 16),
//                         Text(
//                           batch.batchCode,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF1A1A1A),
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         // Container(
//                         //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         //   decoration: BoxDecoration(
//                         //     color: cardColor.withOpacity(0.1),
//                         //     borderRadius: BorderRadius.circular(20),
//                         //   ),
//                         //   child: Text(
//                         //     '${batch.studentCount} ',
//                         //     style: TextStyle(
//                         //       fontSize: 12,
//                         //       color: cardColor,
//                         //       fontWeight: FontWeight.w600,
//                         //     ),
//                         //   ),
//                         // ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildEmptyState(String message, IconData icon) {
//     return Container(
//       height: 200,
//       margin: EdgeInsets.symmetric(horizontal: 20),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: Colors.grey[200]!,
//         ),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 size: 40,
//                 color: Colors.grey[400],
//               ),
//             ),
//             SizedBox(height: 16),
//             Text(
//               message,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Tap + to add new items',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[500],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildShimmerList() {
//     return Container(
//       height: 200,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.symmetric(horizontal: 20),
//         itemCount: 3,
//         separatorBuilder: (context, index) => SizedBox(width: 16),
//         itemBuilder: (context, index) {
//           return TweenAnimationBuilder<double>(
//             duration: Duration(milliseconds: 1500),
//             tween: Tween(begin: 0.3, end: 1.0),
//             builder: (context, value, child) {
//               return AnimatedContainer(
//                 duration: Duration(milliseconds: 800),
//                 width: 280,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.grey[200]!.withOpacity(value),
//                       Colors.grey[100]!.withOpacity(value * 0.5),
//                       Colors.grey[200]!.withOpacity(value),
//                     ],
//                     stops: [0.0, 0.5, 1.0],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Container(
//                   padding: EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             width: 40,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[300]?.withOpacity(value),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           Spacer(),
//                           Container(
//                             width: 50,
//                             height: 20,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[300]?.withOpacity(value),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 20),
//                       Container(
//                         width: double.infinity,
//                         height: 16,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[300]?.withOpacity(value),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Container(
//                         width: 150,
//                         height: 16,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[300]?.withOpacity(value),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       Spacer(),
//                       Container(
//                         width: double.infinity,
//                         height: 6,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[300]?.withOpacity(value),
//                           borderRadius: BorderRadius.circular(3),
//                         ),
//                       ),
//                       SizedBox(height: 12),
//                       Row(
//                         children: [
//                           Container(
//                             width: 80,
//                             height: 14,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[300]?.withOpacity(value),
//                               borderRadius: BorderRadius.circular(7),
//                             ),
//                           ),
//                           Spacer(),
//                           Container(
//                             width: 80,
//                             height: 14,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[300]?.withOpacity(value),
//                               borderRadius: BorderRadius.circular(7),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }