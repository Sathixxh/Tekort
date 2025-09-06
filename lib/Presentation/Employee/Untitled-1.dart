// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:intl/intl.dart';

// class Employcourse extends StatefulWidget {
//   @override
//   State<Employcourse> createState() => _EmploycourseState();
// }

// class _EmploycourseState extends State<Employcourse>
//     with TickerProviderStateMixin {
//   int currentTab = 0;
//   int _current = 0;
//   bool isExpanded = false;
//   PageController pageController = PageController();
//   DateTime? outTime;
//   List<BatchModel> userBatches = [];
//   bool isLoading = true;
//   final CarouselSliderController _controller = CarouselSliderController();
  
//   // Animation controllers
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late AnimationController _scaleController;
//   late AnimationController _pulseController;
  
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _pulseAnimation;

//   Color getProgressColor(double progress) {
//     if (progress >= 1.0) return Colors.green;
//     if (progress >= 0.5) return Colors.orange;
//     if (progress >= 0.3) return Colors.orange.shade200;
//     if (progress >= 0.1) return Colors.grey.shade400;
//     return Colors.grey;
//   }

//   String? name, email, course, customId;

//   final List<Widget> imageSliders = imgList
//       .map(
//         (item) => Container(
//           child: Container(
//             margin: EdgeInsets.all(5.0),
//             child: ClipRRect(
//               borderRadius: BorderRadius.all(Radius.circular(20.0)),
//               child: Stack(
//                 children: <Widget>[
//                   Image.asset(item, fit: BoxFit.cover, width: 1000.0),
//                   Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.transparent,
//                           Colors.black.withOpacity(0.3),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       )
//       .toList();

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _fetchUserData();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = Provider.of<EmployeeProvider>(context, listen: false);
//       provider.fetchEmployeeDetails();
//       fetchUserBatches();
//     });
//   }

//   void _initializeAnimations() {
//     _fadeController = AnimationController(
//       duration: Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _slideController = AnimationController(
//       duration: Duration(milliseconds: 1000),
//       vsync: this,
//     );
//     _scaleController = AnimationController(
//       duration: Duration(milliseconds: 600),
//       vsync: this,
//     );
//     _pulseController = AnimationController(
//       duration: Duration(milliseconds: 2000),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );
    
//     _slideAnimation = Tween<Offset>(
//       begin: Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
//     _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
//       CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
//     );
    
//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );

//     // Start animations
//     _fadeController.forward();
//     _slideController.forward();
//     _scaleController.forward();
//     _pulseController.repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _slideController.dispose();
//     _scaleController.dispose();
//     _pulseController.dispose();
//     super.dispose();
//   }

//   Future<void> fetchUserBatches() async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     try {
//       QuerySnapshot snapshot = await FirebaseFirestore.instance
//           .collection('batches')
//           .get();
//       List<BatchModel> allBatches = snapshot.docs.map((doc) {
//         return BatchModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
//       }).toList();
//       List<BatchModel> filtered = allBatches.where((batch) {
//         return batch.studentmap.containsKey(currentUser!.uid);
//       }).toList();
//       setState(() {
//         userBatches = filtered;
//         isLoading = false;
//       });
//     } catch (e) {
//       print("Error fetching batches: $e");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchUserData() async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid)
//           .get();
//       final data = snapshot.data();
//       if (data != null) {
//         setState(() {
//           email = data['email'];
//           name = data['name'];
//           course = data['course'];
//           customId = data['customId'];
//         });
//       }
//     }
//   }

//   Future<void> punchOut(BuildContext context) async {
//     final provider = Provider.of<AttendanceProvider>(context, listen: false);
//     final outTime = DateTime.now();
//     final inTime = provider.inTime ?? DateTime.now();
//     final duration = outTime.difference(inTime);
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);
//     final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     await FirebaseFirestore.instance.collection('attendance').add({
//       'email': email,
//       'name': name,
//       'course': course,
//       'customId': customId,
//       'inTime': inTime,
//       'outTime': outTime,
//       'duration': '${hours}h ${minutes}m',
//       'date': formattedDate,
//     });
//     provider.punchOut(outTime);
    
