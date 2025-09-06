import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tekort/Providers/employeeprovider.dart';
import 'package:tekort/core/core/common/loading.dart';
import 'package:tekort/core/core/utils/styles.dart';

class EmpAttendanceHistoryScreen extends StatefulWidget {
  const EmpAttendanceHistoryScreen({Key? key}) : super(key: key);

  @override
  State<EmpAttendanceHistoryScreen> createState() =>
      _EmpAttendanceHistoryScreenState();
}

class _EmpAttendanceHistoryScreenState
    extends State<EmpAttendanceHistoryScreen> {
  Map<DateTime, bool> attendanceMap = {};
  bool isLoading = true;
  bool isPunchedIn = false;
  DateTime? inTime;
  String? name, email, course, customId;
  @override
  void initState() {
    super.initState();
    fetchAttendance();
    _fetchUserData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EmployeeProvider>(context, listen: false);
      provider.fetchEmployeeDetails();
    });
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

  Future<void> fetchAttendance() async {
    final employee = Provider.of<EmployeeProvider>(context, listen: false);
    final customId = employee.customId;
    if (customId == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('customId', isEqualTo: customId)
        .get();
    final Map<DateTime, bool> tempMap = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      Timestamp? inTime = data['inTime'];
      Timestamp? outTime = data['outTime'];
      if (inTime != null) {
        DateTime date = DateTime(
          inTime.toDate().year,
          inTime.toDate().month,
          inTime.toDate().day,
        );
        tempMap[date] = outTime != null; // true = present, false = no outTime
      }
    }
    setState(() {
      attendanceMap = tempMap;
      isLoading = false;
    });
  }

  String formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return "N/A";
    return DateFormat('yyyy-MM-dd').format(timestamp.toDate());
  }

  String formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "N/A";
    return DateFormat('hh:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final employee = Provider.of<EmployeeProvider>(context);
    final customId = employee.customId;
    if (customId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Attendance History')),
        body: Center(child: Text("No employee data found.")),
      );
    }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: primaryColor,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.people_alt_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Attendance Records',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      bottom: TabBar(
        dividerColor: Colors.white,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        tabs:  [
          Tab(
            icon: Icon(Icons.view_list),
            text: 'Daily Overview',
          ),
          Tab(
            icon: Icon(Icons.calendar_month),
            text: 'Monthly Calendar',
          ),
        ],
      ),
    );
  }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: _buildAppBar(),
        // appBar: AppBar(
        //   backgroundColor: primaryColor,
        //   title: Text('Attendance History'),
        //   automaticallyImplyLeading: false,
        //   actions: [],
        //   bottom: const TabBar(
        //     tabs: [
        //       Tab(text: 'Daily'),
        //       Tab(text: 'Monthly'),
        //     ],
        //   ),
        // ),
        body: TabBarView(
          children: [
            // Daily Tab
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('attendance')
                  .where('customId', isEqualTo: customId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: loadingWidget());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty)
                  return Center(child: Text("No attendance records found."));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.all(10),
                      elevation: 1,
                      child: ListTile(
                        title: Text(data['course'] ?? ''),
                        
                        // leading: Text(data['course'] ?? ''),
subtitle: Column(
  
  
  mainAxisAlignment: MainAxisAlignment.start,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Text(" IN-Time   : ${ formatDateTime(data['inTime'])} - ${formatTime(data['inTime'])}",
  
  style: TextStyle(
                                            fontSize: 12,
                                            fontWeight:
                                                FontWeight.w200,
                                          ),
  
  
  ),
   Text("Out-Time : ${formatDateTime(data['outTime'])} - ${formatTime(data['outTime'])}", style: TextStyle(
                                            fontSize: 12,
                                            fontWeight:
                                                FontWeight.w200,
                                          ),)
],),
                        // leading: Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Column(
                        //       children: [
                        //         Row(
                        //           mainAxisAlignment:
                        //               MainAxisAlignment.spaceEvenly,
                        //           children: [
                        //             Text(
                        //               " IN ",
                        //               style: TextStyle(
                        //                 fontSize: 14,
                        //                 fontWeight: FontWeight.w500,
                        //               ),
                        //             ),
                        //             SizedBox(width: 10),
                        //             Column(
                        //               mainAxisAlignment:
                        //                   MainAxisAlignment.start,
                        //               crossAxisAlignment:
                        //                   CrossAxisAlignment.start,
                        //               children: [
                        //                 Text(
                        //                   '${formatDateTime(data['inTime'])}',
                        //                   style: TextStyle(
                        //                     fontSize: 13,
                        //                     fontWeight:
                        //                         FontWeight.bold,
                        //                   ),
                        //                 ),
                        //                 Text(
                        //                   '${formatTime(data['inTime'])}',
                        //                   style: TextStyle(
                        //                     fontSize: 12,
                        //                     fontWeight:
                        //                         FontWeight.bold,
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                   
                        //             Container(
                        //               padding: EdgeInsets.all(8),
                        //               decoration: BoxDecoration(
                        //                 borderRadius: BorderRadius.circular(10),
                        //                 color:
                        //                     (Theme.of(context).brightness ==
                        //                         Brightness.dark
                        //                     ? primaryColor
                        //                     : primaryColor.withOpacity(0.3)),
                        //                 boxShadow: [],
                        //               ),
                        //               child: Column(
                        //                 crossAxisAlignment:
                        //                     CrossAxisAlignment.center,
                        //                 children: [
                        //                   Row(
                        //                     mainAxisAlignment:
                        //                         MainAxisAlignment.spaceBetween,
                        //                     children: [
                        //                       Text(
                        //                         "OUT",
                        //                         style: TextStyle(
                        //                           fontSize: 14,

                        //                           fontWeight: FontWeight.w500,
                        //                         ),
                        //                       ),
                        //                       SizedBox(width: 15),
                        //                       Column(
                        //                         mainAxisAlignment:
                        //                             MainAxisAlignment.start,
                        //                         crossAxisAlignment:
                        //                             CrossAxisAlignment.start,
                        //                         children: [
                        //                           Text(
                        //                             '${formatDateTime(data['outTime'])}',
                        //                             style: TextStyle(
                        //                               fontSize: 13,
                        //                               fontWeight:
                        //                                   FontWeight.bold,
                        //                             ),
                        //                           ),
                        //                           Text(
                        //                             '${formatTime(data['outTime'])}',
                        //                             style: TextStyle(
                        //                               fontSize: 12,
                        //                               fontWeight:
                        //                                   FontWeight.bold,
                        //                             ),
                        //                           ),
                        //                         ],
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ],
                        //     ),
                        //   ],
                        // ),
                      ),
                    );
                  },
                );
              },
            ),
            isLoading
                ? Center(child:loadingWidget())
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TableCalendar(
                          firstDay: DateTime.utc(2023, 1, 1),
                          lastDay: DateTime.now().add(Duration(days: 30)),
                          focusedDay: DateTime.now(),
                          calendarFormat: CalendarFormat.month,
                          calendarStyle: CalendarStyle(
                            isTodayHighlighted: true,
                            markersAlignment: Alignment.bottomCenter,
                          ),
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, day, events) {
                              final today = DateTime.now();
                              final dayOnly = DateTime(
                                day.year,
                                day.month,
                                day.day,
                              );
                              final isPast = dayOnly.isBefore(
                                DateTime(today.year, today.month, today.day),
                              );

                              if (attendanceMap.containsKey(dayOnly) &&
                                  attendanceMap[dayOnly] == true) {
                                // Present (green dot)
                                return Align(
                                  alignment: Alignment.bottomRight,
                                  child: _buildDot(Colors.green),
                                );
                              } else if (isPast &&
                                  !attendanceMap.containsKey(dayOnly)) {
                                // Absent (red dot)
                                return Align(
                                  alignment: Alignment.bottomRight,
                                  child: _buildDot(Colors.red),
                                );
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      margin: EdgeInsets.only(right: 3, bottom: 3),
      width: 8,
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
