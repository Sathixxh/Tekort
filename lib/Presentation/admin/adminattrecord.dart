

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tekort/core/core/common/loading.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({Key? key}) : super(key: key);
  
  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen>
    with TickerProviderStateMixin {
  Map<DateTime, List<Map<String, dynamic>>> dailyGroupedAttendance = {};
  List<Map<String, dynamic>> allUsers = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool isLoading = true;
  bool isLoadingUsers = true;
  
  // Tab controllers for Present/Absent tabs
  late TabController _attendanceTabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _flipController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _flipAnimation;

  Color get primaryColor => Theme.of(context).brightness == Brightness.dark ? Color(0xFF04A888): Color(0xFF04A888);
  Color get backgroundColor => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF121212)
      : const Color(0xFFFAFAFA);
  Color get cardColor => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1E1E1E)
      : Colors.white;

  @override
  void initState() {
    super.initState();
    _attendanceTabController = TabController(length: 2, vsync: this);
    _initAnimations();
    _initializeData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeData() async {
    await Future.wait([
      fetchAllAttendance(),
      fetchAllUsers(),
    ]);
  }

  @override
  void dispose() {
    _attendanceTabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  Future<void> fetchAllUsers() async {
    try {
      setState(() {
        isLoadingUsers = true;
      });
      
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      
      List<Map<String, dynamic>> users = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['uid'] = doc.id; // Add document ID as uid
        users.add(data);
      }
      
      setState(() {
        allUsers = users;
        isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        isLoadingUsers = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading users: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchAllAttendance() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .orderBy('inTime', descending: true)
          .get();
      
      Map<DateTime, List<Map<String, dynamic>>> tempGrouped = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final inTimestamp = data['inTime'] as Timestamp?;
        final outTimestamp = data['outTime'] as Timestamp?;
        
        if (inTimestamp != null && outTimestamp != null) {
          final date = DateTime(
            inTimestamp.toDate().year,
            inTimestamp.toDate().month,
            inTimestamp.toDate().day,
          );
          tempGrouped[date] = tempGrouped[date] ?? [];
          tempGrouped[date]!.add(data);
        }
      }
      
      setState(() {
        dailyGroupedAttendance = tempGrouped;
        isLoading = false;
      });
      
      _fadeController.forward();
      _slideController.forward();
      _flipController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading attendance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Get absent users for a specific date
  List<Map<String, dynamic>> getAbsentUsers(DateTime date) {
    final selectedDate = DateTime(date.year, date.month, date.day);
    final presentUsers = dailyGroupedAttendance[selectedDate] ?? [];
    
    // Extract emails/names of present users
    final presentEmails = presentUsers.map((user) => user['email']?.toString().toLowerCase()).toSet();
    
    // Find users who are not in the present list
    final absentUsers = allUsers.where((user) {
      final userEmail = user['email']?.toString().toLowerCase();
      return userEmail != null && !presentEmails.contains(userEmail);
    }).toList();
    
    return absentUsers;
  }

  String formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return "N/A";
    return DateFormat('MMM dd, yyyy – hh:mm a').format(timestamp.toDate());
  }

  String formatDateOnly(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
   final selectedAttendance = _selectedDay != null
    ? (dailyGroupedAttendance[DateTime(
            _selectedDay!.year,
            _selectedDay!.month,
            _selectedDay!.day,
          )] as List<Map<String, dynamic>>?) ?? []
    : <Map<String, dynamic>>[];

    final absentUsers = _selectedDay != null ? getAbsentUsers(_selectedDay!) : <Map<String, dynamic>>[];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: _buildAppBar(),
        body: TabBarView(

          children: [
            _buildDailyView(),
            _buildMonthlyView(selectedAttendance, absentUsers),
          ],
        ),
      ),
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
        dividerColor:Colors.white,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        tabs: const [
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

  Widget _buildDailyView() {
    if (isLoading) {
      return Center(
        child: loadingWidget()
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: dailyGroupedAttendance.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: dailyGroupedAttendance.entries.length,
                itemBuilder: (context, index) {
                  final entry = dailyGroupedAttendance.entries.elementAt(index);
                  final date = entry.key;
                  final records = entry.value;
                  final absentCount = getAbsentUsers(date).length;
                  
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 200 + (index * 50)),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: _buildDayCard(date, records, absentCount),
                  );
                },
              ),
      ),
    );
  }

Widget _buildDayCard(DateTime date, List<Map<String, dynamic>> records, int absentCount) {
  final absentUsers = getAbsentUsers(date);

  // final TabController _dayTabController = TabController(length: 2, vsync: ScrollableState());

  return Container(
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.only(bottom: 16),
        leading: Container(
          width: 60,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${records.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Text(
                'Present',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          formatDateOnly(date),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${records.length} Present • ${absentUsers.length} Absent',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Present: ${records.length}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Absent: ${absentUsers.length}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
    
  if (records.isNotEmpty || absentUsers.isNotEmpty)
    DefaultTabController(
      length: 2,
      child: Container(
        height: 300,
        child: Column(
          children: [
            TabBar(
              labelColor: primaryColor,
              unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              indicatorColor: primaryColor,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 18),
                      const SizedBox(width: 8),
                      Text('Present (${records.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cancel_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text('Absent (${absentUsers.length})'),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  records.isEmpty
                      ? _buildNoRecordsMessage('No students were present', Icons.check_circle_outline, Colors.green)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 300 + (index * 100)),
                              curve: Curves.easeOutBack,
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: _buildAttendanceCard(records[index]),
                            );
                          },
                        ),
                  absentUsers.isEmpty
                      ? _buildNoRecordsMessage('All students were present!', Icons.celebration, Colors.green)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: absentUsers.length,
                          itemBuilder: (context, index) {
                            final student = absentUsers[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.red.withOpacity(0.1),
                                    child: Text(
                                      (student['name'] ?? 'N')[0].toUpperCase(),
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student['name'] ?? 'N/A',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      if (student['course'] != null)
                                        Text(
                                          student['course'],
                                          style: TextStyle(
                                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
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


  Widget _buildAttendanceCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  radius: 20,
                  child: Text(
                    (data['name'] ?? 'N')[0].toUpperCase(),
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? 'N/A',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (data['course'] != null && data['course'].isNotEmpty)
                        Text(
                          data['course'],
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.email_outlined, 'Email', data['email'] ?? 'N/A'),
            _buildInfoRow(Icons.login, 'Check In', formatDateTime(data['inTime'])),
            _buildInfoRow(Icons.logout, 'Check Out', formatDateTime(data['outTime'])),
            _buildInfoRow(Icons.schedule, 'Duration', data['duration'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: primaryColor.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyView(List<Map<String, dynamic>> selectedAttendance, List<Map<String, dynamic>> absentUsers) {
    if (isLoading || isLoadingUsers) {
      return Center(
        child:   loadingWidget(),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Calendar Widget
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.now().add(const Duration(days: 30)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                isTodayHighlighted: true,
                todayDecoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                markersAlignment: Alignment.bottomCenter,
                outsideDaysVisible: false,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: primaryColor,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: primaryColor,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  final dayOnly = DateTime(day.year, day.month, day.day);
                  final records = dailyGroupedAttendance[dayOnly];
                  final isPast = dayOnly.isBefore(
                    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                  );

                  if (records != null && records.isNotEmpty) {
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: cardColor, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '${records.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (isPast) {
                    return Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // Attendance Details Container
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header with date and counts
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event, color: primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedDay != null
                              ? formatDateOnly(_selectedDay!)
                              : 'Select a Date',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Present: ${selectedAttendance.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Absent: ${absentUsers.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tab Bar for Present/Absent
                if (_selectedDay != null && (selectedAttendance.isNotEmpty || absentUsers.isNotEmpty))
                  Container(
                    color: cardColor,
                    child: TabBar(
                      controller: _attendanceTabController,
                      labelColor: primaryColor,
                      unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      indicatorColor: primaryColor,
                      indicatorWeight: 3,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 18),
                              SizedBox(width: 8),
                              Text('Present (${selectedAttendance.length})'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cancel_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Absent (${absentUsers.length})'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Tab Content
                if (_selectedDay != null && (selectedAttendance.isNotEmpty || absentUsers.isNotEmpty))
                  Container(
                    height: 400, // Fixed height for the tab content
                    child: TabBarView(
                      controller: _attendanceTabController,
                      children: [
                        // Present Students Tab
                        selectedAttendance.isEmpty
                            ? _buildNoRecordsMessage('No students were present on this day', Icons.check_circle_outline, Colors.green)
                            : _buildAttendanceList(selectedAttendance, true),
                        
                        // Absent Students Tab
                        absentUsers.isEmpty
                            ? _buildNoRecordsMessage('All students were present!', Icons.celebration, Colors.green)
                            : _buildAttendanceList(absentUsers, false),
                      ],
                    ),
                  )
                else
                  _buildNoRecordsForDay(),
                  
              ],
            ),
          ),
              SizedBox(height: 100,)
        ],
      ),
    );
  }

  Widget _buildAttendanceList(List<Map<String, dynamic>> users, bool isPresent) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          child: isPresent 
              ? _buildCompactAttendanceCard(user) 
              : _buildAbsentUserCard(user),
        );
      },
    );
  }

  Widget _buildAbsentUserCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                backgroundColor: Colors.red.withOpacity(0.1),
                radius: 24,
                child: Text(
                  (user['name'] ?? 'N')[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: backgroundColor, width: 2),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'N/A',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (user['course'] != null && user['course'].isNotEmpty)
                  Text(
                    user['course'],
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  user['email'] ?? 'N/A',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ABSENT',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactAttendanceCard(Map<String, dynamic> data) {
    final Timestamp? inTimestamp = data['inTime'];
    final Timestamp? outTimestamp = data['outTime'];
    
    String formattedInTime = 'N/A';
    String formattedOutTime = 'N/A';
    
    if (inTimestamp != null) {
      final DateTime inDateTime = inTimestamp.toDate();
      formattedInTime = DateFormat('hh:mm:ss a').format(inDateTime);
    }
    
    if (outTimestamp != null) {
      final DateTime outDateTime = outTimestamp.toDate();
      formattedOutTime = DateFormat('hh:mm:ss a').format(outDateTime);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                backgroundColor: primaryColor.withOpacity(0.1),
                radius: 24,
                child: Text(
                  (data['name'] ?? 'N')[0].toUpperCase(),
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: backgroundColor, width: 2),
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? 'N/A',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (data['course'] != null && data['course'].isNotEmpty)
                  Text(
                    data['course'],
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.login,
                      size: 12,
                      color: Colors.green,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'In: $formattedInTime',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.logout,
                      size: 12,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Out: $formattedOutTime',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 12,
                      color: primaryColor.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        data['duration'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 11,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoRecordsMessage(String message, IconData icon, Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: color.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color?.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 64,
              color: primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Attendance Records',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color?.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No attendance data available at the moment.',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoRecordsForDay() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy,
                size: 48,
                color: primaryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color?.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a date from the calendar above to view attendance records',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

