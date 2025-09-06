
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tekort/Providers/courseprovider.dart';
import 'package:tekort/core/core/common/loading.dart';

class EmployeesScreen extends StatefulWidget {
  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  
  String _searchQuery = '';
  String _role = 'employee';
  String? _selectedCourse;
  String? _selectedBatch;
  List<String> _batchCodes = [];
  bool _isPasswordVisible = false;
  
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
    _loadBatchCodes();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
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
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBatchCodes() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('batches').get();
      setState(() {
        _batchCodes = snap.docs
            .map((d) => d.data()['batchCode'] as String)
            .toList();
        if (_selectedBatch == null && _batchCodes.isNotEmpty) {
          _selectedBatch = _batchCodes.first;
        }
      });
        _fadeController.forward();
    _slideController.forward();
    } catch (e) {
      _showErrorSnackbar('Error loading batch codes: $e');
    }
  }

  Future<void> _deleteUser(String uid, String batchCode, String courseTitle) async {
    final firestore = FirebaseFirestore.instance;
    try {
      final batch = firestore.batch();
      
      // Delete user from 'users' collection
      final userRef = firestore.collection('users').doc(uid);
      batch.delete(userRef);
      
      // Update batch - decrement studentCount & remove from studentmap
      final batchSnap = await firestore
          .collection('batches')
          .where('batchCode', isEqualTo: batchCode)
          .limit(1)
          .get();
      
      if (batchSnap.docs.isNotEmpty) {
        final batchRef = batchSnap.docs.first.reference;
        batch.update(batchRef, {
          'studentCount': FieldValue.increment(-1),
          'studentmap.$uid': FieldValue.delete(),
        });
      }
      
      // Update course - decrement studentCount
      final courseSnap = await firestore
          .collection('courses')
          .where('title', isEqualTo: courseTitle)
          .limit(1)
          .get();
      
      if (courseSnap.docs.isNotEmpty) {
        final courseRef = courseSnap.docs.first.reference;
        batch.update(courseRef, {'studentCount': FieldValue.increment(-1)});
      }
      
      await batch.commit();
      _showSuccessSnackbar("User deleted successfully");
    } catch (e) {
      _showErrorSnackbar("Error deleting user: $e");
    }
  }

  void _resetControllers() {
    _emailController.clear();
    _passwordController.clear();
    _phoneController.clear();
    _nameController.clear();
    _role = 'employee';
    _selectedCourse = null;
    _selectedBatch = null;
    _isPasswordVisible = false;
  }

  Future<void> _showUserFormBottomSheet(
    BuildContext context, {
    bool isEdit = false,
    String? docId,
    Map<String, dynamic>? userData,
  }) async {
    if (isEdit && userData != null) {
      _emailController.text = userData['email'] ?? '';
      _phoneController.text = userData['phone'] ?? '';
      _nameController.text = userData['name'] ?? '';
      _role = userData['role'] ?? 'employee';
      _selectedCourse = userData['course'];
      _selectedBatch = userData['batch'];
    } else {
      _resetControllers();
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
          child: Consumer<CourseProvider>(
            builder: (context, provider, _) {
              final courseTitles = provider.courses.map((c) => c.title).toList();
              if (!isEdit && (_selectedCourse == null || _selectedCourse!.isEmpty)) {
                _selectedCourse = courseTitles.isNotEmpty ? courseTitles.first : null;
              }
              
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
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
                              isEdit ? Icons.edit : Icons.person_add,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              isEdit ? 'Edit Employee' : 'Add New Employee',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Form fields
                      _buildFormField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        validator: (value) => value!.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildFormField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email is required';
                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      if (!isEdit)
                        Column(
                          children: [
                            _buildPasswordField(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      
                      _buildFormField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Phone is required';
                          if (!RegExp(r'^\d{10,}$').hasMatch(value)) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                     DropdownButtonFormField<String>(
                      value: _role,
                      decoration: InputDecoration(labelText: 'Role'),
                      items: ['admin', 'employee', 'staff']
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _role = val!),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedBatch,
                      decoration: InputDecoration(labelText: 'Batch'),
                      items: _batchCodes
                          .map(
                            (b) => DropdownMenuItem(value: b, child: Text(b)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedBatch = v),
                      validator: (v) => v == null ? 'Select a batch' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedCourse,
                      decoration: InputDecoration(labelText: 'Course'),
                      items: courseTitles
                          .map(
                            (course) => DropdownMenuItem(
                              value: course,
                              child: Text(course),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _selectedCourse = val),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Select a course' : null,
                    ),
                      // Action button
                      _buildSubmitButton(ctx, isEdit, docId),
                    ],
                  ),
                ),
              );
            },
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
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        labelStyle: TextStyle(color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: surfaceColor,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Password is required';
        if (value.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: primaryColor,
          ),
        ),
        labelStyle: TextStyle(color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: surfaceColor,
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _role,
      decoration: InputDecoration(
        labelText: 'Role',
        prefixIcon: Icon(Icons.admin_panel_settings_outlined, color: primaryColor),
        labelStyle: TextStyle(color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: surfaceColor,
      ),
      items: [
        {'value': 'admin', 'label': 'Administrator', 'icon': Icons.admin_panel_settings},
        {'value': 'employee', 'label': 'Employee', 'icon': Icons.person},
        {'value': 'staff', 'label': 'Staff Member', 'icon': Icons.badge},
      ].map((role) => DropdownMenuItem(
        value: role['value'] as String,
        child: Row(
          children: [
            Icon(role['icon'] as IconData, size: 20, color: primaryColor),
            const SizedBox(width: 12),
            Text(role['label'] as String),
          ],
        ),
      )).toList(),
      onChanged: (val) => setState(() => _role = val!),
    );
  }

  Widget _buildBatchDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBatch,
      decoration: InputDecoration(
        labelText: 'Batch',
        prefixIcon: Icon(Icons.group_outlined, color: primaryColor),
        labelStyle: TextStyle(color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: surfaceColor,
      ),
      items: _batchCodes.map((batch) => DropdownMenuItem(
        value: batch,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                batch.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(batch),
          ],
        ),
      )).toList(),
      onChanged: (v) => setState(() => _selectedBatch = v),
      validator: (v) => v == null ? 'Please select a batch' : null,
    );
  }

  Widget _buildCourseDropdown(List<String> courseTitles) {
    return DropdownButtonFormField<String>(
      value: _selectedCourse,
      decoration: InputDecoration(
        labelText: 'Course',
        prefixIcon: Icon(Icons.school_outlined, color: primaryColor),
        labelStyle: TextStyle(color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: surfaceColor,
      ),
      items: courseTitles.map((course) => DropdownMenuItem(
        value: course,
        child: Row(
          children: [
            Icon(Icons.book_outlined, size: 18, color: primaryColor),
            const SizedBox(width: 12),
            Expanded(child: Text(course)),
          ],
        ),
      )).toList(),
      onChanged: (val) => setState(() => _selectedCourse = val),
      validator: (val) => val == null || val.isEmpty ? 'Please select a course' : null,
    );
  }
  Widget _buildSubmitButton(BuildContext ctx, bool isEdit, String? docId) {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _handleFormSubmit(ctx, isEdit, docId),
        icon: Icon(
          isEdit ? Icons.update : Icons.person_add,
          color: Colors.white,
        ),
        label: Text(
          isEdit ? 'Update Employee' : 'Add Employee',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: primaryColor.withOpacity(0.4),
        ),
      ),
    );
  }

  Future<void> _handleFormSubmit(BuildContext ctx, bool isEdit, String? docId) async {
    if (!_formKey.currentState!.validate()) return;

    try {
                          final firestore = FirebaseFirestore.instance;
                          if (isEdit && docId != null) {
                            // 🔁 EDIT CASE
                            final userRef = firestore
                                .collection('users')
                                .doc(docId);
                            final userSnap = await userRef.get();
                            final uid = userSnap['uid'];
                            final oldBatch = userSnap['batch'];
                            final oldCourse = userSnap['course'];
                            final newBatch = _selectedBatch;
                            final newCourse = _selectedCourse;
                            // ✅ Update user document
                            await userRef.update({
                              'name': _nameController.text.trim(),
                              'email': _emailController.text.trim(),
                              'phone': _phoneController.text.trim(),
                              'role': _role,
                              'course': newCourse,
                              'batch': newBatch,
                            });
                            // 🚨 Check if batch or course changed
                            if (oldBatch != newBatch ||
                                oldCourse != newCourse) {
                              final batch = firestore.batch();
                              final userMap = {
                                'name': _nameController.text.trim(),
                                'email': _emailController.text.trim(),
                                'uid': uid,
                                'phone': _phoneController.text.trim(),
                                'role': _role,
                                'course': newCourse,
                                'customId': userSnap['customId'],
                              };
                              // 🔽 Remove user from old batch
                              final oldBatchSnap = await firestore
                                  .collection('batches')
                                  .where('batchCode', isEqualTo: oldBatch)
                                  .limit(1)
                                  .get();
                              if (oldBatchSnap.docs.isNotEmpty) {
                                final oldBatchRef =
                                    oldBatchSnap.docs.first.reference;
                                batch.update(oldBatchRef, {
                                  'studentCount': FieldValue.increment(-1),
                                  'studentmap.$uid': FieldValue.delete(),
                                });
                              }
                              // 🔼 Add user to new batch
                              final newBatchSnap = await firestore
                                  .collection('batches')
                                  .where('batchCode', isEqualTo: newBatch)
                                  .limit(1)
                                  .get();
                              if (newBatchSnap.docs.isNotEmpty) {
                                final newBatchRef =
                                    newBatchSnap.docs.first.reference;
                                batch.update(newBatchRef, {
                                  'studentCount': FieldValue.increment(1),
                                  'studentmap.$uid': userMap,
                                });
                              }
                              // 🔽 Decrement old course student count
                              final oldCourseSnap = await firestore
                                  .collection('courses')
                                  .where('title', isEqualTo: oldCourse)
                                  .limit(1)
                                  .get();
                              if (oldCourseSnap.docs.isNotEmpty) {
                                final oldCourseRef =
                                    oldCourseSnap.docs.first.reference;
                                batch.update(oldCourseRef, {
                                  'studentCount': FieldValue.increment(-1),
                                });
                              }
                              // 🔼 Increment new course student count
                              final newCourseSnap = await firestore
                                  .collection('courses')
                                  .where('title', isEqualTo: newCourse)
                                  .limit(1)
                                  .get();
                              if (newCourseSnap.docs.isNotEmpty) {
                                final newCourseRef =
                                    newCourseSnap.docs.first.reference;
                                batch.update(newCourseRef, {
                                  'studentCount': FieldValue.increment(1),
                                });
                              }
                              // ✅ Commit all updates
                              await batch.commit();
                            }
                          } else {
                            // ➕ ADD CASE
                            final credential = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                );
                            final uid = credential.user!.uid;
                            // 📦 Generate customId
                            final latestUserSnap = await firestore
                                .collection('users')
                                .orderBy('customId', descending: true)
                                .limit(1)
                                .get();
                            String newCustomId = "Tek001";
                            if (latestUserSnap.docs.isNotEmpty) {
                              String lastId =
                                  latestUserSnap.docs.first['customId'];
                              int lastNum =
                                  int.tryParse(
                                    lastId.replaceAll(RegExp(r'[^0-9]'), ''),
                                  ) ??
                                  0;
                              newCustomId =
                                  "Tek${(lastNum + 1).toString().padLeft(3, '0')}";
                            }
                            final userMap = {
                              'uid': uid,
                              'customId': newCustomId,
                              'name': _nameController.text.trim(),
                              'email': _emailController.text.trim(),
                              'password': _passwordController.text.trim(),
                              'phone': _phoneController.text.trim(),
                              'role': _role,
                              'course': _selectedCourse,
                              'batch': _selectedBatch,
                              'createdAt': FieldValue.serverTimestamp(),
                            };
                            await firestore
                                .collection('users')
                                .doc(uid)
                                .set(userMap);
                            final batch = firestore.batch();
                            // ✅ Update batch
                            final batchSnap = await firestore
                                .collection('batches')
                                .where('batchCode', isEqualTo: _selectedBatch)
                                .limit(1)
                                .get();
                            if (batchSnap.docs.isNotEmpty) {
                              final batchRef = batchSnap.docs.first.reference;
                              batch.update(batchRef, {
                                'studentCount': FieldValue.increment(1),
                                'studentmap.$uid': {
                                  'name': _nameController.text.trim(),
                                  'email': _emailController.text.trim(),
                                  'uid': uid,
                                  'phone': _phoneController.text.trim(),
                                  'role': _role,
                                  'course': _selectedCourse,
                                  'customId': newCustomId,
                                },
                              });
                            }
                            // ✅ Update course
                            final courseSnap = await firestore
                                .collection('courses')
                                .where('title', isEqualTo: _selectedCourse)
                                .limit(1)
                                .get();
                            if (courseSnap.docs.isNotEmpty) {
                              final courseRef = courseSnap.docs.first.reference;
                              batch.update(courseRef, {
                                'studentCount': FieldValue.increment(1),
                              });
                            }
                            // 🔐 Commit all in batch
                            await batch.commit();
                          }
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEdit ? 'User updated' : 'User added',
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }

  }

  void _showSuccessSnackbar(String message) {
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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
      
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildSearchBar(),
                // _buildEmployeeStats(),
                Expanded(child: _buildEmployeesList()),
              ],
            ),
          ),
        ),
        floatingActionButton: ScaleTransition(
          scale: _scaleAnimation,
          child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => _showUserFormBottomSheet(context),
            backgroundColor: primaryColor,
            // icon: const Icon(Icons.person_add, color: Colors.white),
            // label: const Text(
            //   'Add Employee',
            //   style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            // ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
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
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name, email, or ID...',
          prefixIcon: Icon(Icons.search, color: primaryColor),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
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

  Widget _buildEmployeeStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        
        final totalEmployees = snapshot.data!.docs.length;
        final activeEmployees = snapshot.data!.docs
            .where((doc) => (doc.data() as Map<String, dynamic>)['role'] == 'employee')
            .length;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor.withOpacity(0.1), primaryColor.withOpacity(0.05)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              _buildStatItem(Icons.people, 'Total', totalEmployees.toString()),
              const SizedBox(width: 32),
              _buildStatItem(Icons.person, 'Employees', activeEmployees.toString()),
              const Spacer(),
              if (_searchQuery.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Filtered',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmployeesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               loadingWidget(),
                const SizedBox(height: 16),
                Text(
                  'Loading employees...',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;
      
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          
          final email = data['email']?.toString().toLowerCase() ?? '';
          final name = data['name']?.toString().toLowerCase() ?? '';
          final customId = data['customId']?.toString().toLowerCase() ?? '';
          return email.contains(_searchQuery) ||
              name.contains(_searchQuery) ||
              customId.contains(_searchQuery);
        }).toList();

        if (filteredDocs.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final user = filteredDocs[index];
            final data = user.data() as Map<String, dynamic>;
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildEmployeeCard(user.id, data, index),
            );
          },
        );
      },
    );
  }

  Widget _buildEmployeeCard(String docId, Map<String, dynamic> data, int index) {
    final colors = [
      primaryColor,
      primaryColor.withOpacity(0.8),
      primaryColor.withOpacity(0.6),
      primaryColor.withOpacity(0.9),
    ];
    final gradientColor = colors[index % colors.length];
    
    final role = data['role'] ?? 'employee';
    final roleIcon = role == 'admin' 
        ? Icons.admin_panel_settings 
        : role == 'staff' 
            ? Icons.badge 
            : Icons.person;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        // boxShadow: [
        //   BoxShadow(
        //     color: gradientColor.withOpacity(0.15),
        //     blurRadius: 15,
        //     offset: const Offset(0, 8),
        //   ),
        // ],
      ),
      child: Material(
        shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(20),),
        elevation: 1,
        // color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Navigate to employee details
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with avatar and actions
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [gradientColor, gradientColor.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          (data['name'] ?? 'N')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                data['customId'] ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: gradientColor,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: gradientColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(roleIcon, size: 12, color: gradientColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      role.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: gradientColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['name'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            data['email'] ?? 'N/A',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _showUserFormBottomSheet(
                            context,
                            isEdit: true,
                            docId: docId,
                            userData: data,
                          ),
                          icon: Icon(Icons.edit_outlined, color: gradientColor),
                          style: IconButton.styleFrom(
                            backgroundColor: gradientColor.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _showDeleteConfirmation(docId, data),
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Details section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        Icons.phone_outlined,
                        'Phone',
                        data['phone'] ?? 'N/A',
                        gradientColor,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.school_outlined,
                        'Course',
                        data['course'] ?? 'N/A',
                        gradientColor,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.group_outlined,
                        'Batch',
                        data['batch'] ?? 'N/A',
                        gradientColor,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.lock_outline,
                        'Password',
                        '●●●●●●●●',
                        gradientColor,
                        isPassword: true,
                        actualPassword: data['password'] ?? 'N/A',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color, {
    bool isPassword = false,
    String? actualPassword,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        Expanded(
          child: isPassword
              ? Row(
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text('Password'),
                            content: SelectableText(actualPassword ?? 'N/A'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: color,
                      ),
                    ),
                  ],
                )
              : Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(String docId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning_amber_rounded, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Delete Employee'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this employee?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: primaryColor.withOpacity(0.1),
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
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          data['email'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(docId, data['batch'], data['course']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
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
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.people_outline,
              size: 80,
              color: primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _searchQuery.isNotEmpty ? 'No employees found' : 'No employees yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color?.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'Add your first employee to get started',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (_searchQuery.isEmpty)
            ElevatedButton.icon(
              onPressed: () => _showUserFormBottomSheet(context),
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text(
                'Add Your First Employee',
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


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:tekort/Providers/courseprovider.dart';
// import 'package:tekort/core/core/common/loading.dart';
// class EmployeesScreen extends StatefulWidget {
//   @override
//   State<EmployeesScreen> createState() => _EmployeesScreenState();
// }
// class _EmployeesScreenState extends State<EmployeesScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _nameController = TextEditingController();
//   final _searchController = TextEditingController();
//   String _searchQuery = '';
//   String _role = 'employee';
//   String? _selectedCourse;
//   String? _selectedBatch;
//   List<String> _batchCodes = [];
//   @override
//   void initState() {
//     super.initState();
//     _loadBatchCodes();
//     _searchController.addListener(() {
//       setState(() {
//         _searchQuery = _searchController.text.toLowerCase();
//       });
//     });
//   }
//   Future<void> _loadBatchCodes() async {
//     final snap = await FirebaseFirestore.instance.collection('batches').get();
//     setState(() {
//       _batchCodes = snap.docs
//           .map((d) => d.data()['batchCode'] as String)
//           .toList();
//       if (_selectedBatch == null && _batchCodes.isNotEmpty) {
//         _selectedBatch = _batchCodes.first;
//       }
//     });
//   }
//   Future<void> _deleteUser(
//     String uid,
//     String batchCode,
//     String courseTitle,
//   ) async {
//     final firestore = FirebaseFirestore.instance;
//     try {
//       final batch = firestore.batch();      // 1. Delete user from 'users' collection
//       final userRef = firestore.collection('users').doc(uid);
//       batch.delete(userRef);      // 2. Update batch - decrement studentCount & remove from studentmap
//       final batchSnap = await firestore
//           .collection('batches')
//           .where('batchCode', isEqualTo: batchCode)          .limit(1)          .get();
//       if (batchSnap.docs.isNotEmpty) {
//         final batchRef = batchSnap.docs.first.reference;
//         batch.update(batchRef, {
//           'studentCount': FieldValue.increment(-1),
//           'studentmap.$uid': FieldValue.delete(),
//         });
//       }      // 3. Update course - decrement studentCount
//       final courseSnap = await firestore
//           .collection('courses')
//           .where('title', isEqualTo: courseTitle)
//           .limit(1)
//           .get();
//       if (courseSnap.docs.isNotEmpty) {
//         final courseRef = courseSnap.docs.first.reference;
//         batch.update(courseRef, {'studentCount': FieldValue.increment(-1)});
//       }
//       await batch.commit();
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("User deleted successfully")));
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error deleting user: $e")));
//     }
//   }
//   void _resetControllers() {
//     _emailController.clear();
//     _passwordController.clear();
//     _phoneController.clear();
//     _nameController.clear();
//     _role = 'employee';
//     _selectedCourse = null;
//     _selectedBatch = null;
//   }

//   Future<void> _showUserFormBottomSheet(
//     BuildContext context, {
//     bool isEdit = false,
//     String? docId,
//     Map<String, dynamic>? userData,
//   }) async {
//     if (isEdit && userData != null) {
//       _emailController.text = userData['email'] ?? '';
//       _phoneController.text = userData['phone'] ?? '';
//       _nameController.text = userData['name'] ?? '';
//       _role = userData['role'] ?? 'employee';
//       _selectedCourse = userData['course'];
//       _selectedBatch = userData['batch'];
//     } else {
//       _resetControllers();
//     }
//     await showModalBottomSheet(
//       isScrollControlled: true,
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (ctx) {
//         return Consumer<CourseProvider>(
//           builder: (context, provider, _) {
//             final courseTitles = provider.courses.map((c) => c.title).toList();
//             if (!isEdit &&
//                 (_selectedCourse == null || _selectedCourse!.isEmpty)) {
//               _selectedCourse = courseTitles.isNotEmpty
//                   ? courseTitles.first
//                   : null;            }
//             return Padding(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(ctx).viewInsets.bottom,
//                 left: 16,
//                 right: 16,
//                 top: 16,
//               ),
//               child: Form(
//                 key: _formKey,
//                 child: Wrap(
//                   runSpacing: 10,
//                   children: [
//                     Text(
//                       isEdit ? "Edit Employee" : "Add New Employee",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     TextFormField(
//                       controller: _nameController,
//                       decoration: InputDecoration(labelText: 'Name'),
//                       validator: (value) => value!.isEmpty ? 'Required' : null,
//                     ),
//                     TextFormField(
//                       controller: _emailController,
//                       decoration: InputDecoration(labelText: 'Email'),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) return 'Required';
//                         if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
//                           return 'Invalid email';
//                         }
//                         return null;
//                       },
//                     ),
//                     if (!isEdit)
//                       TextFormField(
//                         controller: _passwordController,
//                         obscureText: true,
//                         decoration: InputDecoration(labelText: 'Password'),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) return 'Required';
//                           if (value.length < 6) return 'Minimum 6 characters';
//                           return null;
//                         },
//                       ),
//                     TextFormField(
//                       controller: _phoneController,
//                       keyboardType: TextInputType.phone,
//                       decoration: InputDecoration(labelText: 'Phone'),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) return 'Required';
//                         if (!RegExp(r'^\d{10,}$').hasMatch(value)) {
//                           return 'Invalid phone number';
//                         }
//                         return null;
//                       },
//                     ),
//                     DropdownButtonFormField<String>(
//                       value: _role,
//                       decoration: InputDecoration(labelText: 'Role'),
//                       items: ['admin', 'employee', 'staff']
//                           .map(
//                             (role) => DropdownMenuItem(
//                               value: role,
//                               child: Text(role),
//                             ),
//                           )
//                           .toList(),
//                       onChanged: (val) => setState(() => _role = val!),
//                     ),
//                     DropdownButtonFormField<String>(
//                       value: _selectedBatch,
//                       decoration: InputDecoration(labelText: 'Batch'),
//                       items: _batchCodes
//                           .map(
//                             (b) => DropdownMenuItem(value: b, child: Text(b)),
//                           )
//                           .toList(),
//                       onChanged: (v) => setState(() => _selectedBatch = v),
//                       validator: (v) => v == null ? 'Select a batch' : null,
//                     ),
//                     DropdownButtonFormField<String>(
//                       value: _selectedCourse,
//                       decoration: InputDecoration(labelText: 'Course'),
//                       items: courseTitles
//                           .map(
//                             (course) => DropdownMenuItem(
//                               value: course,
//                               child: Text(course),
//                             ),
//                           )
//                           .toList(),
//                       onChanged: (val) => setState(() => _selectedCourse = val),
//                       validator: (val) =>
//                           val == null || val.isEmpty ? 'Select a course' : null,
//                     ),
//                     SizedBox(height: 10),
//                     ElevatedButton(
//                       onPressed: () async {
//                         if (!_formKey.currentState!.validate()) return;

//                         try {
//                           final firestore = FirebaseFirestore.instance;
//                           if (isEdit && docId != null) {
//                             // 🔁 EDIT CASE
//                             final userRef = firestore
//                                 .collection('users')
//                                 .doc(docId);
//                             final userSnap = await userRef.get();
//                             final uid = userSnap['uid'];
//                             final oldBatch = userSnap['batch'];
//                             final oldCourse = userSnap['course'];
//                             final newBatch = _selectedBatch;
//                             final newCourse = _selectedCourse;
//                             // ✅ Update user document
//                             await userRef.update({
//                               'name': _nameController.text.trim(),
//                               'email': _emailController.text.trim(),
//                               'phone': _phoneController.text.trim(),
//                               'role': _role,
//                               'course': newCourse,
//                               'batch': newBatch,
//                             });
//                             // 🚨 Check if batch or course changed
//                             if (oldBatch != newBatch ||
//                                 oldCourse != newCourse) {
//                               final batch = firestore.batch();
//                               final userMap = {
//                                 'name': _nameController.text.trim(),
//                                 'email': _emailController.text.trim(),
//                                 'uid': uid,
//                                 'phone': _phoneController.text.trim(),
//                                 'role': _role,
//                                 'course': newCourse,
//                                 'customId': userSnap['customId'],
//                               };
//                               // 🔽 Remove user from old batch
//                               final oldBatchSnap = await firestore
//                                   .collection('batches')
//                                   .where('batchCode', isEqualTo: oldBatch)
//                                   .limit(1)
//                                   .get();
//                               if (oldBatchSnap.docs.isNotEmpty) {
//                                 final oldBatchRef =
//                                     oldBatchSnap.docs.first.reference;
//                                 batch.update(oldBatchRef, {
//                                   'studentCount': FieldValue.increment(-1),
//                                   'studentmap.$uid': FieldValue.delete(),
//                                 });
//                               }
//                               // 🔼 Add user to new batch
//                               final newBatchSnap = await firestore
//                                   .collection('batches')
//                                   .where('batchCode', isEqualTo: newBatch)
//                                   .limit(1)
//                                   .get();
//                               if (newBatchSnap.docs.isNotEmpty) {
//                                 final newBatchRef =
//                                     newBatchSnap.docs.first.reference;
//                                 batch.update(newBatchRef, {
//                                   'studentCount': FieldValue.increment(1),
//                                   'studentmap.$uid': userMap,
//                                 });
//                               }
//                               // 🔽 Decrement old course student count
//                               final oldCourseSnap = await firestore
//                                   .collection('courses')
//                                   .where('title', isEqualTo: oldCourse)
//                                   .limit(1)
//                                   .get();
//                               if (oldCourseSnap.docs.isNotEmpty) {
//                                 final oldCourseRef =
//                                     oldCourseSnap.docs.first.reference;
//                                 batch.update(oldCourseRef, {
//                                   'studentCount': FieldValue.increment(-1),
//                                 });
//                               }
//                               // 🔼 Increment new course student count
//                               final newCourseSnap = await firestore
//                                   .collection('courses')
//                                   .where('title', isEqualTo: newCourse)
//                                   .limit(1)
//                                   .get();
//                               if (newCourseSnap.docs.isNotEmpty) {
//                                 final newCourseRef =
//                                     newCourseSnap.docs.first.reference;
//                                 batch.update(newCourseRef, {
//                                   'studentCount': FieldValue.increment(1),
//                                 });
//                               }
//                               // ✅ Commit all updates
//                               await batch.commit();
//                             }
//                           } else {
//                             // ➕ ADD CASE
//                             final credential = await FirebaseAuth.instance
//                                 .createUserWithEmailAndPassword(
//                                   email: _emailController.text.trim(),
//                                   password: _passwordController.text.trim(),
//                                 );
//                             final uid = credential.user!.uid;
//                             // 📦 Generate customId
//                             final latestUserSnap = await firestore
//                                 .collection('users')
//                                 .orderBy('customId', descending: true)
//                                 .limit(1)
//                                 .get();
//                             String newCustomId = "Tek001";
//                             if (latestUserSnap.docs.isNotEmpty) {
//                               String lastId =
//                                   latestUserSnap.docs.first['customId'];
//                               int lastNum =
//                                   int.tryParse(
//                                     lastId.replaceAll(RegExp(r'[^0-9]'), ''),
//                                   ) ??
//                                   0;
//                               newCustomId =
//                                   "Tek${(lastNum + 1).toString().padLeft(3, '0')}";
//                             }
//                             final userMap = {
//                               'uid': uid,
//                               'customId': newCustomId,
//                               'name': _nameController.text.trim(),
//                               'email': _emailController.text.trim(),
//                               'password': _passwordController.text.trim(),
//                               'phone': _phoneController.text.trim(),
//                               'role': _role,
//                               'course': _selectedCourse,
//                               'batch': _selectedBatch,
//                               'createdAt': FieldValue.serverTimestamp(),
//                             };
//                             await firestore
//                                 .collection('users')
//                                 .doc(uid)
//                                 .set(userMap);
//                             final batch = firestore.batch();
//                             // ✅ Update batch
//                             final batchSnap = await firestore
//                                 .collection('batches')
//                                 .where('batchCode', isEqualTo: _selectedBatch)
//                                 .limit(1)
//                                 .get();
//                             if (batchSnap.docs.isNotEmpty) {
//                               final batchRef = batchSnap.docs.first.reference;
//                               batch.update(batchRef, {
//                                 'studentCount': FieldValue.increment(1),
//                                 'studentmap.$uid': {
//                                   'name': _nameController.text.trim(),
//                                   'email': _emailController.text.trim(),
//                                   'uid': uid,
//                                   'phone': _phoneController.text.trim(),
//                                   'role': _role,
//                                   'course': _selectedCourse,
//                                   'customId': newCustomId,
//                                 },
//                               });
//                             }
//                             // ✅ Update course
//                             final courseSnap = await firestore
//                                 .collection('courses')
//                                 .where('title', isEqualTo: _selectedCourse)
//                                 .limit(1)
//                                 .get();
//                             if (courseSnap.docs.isNotEmpty) {
//                               final courseRef = courseSnap.docs.first.reference;
//                               batch.update(courseRef, {
//                                 'studentCount': FieldValue.increment(1),
//                               });
//                             }
//                             // 🔐 Commit all in batch
//                             await batch.commit();
//                           }
//                           Navigator.pop(ctx);
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(
//                                 isEdit ? 'User updated' : 'User added',
//                               ),
//                             ),
//                           );
//                         } catch (e) {
//                           ScaffoldMessenger.of(
//                             context,
//                           ).showSnackBar(SnackBar(content: Text('Error: $e')));
//                         }
//                       },
//                       child: Text(isEdit ? 'Update' : 'Add'),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8),
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   labelText: 'Search by name, email, or ID',
//                   prefixIcon: Icon(Icons.search),
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('users')
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData)
//                     return Center(child: CircularProgressIndicator());

//                   final docs = snapshot.data!.docs;
//                   final filteredDocs = docs.where((doc) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     final email = data['email']?.toString().toLowerCase() ?? '';
//                     final name = data['name']?.toString().toLowerCase() ?? '';
//                     final customId =
//                         data['customId']?.toString().toLowerCase() ?? '';
//                     return email.contains(_searchQuery) ||
//                         name.contains(_searchQuery) ||
//                         customId.contains(_searchQuery);
//                   }).toList();
//                   return ListView.builder(
//                     itemCount: filteredDocs.length,
//                     itemBuilder: (context, index) {
//                       final user = filteredDocs[index];
//                       final data = user.data() as Map<String, dynamic>;
//                       return Card(
//                         margin: EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 6,
//                         ),
//                         child: ListTile(
//                           title: Text('${data['customId']} - ${data['email']}'),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Phone: ${data['phone']} | Role: ${data['role']}',
//                               ),
//                               Text('Course: ${data['course'] ?? 'N/A'}'),
//                               Text('Batch: ${data['batch'] ?? 'N/A'}'),
//                               Text('Password: ${data['password']}'),
//                               Text('Name: ${data['name']}'),
//                             ],
//                           ),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: Icon(Icons.edit),
//                                 onPressed: () => _showUserFormBottomSheet(
//                                   context,
//                                   isEdit: true,
//                                   docId: user.id,
//                                   userData: data,
//                                 ),
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () {
//                                   showDialog(
//                                     context: context,
//                                     builder: (_) => AlertDialog(
//                                       title: Text('Confirm Delete'),
//                                       content: Text(
//                                         'Are you sure you want to delete this user?',
//                                       ),
//                                       actions: [
//                                         TextButton(
//                                           onPressed: () =>
//                                               Navigator.pop(context),
//                                           child: Text('Cancel'),
//                                         ),
//                                         ElevatedButton(
//                                           onPressed: () {
//                                             Navigator.pop(context);
//                                             _deleteUser(
//                                               user.id,
//                                               data['batch'],
//                                               data['course'],
//                                             );
//                                           },
//                                           child: Text('Delete'),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () => _showUserFormBottomSheet(context),
//           child: Icon(Icons.add),
//         ),
//       ),
//     );
//   }
// }