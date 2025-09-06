

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tekort/Providers/batchprovider.dart';
import 'package:tekort/Providers/courseprovider.dart';
import 'package:tekort/Providers/employeeprovider.dart';
import 'package:tekort/Providers/notchprovider.dart';
import 'package:tekort/core/core/utils/styles.dart';

class AddCourseScreen extends StatefulWidget {
  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardController;
  late AnimationController _floatingController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _floatingAnimation;


  ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EmployeeProvider>(context, listen: false);
      if (provider.name == null ||
          provider.email == null ||
          provider.customId == null) {
        provider.fetchEmployeeDetails();
      provider.  fetchAllUsers();
      }
    });
    _headerController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutExpo,
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    );
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(_floatingController);

    _scrollController.addListener(() {
      setState(() {
        _isScrolled = _scrollController.offset > 50;
      });
    });

    Future.microtask(() {
      Provider.of<CourseProvider>(context, listen: false).fetchCourses();
      Provider.of<BatchProvider>(context, listen: false).fetchBatches();
      
      _headerController.forward();
      Future.delayed(Duration(milliseconds: 300), () {
        _cardController.forward();
      });
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardController.dispose();
    _floatingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: CustomScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Consumer2<CourseProvider, BatchProvider>(
              builder: (context, courseProvider, batchProvider, _) {
                final courses = courseProvider.courses;
                final batches = batchProvider.batches;
                
                return Column(
                  children: [
                    _buildStatsOverview(),
                    _buildQuickActions(),
                    _buildCoursesSection(courses),
                    _buildTasksSection(),
                                   _buildBatchesSection(batches),
                    SizedBox(height: 100),

            
                  ],
                );
              },
            ),
          ),
        ],
      ),
     
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      centerTitle: true,
    title:   Image.asset("assets/images/TEKORT LOGO.png", height: 90),
             
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: _isScrolled ? primaryColor : primaryColor,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: _headerAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(1),
                    Color(0xFF00BFA5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Animated background pattern
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Transform.scale(
                      scale: _headerAnimation.value,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: -30,
                    child: Transform.scale(
                      scale: _headerAnimation.value * 0.7,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Consumer<EmployeeProvider>
                  (
                    builder: (context ,provider,child) {
                      return SafeArea(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(-1, 0),
                                      end: Offset.zero,
                                    ).animate(_headerAnimation),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 25,),
                                        Text(
                                          'Hi!',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white.withOpacity(0.9),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        
                                        Text(
                                          '${provider.name}',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                         color: Colors.white.withOpacity(0.9),
                                            
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(1, 0),
                                      end: Offset.zero,
                                    ).animate(_headerAnimation),
                                    child: Stack(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.notifications_outlined,
                                         
                                            size: 24,
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFF6B6B),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              FadeTransition(
                                opacity: _headerAnimation,
                                child: Text(
                                  'Manage your educational ecosystem',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Consumer3<EmployeeProvider,BatchProvider,CourseProvider>(
      builder: (context,empprovider, batchpro,coursepro, child) {
        return AnimatedBuilder(
          animation: _cardAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _cardAnimation.value)),
              child: Opacity(
               opacity: _cardAnimation.value.clamp(0.0, 1.0),
        
                child: Container(
                  margin: EdgeInsets.fromLTRB(20, 30, 20, 20),
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                  // color: Theme.of(context).brightness==Brightness.dark?Color.fromARGB(255, 0, 0, 0):backgroundcolor,
                    color:Theme.of(context).brightness==Brightness.dark?const Color.fromARGB(255, 44, 43, 43).withOpacity(1): Colors.white.withOpacity(1),
                     
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 40,
                        offset: Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: primaryColor,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Overview',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Live',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                     SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(

    children: [
      _buildStatCard(
        '${empprovider.totalCount}',
        'Total Students',
        Icons.people_outline,
        Color(0xFF667EEA),
        0,
      ),
  
      _buildStatCard(
        '${coursepro.totalCourseCount}',
        'Active Courses',
        Icons.school_outlined,
        Color(0xFFFF6B6B),
        1,
      ),
      _buildStatCard(
        '${batchpro.totalBatchCount}',
        'Total Batches',
        Icons.group_work_outlined,
        Color(0xFFFFB74D),
        2,
      ),
    ],
  ),
)

                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    );
  }
Widget _buildStatCard(String value, String label, IconData icon, Color color, int index) {
  return TweenAnimationBuilder<double>(
    duration: Duration(milliseconds: 800 + (index * 200)),
    tween: Tween(begin: 0.0, end: 1.0),
    builder: (context, animation, child) {
      return Transform.scale(
        scale: 0.8 + (0.2 * animation),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Container(
            height: MediaQuery.of(context).size.height *0.15,
            width: MediaQuery.of(context).size.width *0.25,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


  Widget _buildQuickActions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildActionButton('Add Course', Icons.add_box, 0)),
              SizedBox(width: 12),
              Expanded(child: _buildActionButton('New Batch', Icons.group_add, 1)),
              SizedBox(width: 12),
              Expanded(child: _buildActionButton('Analytics', Icons.analytics, 2)),
            ],
          ),
        ],
      ),
    );
  }

Widget _buildActionButton(String title, IconData icon, int targetIndex) {
  return Consumer<BottomNavProvider>(
    builder: (context, navProvider, _) {
      return GestureDetector(
        onTap: () {
            Provider.of<BottomNavProvider>(context, listen: false).changeTab(2);
          navProvider.changeTab(2);
        },
        child: TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (targetIndex * 150)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, animation, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - animation)),
              child: Opacity(
                opacity: animation.clamp(0.0, 1.0),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.8),
                        primaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(icon, color: Colors.white, size: 24),
                      SizedBox(height: 8),
                      Text(
                        title,
                        style: TextStyle(
                       
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
  Widget _buildTasksSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        margin: EdgeInsets.only(top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:Theme.of(context).brightness==Brightness.dark?backgroundcolor.withOpacity(0.3): primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.task_alt,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Recent Tasks',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                 
                    ),
                  ),
                  Spacer(),
                 TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AllTasksScreen()),
    );
  },
  child: Text(
    'View All',
    style: TextStyle(
      color: primaryColor,
      fontWeight: FontWeight.w600,
    ),
  ),
),

                ],
              ),
            ),
            SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tasks')
                  .orderBy('createdAt', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
               
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState('No tasks found', Icons.task_alt);
                }
      
                final tasks = snapshot.data!.docs;
                return Container(
                  // color: primaryColor,
                  height: 240,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                      itemCount: tasks.length,
                      separatorBuilder: (context, index) => SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        return _buildModernTaskCard(tasks[index], index);
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

Widget _buildModernTaskCard(QueryDocumentSnapshot task, int index) {
  final taskName = task['taskName'] ?? '';
  final Map<String, dynamic> studentMap =
      Map<String, dynamic>.from(task['studentMap'] ?? {});

  int pendingCount = 0;
  int completedCount = 0;

  studentMap.forEach((key, value) {
    final status = value['status'] ?? 'Pending';
    if (status == 'Completed') {
      completedCount++;
    } else {
      pendingCount++;
    }
  });

  final total = pendingCount + completedCount;
  final progress = total > 0 ? completedCount / total : 0.0;
  final isHighProgress = progress > 0.7;

  final brightness = Theme.of(context).brightness;
  final bool isDark = brightness == Brightness.dark;

  // 🎨 Theme-based colors
  final cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
  final textColor = isDark ? Colors.white : Color(0xFF1A1A1A);
  final shadowColor = isDark ? Colors.black12 : Colors.black.withOpacity(0.05);
  final borderColor = isHighProgress
      ? primaryColor.withOpacity(0.3)
      : isDark
          ? Colors.grey.withOpacity(0.2)
          : Colors.grey.withOpacity(0.1);

  return TweenAnimationBuilder<double>(
    duration: Duration(milliseconds: 600 + (index * 100)),
    tween: Tween(begin: 0.0, end: 1.0),
    builder: (context, animation, child) {
      return Transform.translate(
        offset: Offset(50 * (1 - animation), 0),
        child: Opacity(
          opacity: animation.clamp(0.0, 1.0),
          child: Material(
            shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.all(Radius.circular(20))),
            elevation: 2,
            child: Container(
              width: 280,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isHighProgress
                              ? primaryColor.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isHighProgress
                              ? Icons.check_circle_outline
                              : Icons.pending_actions,
                          color:
                              isHighProgress ? primaryColor : Colors.orange,
                          size: 30,
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isHighProgress
                              ? primaryColor.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            color: isHighProgress
                                ? primaryColor
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    taskName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  buildProgressBar(completedCount, pendingCount),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: primaryColor, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '$completedCount Done',
                        style: TextStyle(
                          fontSize: 14,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.access_time,
                          color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '$pendingCount Pending',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
Widget buildProgressBar(int completedCount, int pendingCount) {
  final total = completedCount + pendingCount;

  if (total == 0) {
    return SizedBox(height: 4); // avoid division by zero and keep layout consistent
  }

  final progress = completedCount / total;

  // Show progress bar only if there's some progress
  if (progress > 0) {
    return LinearProgressIndicator(
      value: progress,
      backgroundColor: Colors.grey[300],
      color:primaryColor,
      minHeight: 4,
    );
  } else {
   return LinearProgressIndicator(
      value: progress,
      backgroundColor: Colors.grey[300],
      color:primaryColor,
      minHeight: 4,
    ); // Keep height consistent
  }
}

  Widget _buildCoursesSection(List<dynamic> courses) {
    return Container(
      margin: EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.school,
                    color: Color(0xFF667EEA),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Popular Courses',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                 
                  ),
                ),
                Spacer(),
               TextButton(
  onPressed: () {
    print("coursescoursescoursescourses$courses");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllCoursesScreen(courses: courses),
      ),
    );
  },
  child: Text(
    'ViewAll',
    style: TextStyle(
      color: Color(0xFF667EEA),
      fontWeight: FontWeight.w600,
    ),
  ),
),

              ],
            ),
          ),
          SizedBox(height: 16),
          courses.isEmpty
              ? _buildEmptyState('No courses available', Icons.school)
              : Container(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: courses.length,
                    separatorBuilder: (context, index) => SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return _buildModernCourseCard(courses[index], index);
                    },
                  ),
                ),
        ],
      ),
    );
  }
