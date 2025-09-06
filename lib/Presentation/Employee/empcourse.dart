
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tekort/Presentation/Employee/empbatchlist.dart';
import 'package:tekort/Providers/courseprovider.dart';
import 'package:tekort/Providers/employeeprovider.dart';
import 'package:tekort/core/core/common/loading.dart';
import 'package:tekort/core/core/utils/styles.dart';
import 'package:tekort/curosalwidget.dart';
import 'package:tekort/main.dart';

class Employcoursefirst extends StatefulWidget {
  @override
  State<Employcoursefirst> createState() => _EmploycoursefirstState();
}

class _EmploycoursefirstState extends State<Employcoursefirst> {
  int currentTab = 0;
  PageController pageController = PageController();

  final List<String> tabs = ['Course', 'Task', 'Batch'];
  String? name, email, course, customId;
  Set<int> expandedTiles = <int>{}; // Track expanded tiles
 
  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchUserData1();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EmployeeProvider>(context, listen: false);
      provider.fetchEmployeeDetails();
  
    });  }

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
  Future<void> _fetchUserData1() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('batches')
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

  @override
  Widget build(BuildContext context) {
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
        return Consumer<CourseProvider>(
              builder: (context, provider, _) {
                  print("provider.courses${provider.courses}");
                    final filteredCourses = provider.courses
                        .where((course) => course.title == assignedCourseKey)
                        .toList();
                  final List<Widget> pages = [
     Center(
                                child: filteredCourses.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.school_outlined,
                                              size: 60,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'No assigned course found',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        itemCount: filteredCourses.length,
                                        itemBuilder: (context, index) {
                                          final course = filteredCourses[index];
                                          final isExpanded = expandedTiles
                                              .contains(index);

                                          return Card(
                                            margin: EdgeInsets.only(bottom: 12),
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              children: [
                                                ListTile(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 8,
                                                      ),
                                                  leading: CircleAvatar(
                                                    backgroundColor:
                                                        primaryColor,
                                                    child: Icon(Icons.book),
                                                  ),
                                                  title: Text(
                                                    course.title,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    course.subtitle,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  trailing: Icon(
                                                    isExpanded
                                                        ? Icons.expand_less
                                                        : Icons.expand_more,
                                                    color: primaryColor,
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      if (isExpanded) {
                                                        expandedTiles.remove(
                                                          index,
                                                        );
                                                      } else {
                                                        expandedTiles.add(
                                                          index,
                                                        );
                                                      }
                                                    });
                                                  },
                                                ),
                                                AnimatedContainer(
                                                  duration: Duration(
                                                    milliseconds: 3000,
                                                  ),
                                                  curve: Curves.easeInOut,
                                                  height: isExpanded ? null : 0,
                                                  child: isExpanded
                                                      ? Container(
                                                          width:
                                                              double.infinity,
                                                          padding:
                                                              EdgeInsets.all(
                                                                20,
                                                              ),
                                                          decoration: BoxDecoration(
                                                           
                                                            borderRadius:
                                                                BorderRadius.only(
                                                                  bottomLeft:
                                                                      Radius.circular(
                                                                        12,
                                                                      ),
                                                                  bottomRight:
                                                                      Radius.circular(
                                                                        12,
                                                                      ),
                                                                ),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .access_time,

                                                                    size: 20,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Text(
                                                                    'Duration: ${course.duration}',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 16,
                                                              ),
                                                              Text(
                                                                'Course Description:',
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .grey[800],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 8,
                                                              ),
                                                              Text(
                                                                course
                                                                    .description,
                                                                style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .grey[700],
                                                                  height: 1.5,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 16,
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : SizedBox.shrink(),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                              
    Center(
      child: TaskMapScreen()
    ),
    Center(
      child: UserBatchList(uid: currentUser!.uid)
    ),
  ];
                 
            return DefaultTabController(
              length: 3,
              child: Scaffold(
                               body: Consumer<CourseProvider>(
                  builder: (context, provider, _) {
                                     return Column(
                      children: [
                      
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
                            selectedColor: primaryColor,
                            unselectedColor: Colors.grey[600],
                            borderRadius: 50,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
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
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}




class TaskMapScreen extends StatelessWidget {
  const TaskMapScreen({Key? key}) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_bottom;
      case 'completed':
        return Icons.check_circle;
      case 'in progress':
        return Icons.autorenew;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskMap = Provider.of<EmployeeProvider>(context).taskMap;

    if (taskMap == null || taskMap.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No task data available.')),
      );
    }
    return Scaffold(
           body: Padding(
             padding: const EdgeInsets.all(8.0),
             child: ListView(
                     children: [
                       Card(
              child: ListTile(
                            title: Text(taskMap['taskName'] ?? 'No Task Name'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Start Date: ${taskMap['startDate'] ?? ''}'),
                    Text('End Date: ${taskMap['endDate'] ?? ''}'),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getStatusIcon(taskMap['status'] ?? ''),
                      color: _getStatusColor(taskMap['status'] ?? ''),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      taskMap['status'] ?? '',
                      style: TextStyle(
                        color: _getStatusColor(taskMap['status'] ?? ''),
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              ),
                       ),
                     ],
                   ),
           ),
    );
  }
}

