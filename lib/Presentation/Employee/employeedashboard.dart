import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:animations/animations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tekort/Models/batchmodel.dart';
import 'package:tekort/Models/coursemodel.dart';
import 'package:tekort/Presentation/Employee/empattendance.dart';
import 'package:tekort/Presentation/notification/nofiticationscren.dart';
import 'package:tekort/Presentation/profile.dart';
import 'package:tekort/Providers/attenceprovider.dart';
import 'package:tekort/Providers/courseprovider.dart';
import 'package:tekort/Providers/employeeprovider.dart';
import 'package:tekort/core/core/common/loading.dart';
import 'package:tekort/core/core/themes/themeprovider/themeprovider.dart';
import 'package:tekort/core/core/utils/styles.dart';
import 'package:tekort/curosalwidget.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({Key? key}) : super(key: key);
  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  final PageController _pageController = PageController(initialPage: 1);
  final NotchBottomBarController _controller = NotchBottomBarController(
    index: 1,
  );
  int maxCount = 3;
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> bottomBarPages = [
      EmpAttendanceHistoryScreen(),
      Employcourse(),
      AccountScreen(),
    ];
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundcolor2,
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: bottomBarPages,
        ),
        extendBody: true,
        bottomNavigationBar: (bottomBarPages.length <= maxCount)
            ? Consumer<ThemeSwitch>(
                builder: (context, themeprovider, child) {
                  return AnimatedNotchBottomBar(
                    notchBottomBarController: _controller,
                    color: (Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(255, 46, 46, 46)
                        : const Color.fromARGB(255, 230, 228, 228)),
                    showLabel: true,
                    textOverflow: TextOverflow.visible,
                    maxLine: 1,
                    shadowElevation: 5,
                    kBottomRadius: 28.0,
                    notchColor: const Color.fromRGBO(4, 168, 136, 1),
                    removeMargins: false,
                    bottomBarWidth: 500,
                    showShadow: false,
                    durationInMilliSeconds: 300,
                    itemLabelStyle: TextStyle(fontSize: 10),
                    elevation: 1,
                    bottomBarItems: [
                      BottomBarItem(
                        inActiveItem: ImageIcon(
                          AssetImage("assets/images/event.png"),
                        ),
                        activeItem: ImageIcon(
                          AssetImage("assets/images/event.png"),
                          color: Colors.white,
                        ),
                      ),
                      BottomBarItem(
                        inActiveItem: ImageIcon(
                          AssetImage("assets/images/home.png"),
                        ),
                        activeItem: ImageIcon(
                          AssetImage("assets/images/home.png"),
                          color: backgroundcolor,
                        ),
                      ),
                      BottomBarItem(
                        inActiveItem: Icon(Icons.person_2_outlined),
                        activeItem: Icon(
                          Icons.person_2_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    onTap: (index) {
                      _pageController.jumpToPage(index);
                    },
                    kIconSize: 24.0,
                  );
                },
              )
            : null,
      ),
    );
  }
}

class Employcourse extends StatefulWidget {
  @override
  State<Employcourse> createState() => _EmploycourseState();
}