Widget _buildModernCourseCard(dynamic course, int index) {
  final colors = [
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
    [Color(0xFFFFB74D), Color(0xFFFF8A65)],
    [primaryColor, Color(0xFF00BFA5)],
  ];
  final cardColors = colors[index % colors.length];


  return TweenAnimationBuilder<double>(
    duration: Duration(milliseconds: 700 + (index * 100)),
    tween: Tween(begin: 0.0, end: 1.0),
    builder: (context, animation, child) {
      final screenHeight = MediaQuery.of(context).size.height;
      final cardHeight = screenHeight * 0.3;

      return Transform.scale(
        scale: 0.8 + (0.2 * animation),
        child: Opacity(
          opacity: animation.clamp(0.0, 1.0),
          child: Container(
            height: cardHeight,
            width: 200,
            decoration: BoxDecoration(
                color:Theme.of(context).brightness==Brightness.dark?const Color.fromARGB(255, 240, 234, 234): primaryColor.withOpacity(0.1),
                gradient: LinearGradient(
                  colors:Theme.of(context).brightness==Brightness.dark?[
                    backgroundcolor.withOpacity(0.2),
                   backgroundcolor.withOpacity(0.2),
                  ]: cardColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                             ),
            child: Column(
              children: [
                // 60% - Image section
                Expanded(
                  flex: 7,
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        _getCourseImage(course.title),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),

                // 40% - Text/info section
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 0),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? primaryColor
                                    : backgroundcolor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.people, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${course.studentCount}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                course.duration,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildBatchesSection(List<dynamic> batches) {
    print("batchesbatchesbatchesbatches$batches");
    return Container(
      margin: EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:Theme.of(context).brightness==Brightness.dark?backgroundcolor.withOpacity(0.3): primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.groups,
                    color:primaryColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Student Batches',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                 
                  ),
                ),
                Spacer(),
               TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllBatchesScreen(batches: batches),
      ),
    );
  },
  child: Text(
    'viewAll',
    style: TextStyle(
      color: primaryColor,
      fontWeight: FontWeight.w600,
    ),
  ),
),

              ],
            ),
          ),
          SizedBox(height: 16),
          batches.isEmpty
              ? _buildEmptyState('No batches available', Icons.groups)
              : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20)
                ),
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: batches.length,
                    separatorBuilder: (context, index) => SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return _buildModernBatchCard(batches[index], index);
                    },
                  ),
                ),
        ],
      ),
    );
  }
