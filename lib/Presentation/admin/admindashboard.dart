import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tekort/Models/coursemodel.dart';
import 'package:tekort/Presentation/admin/adminattrecord.dart';
import 'package:tekort/Presentation/admin/adminsettings.dart';
import 'package:tekort/Presentation/profile.dart';
import 'package:tekort/Providers/courseprovider.dart';
import 'package:tekort/Providers/notchprovider.dart';
import 'package:tekort/Presentation/admin/adminhomepage.dart';
import 'package:tekort/core/core/themes/themeprovider/themeprovider.dart';
import 'package:tekort/core/core/utils/styles.dart';
   

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _pageController = PageController(initialPage: 0);
  final NotchBottomBarController _controller = NotchBottomBarController(
    index: 0,
  );
  int maxCount = 5;
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // For opening drawer
  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }


  @override
void initState() {
  super.initState();
  _controller.addListener(() {
    final index = _controller.index;
    final provider = Provider.of<BottomNavProvider>(context, listen: false);
    if (provider.currentIndex != index) {
      provider.changeTab(index);
    }
  });
}


@override
Widget build(BuildContext context) {
  final List<Widget> bottomBarPages = [
    AddCourseScreen(),
    const AdminAttendanceScreen(),
    MainScreen(),
    const AccountScreen(),
  ];

  return Consumer<BottomNavProvider>(
    builder: (context, navProvider, _) {
      // If the page controller is not on the right page, jump to it
if (_pageController.hasClients && _pageController.page?.round() != navProvider.currentIndex) {
  _pageController.animateToPage(
    navProvider.currentIndex,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
  _controller.jumpTo(navProvider.currentIndex); // Optional: this is visual only
}

      return SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: bottomBarPages,
          ),
          extendBody: true,
          bottomNavigationBar: (bottomBarPages.length <= maxCount)
              ? Consumer<ThemeSwitch>(
                  builder: (context, provider, child) {
                    return AnimatedNotchBottomBar(
                      notchBottomBarController: _controller,
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? const Color.fromARGB(255, 46, 46, 46)
                          : const Color.fromARGB(255, 230, 228, 228)),
                      showLabel: true,
                      notchColor: Color.fromRGBO(4, 168, 136, 1),
                      itemLabelStyle: const TextStyle(fontSize: 10),
                      bottomBarItems: [
                        BottomBarItem(
                          inActiveItem: ImageIcon(AssetImage("assets/images/home.png")),
                          activeItem: ImageIcon(AssetImage("assets/images/home.png"), color: backgroundcolor),
                        ),
                        BottomBarItem(
                          inActiveItem: ImageIcon(AssetImage("assets/images/event.png")),
                          activeItem: ImageIcon(AssetImage("assets/images/event.png"), color: Colors.white),
                        ),
                        BottomBarItem(
                          inActiveItem: Icon(Icons.settings_outlined),
                          activeItem: Icon(Icons.settings_outlined, color: Colors.white),
                        ),
                        BottomBarItem(
                          inActiveItem: Icon(Icons.person_2_outlined),
                          activeItem: Icon(Icons.person_2_outlined, color: Colors.white),
                        ),
                      ],
                      onTap: (index) {
                        Provider.of<BottomNavProvider>(context, listen: false).changeTab(index);
                      }, kIconSize: 24.0, kBottomRadius: 28.0,
                    );
                  },
                )
              : null,
        ),
      );
    },
  );
}

}




class CourseListScreen extends StatefulWidget {
  const CourseListScreen({Key? key}) : super(key: key);
  
  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen>
    with TickerProviderStateMixin {
  String searchQuery = '';
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Your primary color
  static const Color primaryColor = Color(0xFF04A888);
  
  // Theme colors
  Color get backgroundColor => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF121212)
      : Colors.white;
  