class _EmploycourseState extends State<Employcourse>
    with TickerProviderStateMixin {
  // Theme colors
  Color get primaryColor => Theme.of(context).primaryColor;
  Color get backgroundColor => Theme.of(context).scaffoldBackgroundColor;
  Color get cardColor => Theme.of(context).cardColor;
  Color get textColor =>
      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  Color get surfaceColor => Theme.of(context).colorScheme.surface;
  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  int currentTab = 0;
  int _current = 0;
  bool isExpanded = false;
  PageController pageController = PageController();
  DateTime? outTime;
  List<BatchModel> userBatches = [];

  bool isLoading = true;
  Color getProgressColor(double progress) {
    if (progress >= 1.0) return primaryColor; // 100% complete
    if (progress >= 0.5) return Colors.orange; // 50% to <100%
    if (progress >= 0.3) return Colors.orange.shade200; // 30% to <50%
    if (progress >= 0.1) return Colors.grey.shade400; // 10% to <30%
    return Colors.grey; // 0% to <10%
  }

  String? name, email, course, customId;
  final List<Widget> imageSliders = imgList
      .map(
        (item) => Container(
          child: Container(
            margin: EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              child: Stack(
                children: <Widget>[
                  Image.asset(item, fit: BoxFit.cover, width: 1000.0),
                ],
              ),
            ),
          ),
        ),
      )
      .toList();
  @override
  void initState() {
    super.initState();
    _fetchUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EmployeeProvider>(context, listen: false);
      provider.fetchEmployeeDetails();
      fetchUserBatches();
    });
  }

  Future<void> fetchUserBatches() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('batches')
          .get();
      List<BatchModel> allBatches = snapshot.docs.map((doc) {
        return BatchModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      List<BatchModel> filtered = allBatches.where((batch) {
        return batch.studentmap.containsKey(currentUser!.uid);
      }).toList();
      setState(() {
        userBatches = filtered;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching batches: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final data = snapshot.data();
      if (data != null) {
        setState(() {
          email = data['email'];
          name = data['name'];
          course = data['course'];
          customId = data['customId'];
        });
      }
    }
  }

  Future<void> punchOut(BuildContext context) async {
    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    final outTime = DateTime.now();
    final inTime = provider.inTime ?? DateTime.now();
    final duration = outTime.difference(inTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await FirebaseFirestore.instance.collection('attendance').add({
      'email': email,
      'name': name,
      'course': course,
      'customId': customId,
      'inTime': inTime,
      'outTime': outTime,
      'duration': '${hours}h ${minutes}m',
      'date': formattedDate,
    });
    provider.punchOut(outTime); // <-- pass outTime here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Attendance recorded successfully!")),
    );
  }

  Widget _buildGradientCard({
    required Widget child,
    List<Color>? colors,
    double elevation = 8.0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              colors ??
              (isDark
                  ? [Color(0xFF2D2D2D), Color(0xFF1E1E1E)]
                  : [Colors.white, Colors.grey.shade50]),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.3),
            blurRadius: elevation,
            offset: Offset(0, elevation / 2),
          ),
        ],
      ),
      child: child,
    );
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
       final isDark =
                      Theme.of(context).brightness == Brightness.dark;
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(body: loadingWidget());
        }
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final assignedCourseKey = userData['course'];
        return Consumer2<CourseProvider, ThemeSwitch>(
          builder: (context, provider, themeprovider, _) {
            final filteredCourses = provider.courses
                .where((course) => course.title == assignedCourseKey)
                .toList();
            final CourseModel? course = filteredCourses.isNotEmpty
                ? filteredCourses.first
                : null;

            return Scaffold(
              backgroundColor:isDark?blackColor: const Color.fromARGB(
                255,
                179,
                211,
                205,
              ).withOpacity(0.1),
                           body: Consumer<CourseProvider>(
                builder: (context, provider, _) {
                 
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Text(
                          "Hi,",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 3, 20, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$name",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NotificationScreen()),
);

                              },
                              child: Icon(Icons.notifications_active_rounded)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color:isDark?const Color.fromARGB(255, 31, 31, 31): backgroundcolor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color:isDark?Colors.grey[800]: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Current Career Programme",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                         
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),

                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              course?.title ?? "Loading...",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 12),

                                        SizedBox(
                                          height: 40,
                                          child: ListView.builder(
                                            itemCount: userBatches.length,
                                            itemBuilder: (context, index) {
                                              final batch = userBatches[index];
                                              final now = DateTime.now();
                                              final totalDuration = batch
                                                  .endDate
                                                  .difference(batch.startDate)
                                                  .inDays;
                                              final completedDuration = now
                                                  .difference(batch.startDate)
                                                  .inDays;
                                              double progress =
                                                  completedDuration /
                                                  totalDuration;
                                              progress = progress.clamp(
                                                0.0,
                                                1.0,
                                              ); // ensure between 0 and 1
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  LinearProgressIndicator(
                                                    value: progress,
                                                    minHeight: 8,
                                                    backgroundColor:
                                                        Colors.grey.shade300,
                                                    // color: getProgressColor(
                                                    //   progress,
                                                    // ),
                                                    color: primaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  SizedBox(height: 15),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        '${(progress * 100).toStringAsFixed(1)}% Completed',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                                  fontSize: 13,
                                                        ),
                                                      ),
                                                      Text(
                                                        "Duration:${course?.duration ?? 'N/A'}",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Inside your widget
                                      attendanceProvider.hasPunchedToday
                                          ? SvgPicture.asset(
                                              'assets/images/Punchout.svg',
                                            )
                                          // Already punched today
                                          : attendanceProvider.isPunchedIn
                                          ? InkWell(
                                              onTap: () => punchOut(context),
                                              child: SvgPicture.asset(
                                                'assets/images/Punchout.svg',
                                                width: 24,
                                                height: 24,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                      Colors
                                                          .red, // Or any color
                                                      BlendMode.srcIn,
                                                    ),
                                              ),
                                            )
                                          : InkWell(
                                              onTap: () => attendanceProvider
                                                  .punchIn(DateTime.now()),
                                              child: SvgPicture.asset(
                                                'assets/images/Punchin.svg',
                                                width: 24,
                                                height: 24,
                                              ),
                                            ),

                                      Expanded(
                                        child: _buildClockCard(
                                          title: "Clock in",
                                          time:
                                              (attendanceProvider.inTime !=
                                                      null &&
                                                  isToday(
                                                    attendanceProvider.inTime!,
                                                  ))
                                              ? DateFormat('hh:mm:ss a').format(
                                                  attendanceProvider.inTime!,
                                                )
                                              : "-----",
                                          isActive:
                                              (attendanceProvider.inTime !=
                                                  null &&
                                              isToday(
                                                attendanceProvider.inTime!,
                                              )),
                                          context: context,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildClockCard(
                                          title: "Clock out",
                                          time:
                                              (attendanceProvider.outTime !=
                                                      null &&
                                                  isToday(
                                                    attendanceProvider.outTime!,
                                                  ))
                                              ? DateFormat('hh:mm:ss a').format(
                                                  attendanceProvider.outTime!,
                                                )
                                              : "-----",
                                          isActive:
                                              (attendanceProvider.outTime !=
                                                  null &&
                                              isToday(
                                                attendanceProvider.outTime!,
                                              )),
                                          context: context,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                     
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('tasks')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: loadingWidget());
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return _buildNoTaskCard(isDark);
                          }

                          final tasks = snapshot.data!.docs;
                      

                       return SingleChildScrollView(
  child: Padding(
    padding: const EdgeInsets.only(top: 5, bottom: 0),
    child: Builder(
      builder: (context) {
        final currentUser = FirebaseAuth.instance.currentUser;

        // Filtered list based on current user
        final filteredTasks = tasks.where((task) {
          final Map<String, dynamic> studentMap =
              Map<String, dynamic>.from(task['studentMap'] ?? {});
          return studentMap.values.any((value) {
            final details = Map<String, dynamic>.from(value);
            return details['uid'] == currentUser!.uid;
          });
        }).toList();

        // If no matching tasks → show "No Task" card
        if (filteredTasks.isEmpty) {
          return _buildNoTaskCard(isDark);
        }

        // Show only first 3 here
        final displayedTasks = filteredTasks.take(3).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Task",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AllTasksScreen(
                            allTasks: filteredTasks,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "View all",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                  )
                ],
              ),
            ),
            ...displayedTasks.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;

              final Map<String, dynamic> studentMap =
                  Map<String, dynamic>.from(task['studentMap'] ?? {});
              final userEntry = studentMap.entries.firstWhere(
                (e) {
                  final details = Map<String, dynamic>.from(e.value);
                  return details['uid'] == currentUser!.uid;
                },
                orElse: () => const MapEntry('', {}),
              );

              return _buildTaskCard1(task, index, userEntry,isDark,context);
            }),
          ],
        );
      },
    ),
  ),
);


                        },
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Text(
                              "Course Description",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              "viwe all",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                          ],
                        ),
                      ),
                  CourseDescription(
  description: course?.description ?? 'No description available',
  title: course?.title ?? 'Untitled',
)

                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class BatchProgressCard extends StatelessWidget {
  final String batchCode;
  final DateTime startDate;
  final DateTime endDate;

  const BatchProgressCard({
    super.key,
    required this.batchCode,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final totalDays = endDate.difference(startDate).inDays;
    final completedDays = now.isBefore(startDate)
        ? 0
        : now.isAfter(endDate)
        ? totalDays
        : now.difference(startDate).inDays;

    final remainingDays = totalDays - completedDays;
    final progress = totalDays == 0 ? 0.0 : completedDays / totalDays;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Batch: $batchCode",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade300,
              color: Colors.blue,
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Start: ${DateFormat('dd MMM yyyy').format(startDate)}"),
                Text("End: ${DateFormat('dd MMM yyyy').format(endDate)}"),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Completed: ${completedDays} days (${(progress * 100).toStringAsFixed(1)}%)",
              style: TextStyle(color: primaryColor),
            ),
            Text(
              "Remaining: $remainingDays days",
              style: TextStyle(color: Colors.redAccent),
            ),
            Text(
              "Total Duration: $totalDays days",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildClockCard({
  required String title,
  required String time,
  required bool isActive,
  required BuildContext context,
}) {
  return Row(
    children: [
      Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,color: title=='Clock out'?Colors.orange:primaryColor)),
      SizedBox(width: 3),
      Text(
        time,
        style: TextStyle(
          fontSize: 11,
         
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}



class CourseDescription extends StatefulWidget {
  final String description;
  final String title;
  const CourseDescription({
    Key? key,
    required this.description,
    required this.title,
  }) : super(key: key);

  @override
  State<CourseDescription> createState() => _CourseDescriptionState();
}

class _CourseDescriptionState extends State<CourseDescription>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  final int _maxVisibleItems = 3;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Split description into list items based on "/"
    final List<String> descriptionItems = widget.description
        .split('/')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    // Items to display depending on expansion state
    final List<String> itemsToDisplay = _isExpanded
        ? descriptionItems
        : descriptionItems.take(_maxVisibleItems).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : backgroundcolor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            // Animated bullet list
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: itemsToDisplay.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "• ",
                          style: TextStyle(fontSize: 14, height: 1.5),
                        ),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 12, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // View more/less button
            if (descriptionItems.length > _maxVisibleItems)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  _isExpanded ? "View Less" : "View More",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


Widget _buildNoTaskCard(bool isDark) {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      children: [
 Row(
   mainAxisAlignment: MainAxisAlignment.spaceBetween,
   children: [
     const Text(
       "Task",
       style: TextStyle(
         fontSize: 18,
         fontWeight: FontWeight.w900,
       ),
     ),
     TextButton(
       onPressed: () {
         
       },
       child: const Text(
         "View all",
         style: TextStyle(
           fontSize: 15,
           fontWeight: FontWeight.w100,
         ),
       ),
     )
   ],
 ),

        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[50],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.assignment_outlined, size: 48, color: Colors.grey[400]),
                SizedBox(height: 10),
                Text(
                  "No tasks assigned yet",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}



Widget _buildTaskCard1(
    DocumentSnapshot task, int index, MapEntry<String, dynamic> userEntry ,bool theme,BuildContext context) {
  final studentDetails = Map<String, dynamic>.from(userEntry.value);
  final studentStatus = studentDetails['status'] ?? 'Pending';
  

  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
    child: Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 20, 3),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and status row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          task['taskName'] ?? "No Task",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Container(
  height: MediaQuery.of(context).size.height * 0.02, // 3% of screen height
  width: MediaQuery.of(context).size.width * 0.18,  // 25% of screen width
  // padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
  decoration: BoxDecoration(
    color: studentStatus == 'Pending'
        ? theme
            ? const Color.fromARGB(255, 236, 184, 104)
            : Colors.orange.withOpacity(0.1)
        : studentStatus == 'Completed'
            ? theme
                ? primaryColor
                : primaryColor.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
  ),
  alignment: Alignment.center, // Ensures text stays centered
  child: Text(
    studentStatus,
    style: TextStyle(fontSize: 10),
    textAlign: TextAlign.center,
  ),
)
                    ]

                  ),
                  SizedBox(height: 5),
                  Text(
                    "From: ${task['startDate']?.toString().split('T').first ?? '-'} "
                    "to ${task['endDate']?.toString().split('T').first ?? '-'}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}





class AllTasksScreen extends StatefulWidget {
  final List<DocumentSnapshot> allTasks;
  const AllTasksScreen({Key? key, required this.allTasks}) : super(key: key);

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  String selectedFilter = 'All Tasks'; // 'All', 'Pending', 'Completed'

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
  final isDark = Theme.of(context).brightness == Brightness.dark;
    // Filter the tasks based on selected filter
    final filteredTasks = widget.allTasks.where((task) {
      final Map<String, dynamic> studentMap =
          Map<String, dynamic>.from(task['studentMap'] ?? {});
      final userEntry = studentMap.entries.firstWhere(
        (e) {
          final details = Map<String, dynamic>.from(e.value);
          return details['uid'] == currentUser!.uid;
        },
        orElse: () => const MapEntry('', {}),
      );

      if (selectedFilter == 'All Tasks') return true;
      final status = Map<String, dynamic>.from(userEntry.value)['status'] ?? '';
      return status == selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor:isDark?blackColor: backgroundcolor2,
      appBar: AppBar(title: const Text('All Tasks')),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // Filter buttons row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterButton('All Tasks'),
                const SizedBox(width: 8),
                _buildFilterButton('Pending'),
                const SizedBox(width: 8),
                _buildFilterButton('Completed'),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Animated list section
          Expanded(
            child: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation, secondaryAnimation) {
                return SharedAxisTransition(
                  fillColor:   isDark?blackColor: backgroundcolor2,
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                );
              },
              child: ListView.builder(
                key: ValueKey(selectedFilter), // important for animation
                padding: const EdgeInsets.only(top: 5, bottom: 0),
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  final Map<String, dynamic> studentMap =
                      Map<String, dynamic>.from(task['studentMap'] ?? {});
                  final userEntry = studentMap.entries.firstWhere(
                    (e) {
                      final details = Map<String, dynamic>.from(e.value);
                      return details['uid'] == currentUser!.uid;
                    },
                    orElse: () => const MapEntry('', {}),
                  );

                  return _buildTaskCard1(task, index, userEntry,isDark,context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
// Builds a filter button with style changes
Widget _buildFilterButton(String label) {
  final isSelected = selectedFilter == label;
  return SingleChildScrollView(
    child: SizedBox(
      // width: 105, // set your desired width
      height: 40, // set your desired height
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? primaryColor : Colors.white,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: () {
          setState(() {
            selectedFilter = label;
          });
        },
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? Colors.white : primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}

}