Widget _buildModernBatchCard(dynamic batch, int index) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  // Rotating base colors for batch cards
  final batchColors = [
   
    primaryColor,
  ];
  final cardColor = batchColors[index % batchColors.length];

  // Theme-based colors
  final backgroundColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
  final textColor = isDark ? Colors.white : Color(0xFF1A1A1A);
  final borderColor = cardColor.withOpacity(isDark ? 0.3 : 0.2);
  final shadowColor = cardColor.withOpacity(isDark ? 0.15 : 0.1);
  final iconBgGradient = [
    cardColor.withOpacity(0.8),
    cardColor,
  ];

  return TweenAnimationBuilder<double>(
    duration: Duration(milliseconds: 500 + (index * 100)),
    tween: Tween(begin: 0.0, end: 1.0),
    builder: (context, animation, child) {
      return Transform.translate(
        offset: Offset(30 * (1 - animation), 0),
        child: Opacity(
          opacity: animation.clamp(0.0, 1.0),
          child: Container(
            width: 160,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
              boxShadow: [
                
              ],
            ),
            child: Stack(
              children: [
                // Decorative Circle Background
                Positioned(
                  top: -10,
                  right: -10,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cardColor.withOpacity(0.1),
                    ),
                  ),
                ),
                 Positioned(
                  bottom: -10,
                  left: -10,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cardColor.withOpacity(0.1),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Box
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: iconBgGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.groups,
                         
                            size: 30,
                          ),
                        ),
                        SizedBox(height: 5),
                        // Batch Code
                        Text(
                          batch.batchCode ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                                            Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${batch.studentCount ?? 0}',
                            style: TextStyle(
                              fontSize: 12,
                           
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      height: 200,
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to add new items',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
    }

    class CourseDetailScreen extends StatelessWidget {
  final dynamic course;

  const CourseDetailScreen({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/images/Frame 44.png'),
            ),
            SizedBox(height: 16),
            Text(
              course.title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Duration: ${course.duration}'),
            SizedBox(height: 8),
            Text('${course.studentCount} students enrolled'),
            // Add more info if needed...
          ],
        ),
      ),
    );
  }
}






class AllCoursesScreen extends StatefulWidget {
  final List<dynamic> courses;
  
  const AllCoursesScreen({Key? key, required this.courses}) : super(key: key);
  
  @override
  _AllCoursesScreenState createState() => _AllCoursesScreenState();
}

class _AllCoursesScreenState extends State<AllCoursesScreen>
    with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late AnimationController _fabAnimationController;
  List<bool> _isExpanded = [];
  
  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _isExpanded = List.generate(widget.courses.length, (index) => false);
    _startAnimation();
  }
  
  void _startAnimation() {
    _listAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _fabAnimationController.forward();
    });
  }
  
  @override
  void dispose() {
    _listAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }
  

  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
   
      appBar: AppBar(
        title: const Text(
          "All Courses",
          style: TextStyle(
        
            fontSize: 24,
          ),
        ),
       

        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
           
            height: 1,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _listAnimationController,
        builder: (context, child) {
          return ListView.builder(
            // padding: const EdgeInsets.all(16),
            itemCount: widget.courses.length,
            itemBuilder: (context, index) {
              final course = widget.courses[index];
              final animation = Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: _listAnimationController,
                  curve: Interval(
                    (index * 0.1).clamp(0.0, 1.0),
                    ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                    curve: Curves.easeOutCubic,
                  ),
                ),
              );
              
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - animation.value)),
                    child: Opacity(
                      opacity: animation.value,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Container(
                            
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                                
                              ),
                            // margin: const EdgeInsets.only(bottom: 16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                
                              ),
                              child: ExpansionTile(
                                shape: Border.all(style: BorderStyle.none),
                                // tilePadding: const EdgeInsets.all(20),
                                childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                onExpansionChanged: (expanded) {
                                  setState(() {
                                    _isExpanded[index] = expanded;
                                  });
                                },

                                leading:Container(
                                  
                                  width: 100,
                                      height: 100,                        
                                  decoration: BoxDecoration(
                                    image: DecorationImage(image: AssetImage( _getCourseImage(course.title),)),
                                    borderRadius: BorderRadius.circular(15),
                             
                                   
                                  ),
                                
                                ),
                                title: Text(
                                  course.title.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                 
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: primaryColor
                                          ),
                                        ),
                                        child: Text(
                                          course.subtitle,
                                          style: TextStyle(
                                           
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: AnimatedRotation(
                                  turns: _isExpanded[index] ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                     
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                    
                                      size: 24,
                                    ),
                                  ),
                                ),
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                    color:Theme.of(context).brightness==Brightness.dark?backgroundcolor.withOpacity(0.3): primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(15),
                                     
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildDetailCard(
                                                icon: Icons.access_time,
                                                title: "Duration",
                                                value: "${course.duration} months",
                                              
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildDetailCard(
                                                icon: Icons.people,
                                                title: "Students",
                                                value: "${course.studentCount}",
                                              
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                       color:Theme.of(context).brightness==Brightness.dark? primaryColor.withOpacity(0.3): backgroundcolor,
                                            borderRadius: BorderRadius.circular(12),
                                          
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.description,
                                                  
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    "Course Description",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                             SizedBox(height: 10),
                                                if (course?.description == null || course!.description.isEmpty)
                                                  Text(
                                                    "N/A",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                      height: 1.5,
                                                    ),
                                                  )
                                                else
                                                  ...course!.description.split('/').map(
                                                    (point) => _buildLearningPoint(point.trim()),
                                                  ),
                                            ],
                                          ),
                                        ),
                                       
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
   
    );
  }
  
  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
     color:Theme.of(context).brightness==Brightness.dark? primaryColor.withOpacity(0.3): backgroundcolor,
        borderRadius: BorderRadius.circular(10),
      
      ),
      child: Column(
        children: [
          Icon(icon,  size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
             
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            
            ),
          ),
        ],
      ),
    );
  }
}