  Color get cardColor => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1E1E1E)
      : Colors.white;
  
  Color get surfaceColor => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF2C2C2C)
      : const Color(0xFFF0F9F7);

  @override
  void initState() {
    super.initState();
    _initAnimations();
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
    _scaleController = AnimationController(
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
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _openBottomSheet(BuildContext context, {CourseModel? courseToEdit}) {
    final _formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(
      text: courseToEdit?.title ?? '',
    );
    final subtitleController = TextEditingController(
      text: courseToEdit?.subtitle ?? '',
    );
    final durationController = TextEditingController(
      text: courseToEdit?.duration ?? '',
    );
    final descriptionController = TextEditingController(
      text: "This course teaches you how to build real Android and iOS apps using Flutter and Dart. You'll move from basic UI creation to backend integration, working on actual client-level mobile projects. Guided by industry professionals, every session is practical and career-focused. By the end, you’ll have real apps in your portfolio, ready to showcase your skills./Course Syllabus/Introduction to Dart Programming/Flutter Basics and Widgets/State Management/UI Design and Animations/API Integration and Data Handling/Firebase Integration/App Publishing and Deployment/" ?? '',
    );

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Header with icon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, primaryColor.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          courseToEdit == null ? Icons.add : Icons.edit,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        courseToEdit == null ? 'Add New Course' : 'Edit Course',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Form fields
                  _buildFormField(
                    controller: titleController,
                    label: 'Course Title',
                    icon: Icons.book_outlined,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter course title'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  
                  _buildFormField(
                    controller: subtitleController,
                    label: 'Subtitle',
                    icon: Icons.subtitles_outlined,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter subtitle'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  
                  _buildFormField(
                    controller: durationController,
                    label: 'Duration',
                    icon: Icons.schedule_outlined,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter duration'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  
                  _buildFormField(
                    controller: descriptionController,
                    label: 'Description',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter description'
                        : null,
                  ),
                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      if (courseToEdit != null) ...[
                        Expanded(
                          child: _buildActionButton(
                            label: 'Delete',
                            icon: Icons.delete_outline,
                            color: Colors.red,
                            onPressed: () {
                              _showDeleteConfirmation(context, courseToEdit);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        flex: 2,
                        child: _buildActionButton(
                          label: courseToEdit == null ? 'Add Course' : 'Update Course',
                          icon: courseToEdit == null ? Icons.add : Icons.update,
                          color: primaryColor,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final newCourse = CourseModel(
                                id: courseToEdit?.id ?? '',
                                title: titleController.text,
                                subtitle: subtitleController.text,
                                duration: durationController.text,
                                description: descriptionController.text,
                              );
                              final provider = Provider.of<CourseProvider>(
                                context,
                                listen: false,
                              );
                              if (courseToEdit == null) {
                                provider.addCourse(newCourse);
                              } else {
                                provider.updateCourse(newCourse);
                              }
                              Navigator.pop(context);
                              _showSuccessSnackbar(
                                context,
                                courseToEdit == null ? 'Course added successfully!' : 'Course updated successfully!',
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        labelStyle: TextStyle(color: primaryColor),
      
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: color.withOpacity(0.4),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CourseModel course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Delete Course'),
          ],
        ),
        content: Text('Are you sure you want to delete "${course.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<CourseProvider>(context, listen: false)
                  .deleteCourse(course.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              _showSuccessSnackbar(context, 'Course deleted successfully!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        final filteredCourses = provider.courses.where((course) {
          final query = searchQuery.toLowerCase();
          return course.title.toLowerCase().contains(query) ||
              course.subtitle.toLowerCase().contains(query) ||
              course.duration.toLowerCase().contains(query) ||
              course.description.toLowerCase().contains(query);
        }).toList();

        return SafeArea(
          child: Scaffold(
            backgroundColor: backgroundColor,
            // appBar: _buildAppBar(),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: filteredCourses.isEmpty
                    ? _buildEmptyState()
                    : Column(
                        children: [
                          _buildSearchBar(),
                          _buildCourseStats(filteredCourses.length, provider.courses.length),
                          Expanded(
                            child: _buildCourseList(filteredCourses),
                          ),
                        ],
                      ),
              ),
            ),
            floatingActionButton: ScaleTransition(
              scale: _scaleAnimation,
              child:  FloatingActionButton(
              onPressed: () => _openBottomSheet(context),
              child: const Icon(Icons.add),
            ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search courses...',
          prefixIcon: Icon(Icons.search, color: primaryColor),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () => setState(() => searchQuery = ''),
                  icon: Icon(Icons.clear, color: primaryColor.withOpacity(0.7)),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          hintStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseStats(int filteredCount, int totalCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor.withOpacity(0.1), primaryColor.withOpacity(0.05)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Showing $filteredCount of $totalCount courses',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Filtered',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCourseList(List<CourseModel> courses) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildCourseCard(course, index),
        );
      },
    );
  }

  Widget _buildCourseCard(CourseModel course, int index) {
    final colors = [
      primaryColor,
      primaryColor.withOpacity(0.8),
      primaryColor.withOpacity(0.6),
      primaryColor.withOpacity(0.9),
    ];
    final gradientColor = colors[index % colors.length];

    return Material(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            // BoxShadow(
            //   color: gradientColor.withOpacity(0.15),
            //   blurRadius: 15,
            //   offset: const Offset(0, 8),
            // ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              // Navigate to course details
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [gradientColor, gradientColor.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.book_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              course.subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _openBottomSheet(context, courseToEdit: course),
                        icon: Icon(Icons.edit_outlined, color: gradientColor),
                        style: IconButton.styleFrom(
                          backgroundColor: gradientColor.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_outlined,
                              size: 16,
                              color: gradientColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              course.duration,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: gradientColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          course.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor.withOpacity(0.1), primaryColor.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_outlined,
              size: 80,
              color: primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            searchQuery.isNotEmpty ? 'No courses found' : 'No courses yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color?.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            searchQuery.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'Create your first course to get started',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (searchQuery.isEmpty)
            ElevatedButton.icon(
              onPressed: () => _openBottomSheet(context),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Your First Course',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.4),
              ),
            ),
        ],
      ),
    );
  }
}