//     // Show animated snackbar
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.check_circle, color: Colors.white),
//             SizedBox(width: 10),
//             Text("Attendance recorded successfully!"),
//           ],
//         ),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: EdgeInsets.all(20),
//       ),
//     );
//   }

//   bool isToday(DateTime date) {
//     final now = DateTime.now();
//     return date.year == now.year &&
//         date.month == now.month &&
//         date.day == now.day;
//   }

//   Widget _buildAnimatedCard({
//     required Widget child,
//     double delay = 0.0,
//   }) {
//     return AnimatedBuilder(
//       animation: _fadeAnimation,
//       builder: (context, _) {
//         return FadeTransition(
//           opacity: _fadeAnimation,
//           child: SlideTransition(
//             position: _slideAnimation,
//             child: ScaleTransition(
//               scale: _scaleAnimation,
//               child: child,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildGradientCard({
//     required Widget child,
//     List<Color>? colors,
//     double elevation = 8.0,
//   }) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: colors ?? (isDark 
//             ? [Color(0xFF2D2D2D), Color(0xFF1E1E1E)]
//             : [Colors.white, Colors.grey.shade50]),
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: (isDark ? Colors.black : Colors.grey).withOpacity(0.3),
//             blurRadius: elevation,
//             offset: Offset(0, elevation / 2),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }

//   Widget _buildPulsingButton({
//     required VoidCallback onPressed,
//     required IconData icon,
//     required Color color,
//     required String tooltip,
//   }) {
//     return AnimatedBuilder(
//       animation: _pulseAnimation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _pulseAnimation.value,
//           child: Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: color.withOpacity(0.4),
//                   blurRadius: 15,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: IconButton(
//               onPressed: onPressed,
//               icon: Icon(icon),
//               color: color,
//               iconSize: 32,
//               tooltip: tooltip,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildClockCard({
//     required String title,
//     required String time,
//     required bool isActive,
//     required BuildContext context,
//   }) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return _buildGradientCard(
//       child: Container(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: isActive ? Colors.green : Colors.grey,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.access_time,
//                     color: Colors.white,
//                     size: 16,
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: isDark ? Colors.white70 : Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 15),
//             Text(
//               time,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: isActive 
//                   ? (isDark ? Colors.greenAccent : Colors.green)
//                   : (isDark ? Colors.white54 : Colors.grey),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLearningPoint(String point) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             margin: EdgeInsets.only(top: 8, right: 10),
//             width: 6,
//             height: 6,
//             decoration: BoxDecoration(
//               color: Colors.teal,
//               shape: BoxShape.circle,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               point.replaceAll('•', '').trim(),
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w400,
//                 height: 1.5,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final attendanceProvider = Provider.of<AttendanceProvider>(context);
//     final currentUser = FirebaseAuth.instance.currentUser;
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return FutureBuilder<DocumentSnapshot>(
//       future: FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser?.uid)
//           .get(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
//               ),
//             ),
//           );
//         }
//         final userData = snapshot.data!.data() as Map<String, dynamic>;
//         final assignedCourseKey = userData['course'];

//         return Consumer2<CourseProvider, ThemeSwitch>(
//           builder: (context, provider, themeprovider, _) {
//             final filteredCourses = provider.courses
//                 .where((course) => course.title == assignedCourseKey)
//                 .toList();
//             final CourseModel? course = filteredCourses.isNotEmpty
//                 ? filteredCourses.first
//                 : null;

//             return Scaffold(
//               body: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: isDark
//                         ? [Color(0xFF1A1A1A), Color(0xFF2D2D2D)]
//                         : [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
//                   ),
//                 ),
//                 child: SafeArea(
//                   child: CustomScrollView(
//                     slivers: [
//                       // Animated App Bar
//                       SliverAppBar(
//                         expandedHeight: 100,
//                         floating: true,
//                         pinned: true,
//                         elevation: 0,
//                         backgroundColor: Colors.transparent,
//                         automaticallyImplyLeading: false,
//                         flexibleSpace: FlexibleSpaceBar(
//                           background: Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [
//                                   Colors.teal.shade400,
//                                   Colors.teal.shade600,
//                                 ],
//                               ),
//                               borderRadius: BorderRadius.only(
//                                 bottomLeft: Radius.circular(30),
//                                 bottomRight: Radius.circular(30),
//                               ),
//                             ),
//                             child: Center(
//                               child: themeprovider.isDarkMode
//                                   ? Image.asset("assets/images/TEKORT LOGO.png", height: 60)
//                                   : Image.asset("assets/images/TEKORT LOGO1.png", height: 60),
//                             ),
//                           ),
//                         ),
//                         actions: [
//                           Padding(
//                             padding: EdgeInsets.only(right: 20),
//                             child: attendanceProvider.hasPunchedToday
//                                 ? SizedBox()
//                                 : attendanceProvider.isPunchedIn
//                                     ? _buildPulsingButton(
//                                         onPressed: () => punchOut(context),
//                                         icon: Icons.logout,
//                                         color: Colors.redAccent,
//                                         tooltip: 'Punch Out',
//                                       )
//                                     : _buildPulsingButton(
//                                         onPressed: () {
//                                           attendanceProvider.punchIn(DateTime.now());
//                                         },
//                                         icon: Icons.login,
//                                         color: Colors.greenAccent,
//                                         tooltip: 'Punch In',
//                                       ),
//                           ),
//                         ],
//                       ),

//                       // Main Content
//                       SliverList(
//                         delegate: SliverChildListDelegate([
//                           SizedBox(height: 20),
                          
//                           // Welcome Message
//                           _buildAnimatedCard(
//                             child: Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 20),
//                               child: Text(
//                                 "Hi, $name (${customId ?? 'Loading...'})",
//                                 style: TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                   color: isDark ? Colors.white : Colors.grey[800],
//                                 ),
//                               ),
//                             ),
//                           ),
                          
//                           SizedBox(height: 20),

//                           // Course Progress Card
//                           _buildAnimatedCard(
//                             child: Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 20),
//                               child: _buildGradientCard(
//                                 colors: [
//                                   Colors.teal.shade400,
//                                   Colors.teal.shade600,
//                                 ],
//                                 child: Container(
//                                   padding: EdgeInsets.all(25),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Container(
//                                             padding: EdgeInsets.all(10),
//                                             decoration: BoxDecoration(
//                                               color: Colors.white.withOpacity(0.2),
//                                               borderRadius: BorderRadius.circular(12),
//                                             ),
//                                             child: Icon(
//                                               Icons.school,
//                                               color: Colors.white,
//                                               size: 24,
//                                             ),
//                                           ),
//                                           SizedBox(width: 15),
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   "Current Career Programme",
//                                                   style: TextStyle(
//                                                     color: Colors.white70,
//                                                     fontSize: 14,
//                                                     fontWeight: FontWeight.w500,
//                                                   ),
//                                                 ),
//                                                 SizedBox(height: 5),
//                                                 Text(
//                                                   course?.title ?? "Loading...",
//                                                   style: TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: 20,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
                                      
//                                       SizedBox(height: 25),

//                                       // Progress Section
//                                       if (userBatches.isNotEmpty)
//                                         ...userBatches.map((batch) {
//                                           final now = DateTime.now();
//                                           final totalDuration = batch.endDate
//                                               .difference(batch.startDate)
//                                               .inDays;
//                                           final completedDuration = now
//                                               .difference(batch.startDate)
//                                               .inDays;
//                                           double progress = completedDuration / totalDuration;
//                                           progress = progress.clamp(0.0, 1.0);

//                                           return Column(
//                                             children: [
//                                               Container(
//                                                 height: 12,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius: BorderRadius.circular(6),
//                                                   color: Colors.white.withOpacity(0.3),
//                                                 ),
//                                                 child: ClipRRect(
//                                                   borderRadius: BorderRadius.circular(6),
//                                                   child: LinearProgressIndicator(
//                                                     value: progress,
//                                                     backgroundColor: Colors.transparent,
//                                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                                       Colors.white,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                               SizedBox(height: 15),
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                 children: [
//                                                   Text(
//                                                     'Completed: ${(progress * 100).toStringAsFixed(1)}%',
//                                                     style: TextStyle(
//                                                       fontWeight: FontWeight.w600,
//                                                       color: Colors.white,
//                                                       fontSize: 16,
//                                                     ),
//                                                   ),
//                                                   Text(
//                                                     "Duration: ${course?.duration ?? 'N/A'} months",
//                                                     style: TextStyle(
//                                                       color: Colors.white70,
//                                                       fontSize: 14,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           );
//                                         }).toList(),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),

//                           SizedBox(height: 25),

//                           // Clock Cards
//                           _buildAnimatedCard(
//                             delay: 0.2,
//                             child: Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 20),
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     child: _buildClockCard(
//                                       title: "Clock in",
//                                       time: (attendanceProvider.inTime != null &&
//                                               isToday(attendanceProvider.inTime!))
//                                           ? DateFormat('hh:mm:ss a').format(attendanceProvider.inTime!)
//                                           : "-----",
//                                       isActive: (attendanceProvider.inTime != null &&
//                                           isToday(attendanceProvider.inTime!)),
//                                       context: context,
//                                     ),
//                                   ),
//                                   SizedBox(width: 15),
//                                   Expanded(
//                                     child: _buildClockCard(
//                                       title: "Clock out",
//                                       time: (attendanceProvider.outTime != null &&
//                                               isToday(attendanceProvider.outTime!))
//                                           ? DateFormat('hh:mm:ss a').format(attendanceProvider.outTime!)
//                                           : "-----",
//                                       isActive: (attendanceProvider.outTime != null &&
//                                           isToday(attendanceProvider.outTime!)),
//                                       context: context,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),

//                           SizedBox(height: 25),

//                           // Course Description
//                           _buildAnimatedCard(
//                             delay: 0.3,
//                             child: Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 20),
//                               child: _buildGradientCard(
//                                 child: Theme(
//                                   data: Theme.of(context).copyWith(
//                                     dividerColor: Colors.transparent,
//                                   ),
//                                   child: ExpansionTile(
//                                     initiallyExpanded: false,
//                                     tilePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                                     childrenPadding: EdgeInsets.all(20),
//                                     leading: Container(
//                                       padding: EdgeInsets.all(10),
//                                       decoration: BoxDecoration(
//                                         gradient: LinearGradient(
//                                           colors: [Colors.teal.shade400, Colors.teal.shade600],
//                                         ),
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: Icon(Icons.book, color: Colors.white),
//                                     ),
//                                     title: Text(
//                                       "Course Description",
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 18,
//                                       ),
//                                     ),
//                                     iconColor: Colors.teal,
//                                     collapsedIconColor: Colors.grey[600],
//                                     children: [
//                                       Container(
//                                         padding: EdgeInsets.all(20),
//                                         decoration: BoxDecoration(
//                                           color: isDark 
//                                             ? Colors.grey[800]
//                                             : Colors.grey[50],
//                                           borderRadius: BorderRadius.circular(15),
//                                         ),
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               "Course Overview",
//                                               style: TextStyle(
//                                                 fontSize: 18,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             SizedBox(height: 15),
//                                             Text(
//                                               "What you'll learn:",
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.w600,
//                                                 color: Colors.teal,
//                                               ),
//                                             ),
//                                             SizedBox(height: 10),
//                                             if (course?.description == null || course!.description.isEmpty)
//                                               Text(
//                                                 "N/A",
//                                                 style: TextStyle(
//                                                   fontSize: 14,
//                                                   fontWeight: FontWeight.w400,
//                                                   height: 1.5,
//                                                 ),
//                                               )
//                                             else
//                                               ...course!.description.split('/').map(
//                                                 (point) => _buildLearningPoint(point.trim()),
//                                               ),
//                                             SizedBox(height: 20),
//                                             Row(
//                                               children: [
//                                                 Container(
//                                                   padding: EdgeInsets.all(8),
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.teal.withOpacity(0.1),
//                                                     borderRadius: BorderRadius.circular(8),
//                                                   ),
//                                                   child: Icon(Icons.schedule, size: 20, color: Colors.teal),
//                                                 ),
//                                                 SizedBox(width: 10),
//                                                 Text(
//                                                   course!.duration.isEmpty 
//                                                     ? "N/A" 
//                                                     : "${course!.duration} - Duration",
//                                                   style: TextStyle(
//                                                     fontSize: 14,
//                                                     fontWeight: FontWeight.w500,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             SizedBox(height: 10),
//                                             Row(
//                                               children: [
//                                                 Container(
//                                                   padding: EdgeInsets.all(8),
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.teal.withOpacity(0.1),
//                                                     borderRadius: BorderRadius.circular(8),
//                                                   ),
//                                                   child: Icon(Icons.people, size: 20, color: Colors.teal),
//                                                 ),
//                                                 SizedBox(width: 10),
//                                                 Text(
//                                                   "Mentor support included",
//                                                   style: TextStyle(
//                                                     fontSize: 14,
//                                                     fontWeight: FontWeight.w500,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),

//                           SizedBox(height: 25),

//                           // Tasks Section
//                           _buildAnimatedCard(
//                             delay: 0.4,
//                             child: Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 20),
//                               child: Consumer<EmployeeProvider>(
//                                 builder: (context, provider, child) {
//                                   final tasks = provider.taskList ?? [];
//                                   return _buildGradientCard(
//                                     child: Theme(
//                                       data: Theme.of(context).copyWith(
//                                         dividerColor: Colors.transparent,
//                                       ),
//                                       child: ExpansionTile(
//                                         initiallyExpanded: false,
//                                         leading: Container(
//                                           padding: EdgeInsets.all(10),
//                                           decoration: BoxDecoration(
//                                             gradient: LinearGradient(
//                                               colors: [Colors.orange.shade400, Colors.orange.shade600],
//                                             ),
//                                             borderRadius: BorderRadius.circular(12),
//                                           ),
//                                           child: Icon(Icons.assignment, color: Colors.white),
//                                         ),
//                                         title: Text(
//                                           "Assigned Tasks",
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 18,
//                                           ),
//                                         ),
//                                         childrenPadding: EdgeInsets.all(15),
//                                         iconColor: Colors.orange,
//                                         collapsedIconColor: Colors.grey[600],
//                                         children: tasks.isNotEmpty
//                                             ? tasks.map((task) {
//                                                 return Container(
//                                                   margin: EdgeInsets.only(bottom: 15),
//                                                   padding: EdgeInsets.all(15),
//                                                   decoration: BoxDecoration(
//                                                     color: isDark 
//                                                       ? Colors.grey[800]
//                                                       : Colors.grey[50],
//                                                     borderRadius: BorderRadius.circular(15),
//                                                     border: Border.all(
//                                                       color: task['status'] == 'Pending'
//                                                           ? Colors.orange
//                                                           : task['status'] == 'Completed'
//                                                               ? Colors.green
//                                                               : Colors.grey,
//                                                       width: 1,
//                                                     ),
//                                                   ),
//                                                   child: Column(
//                                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                                     children: [
//                                                       Row(
//                                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                         children: [
//                                                           Expanded(
//                                                             child: Text(
//                                                               task['taskName'] ?? "No Task",
//                                                               style: TextStyle(
//                                                                 fontSize: 16,
//                                                                 fontWeight: FontWeight.w600,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           Container(
//                                                             padding: EdgeInsets.symmetric(
//                                                                 horizontal: 12, vertical: 6),
//                                                             decoration: BoxDecoration(
//                                                               color: task['status'] == 'Pending'
//                                                                   ? Colors.orange.withOpacity(0.1)
//                                                                   : task['status'] == 'Completed'
//                                                                       ? Colors.green.withOpacity(0.1)
//                                                                       : Colors.grey.withOpacity(0.1),
//                                                               borderRadius: BorderRadius.circular(20),
//                                                             ),
//                                                             child: Text(
//                                                               task['status'] ?? "No Status",
//                                                               style: TextStyle(
//                                                                 fontSize: 12,
//                                                                 fontWeight: FontWeight.w600,
//                                                                 color: task['status'] == 'Pending'
//                                                                     ? Colors.orange
//                                                                     : task['status'] == 'Completed'
//                                                                         ? Colors.green
//                                                                         : Colors.grey,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                       SizedBox(height: 10),
//                                                       Row(
//                                                         children: [
//                                                           Icon(
//                                                             Icons.calendar_today,
//                                                             size: 16,
//                                                             color: Colors.grey[600],
//                                                           ),
//                                                           SizedBox(width: 8),
//                                                           Text(
//                                                             "From: ${task['startDate']?.toString().split('T').first ?? '-'} to ${task['endDate']?.toString().split('T').first ?? '-'}",
//                                                             style: TextStyle(
//                                                               fontSize: 12,
//                                                               color: Colors.grey[600],
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 );
//                                               }).toList()
//                                             : [
//                                                 Container(
//                                                   padding: EdgeInsets.all(20),
//                                                   decoration: BoxDecoration(
//                                                     color: isDark 
//                                                       ? Colors.grey[800]
//                                                       : Colors.grey[50],
//                                                     borderRadius: BorderRadius.circular(15),
//                                                   ),
//                                                   child: Center(
//                                                     child: Column(
//                                                       children: [
//                                                         Icon(
//                                                           Icons.assignment_outlined,
//                                                           size: 48,
//                                                           color: Colors.grey[400],
//                                                         ),
//                                                         SizedBox(height: 10),
//                                                         Text(
//                                                           "No tasks assigned yet",
//                                                           style: TextStyle(
//                                                             fontSize: 16,
//                                                             color: Colors.grey[600],
//                                                             fontWeight: FontWeight.w500,
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),

//                           SizedBox(height: 30),

//                           // Carousel Section
//                           _buildAnimatedCard(
//                             delay: 0.5,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Padding(
//                                   padding: EdgeInsets.symmetric(horizontal: 20),
//                                   child: Text(
//                                     "Latest Updates",
//                                     style: TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                       color: isDark ? Colors.white : Colors.grey[800],
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(height: 15),
//                                 Container(
//                                   height: 200,
//                                   child: CarouselSlider(
//                                     items: imageSliders.map((slider) {
//                                       return Container(
//                                         margin: EdgeInsets.symmetric(horizontal: 8),
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(20),
//                                           boxShadow: [
//                                             BoxShadow(
//                                               color: Colors.black.withOpacity(0.2),
//                                               blurRadius: 15,
//                                               offset: Offset(0, 8),
//                                             ),
//                                           ],
//                                         ),
//                                         child: ClipRRect(
//                                           borderRadius: BorderRadius.circular(20),
//                                           child: Stack(
//                                             children: [
//                                               Container(
//                                                 width: double.infinity,
//                                                 child: slider,
//                                               ),
//                                               Container(
//                                                 decoration: BoxDecoration(
//                                                   gradient: LinearGradient(
//                                                     begin: Alignment.topCenter,
//                                                     end: Alignment.bottomCenter,
//                                                     colors: [
//                                                       Colors.transparent,
//                                                       Colors.black.withOpacity(0.4),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     }).toList(),
//                                     carouselController: _controller,
//                                     options: CarouselOptions(
//                                       autoPlay: true,
//                                       enlargeCenterPage: true,
//                                       aspectRatio: 2.0,
//                                       autoPlayInterval: Duration(seconds: 4),
//                                       autoPlayAnimationDuration: Duration(milliseconds: 800),
//                                       autoPlayCurve: Curves.fastOutSlowIn,
//                                       viewportFraction: 0.85,
//                                       onPageChanged: (index, reason) {
//                                         setState(() {
//                                           _current = index;
//                                         });
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(height: 15),
//                                 // Carousel indicators
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: imageSliders.asMap().entries.map((entry) {
//                                     return AnimatedContainer(
//                                       duration: Duration(milliseconds: 300),
//                                       width: _current == entry.key ? 12.0 : 8.0,
//                                       height: _current == entry.key ? 12.0 : 8.0,
//                                       margin: EdgeInsets.symmetric(horizontal: 4.0),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: _current == entry.key
//                                             ? Colors.teal
//                                             : Colors.grey.withOpacity(0.4),
//                                       ),
//                                     );
//                                   }).toList(),
//                                 ),
//                               ],
//                             ),
//                           ),

//                           SizedBox(height: 30),

//                           // Bottom spacing
//                           SizedBox(height: 20),
//                         ]),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