class AllTasksScreen extends StatefulWidget {
  @override
  _AllTasksScreenState createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen>
    with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  List<bool> _isExpanded = [];

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Tasks")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No tasks found"));
          }

          final tasks = snapshot.data!.docs;
          _isExpanded = List.generate(tasks.length, (index) => false);

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              print(task);
              final String taskName = task['taskName'] ?? 'Untitled Task';
              final Map<String, dynamic> studentMap =
                  Map<String, dynamic>.from(task['studentMap'] ?? {});
print(studentMap);
              int completed = 0;
              int pending = 0;
              studentMap.forEach((key, value) {
                final status = value['status'] ?? 'Pending';
                if (status == 'Completed') {
                  completed++;
                } else {
                  pending++;
                }
              });

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: ExpansionTile(
                    shape: Border.all(style: BorderStyle.none),
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _isExpanded[index] = expanded;
                      });
                    },
                    leading: CircleAvatar(
                      backgroundColor:primaryColor.withOpacity(0.3),
                      child: const Icon(Icons.task, color: primaryColor),
                    ),
                    title: Text(
                      taskName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      "Completed: $completed / ${completed + pending}",
                      style: TextStyle(
                          color: completed == (completed + pending)
                              ? Colors.green
                              : Colors.orange),
                    ),
                    trailing: AnimatedRotation(
                      turns: _isExpanded[index] ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: studentMap.entries.map((entry) {
                            final student = entry.value;
                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(student['studentname'] ?? 'Unknown'),
                              trailing: Text(
                                student['status'] ?? 'Pending',
                                style: TextStyle(
                                  color: (student['status'] ?? 'Pending') ==
                                          'Completed'
                                      ?primaryColor
                                      : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


  String _getCourseImage(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('webtech')) return 'assets/images/uiux.png';
    if (lowerTitle.contains('uiux')) return 'assets/images/uiux.png';
    if (lowerTitle.contains('flutter')) return 'assets/images/dm.png';
    if (lowerTitle.contains('flutter')) return 'assets/images/Frame 44.png';
    return 'assets/images/Frame 44.png'; // fallback image
  }



Widget _buildLearningPoint(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Text(text, style: TextStyle(fontSize: 14, height: 1.4)),
  );
}


class AllBatchesScreen extends StatelessWidget {
  final List<dynamic> batches;

  const AllBatchesScreen({Key? key, required this.batches}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Batches"),
      ),
      body: batches.isEmpty
          ? Center(
              child: Text(
                "No batches available",
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: batches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildFullBatchCard(context, batches[index], index);
              },
            ),
    );
  }

  Widget _buildFullBatchCard(BuildContext context, dynamic batch, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final batchColors = [primaryColor];
    final cardColor = batchColors[index % batchColors.length];

    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final borderColor = cardColor.withOpacity(isDark ? 0.3 : 0.2);
    final iconBgGradient = [
      cardColor.withOpacity(0.8),
      cardColor,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: iconBgGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.groups, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),

          // Batch Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch.batchCode ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Students: ${batch.studentCount ?? 0}",
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Start Date: ${batch.startDate ?? 'N/A'}",
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
                Text(
                  "End Date: ${batch.endDate ?? 'N/A'}",
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
