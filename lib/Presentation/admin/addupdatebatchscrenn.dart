import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tekort/Models/batchmodel.dart';
import 'package:tekort/Providers/batchprovider.dart';
import 'package:tekort/core/core/common/loading.dart';
import 'package:tekort/core/core/utils/styles.dart';

class BatchScreennew extends StatefulWidget {
  const BatchScreennew({Key? key}) : super(key: key);
  @override
  State<BatchScreennew> createState() => _BatchScreennewState();
}

class _BatchScreennewState extends State<BatchScreennew> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<BatchModel> _filteredBatches = [];
 late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  // Theme colors
  Color get primaryColor => Theme.of(context).primaryColor;
  Color get backgroundColor => Theme.of(context).scaffoldBackgroundColor;
  Color get cardColor => Theme.of(context).cardColor;
  Color get textColor => Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  Color get surfaceColor => Theme.of(context).colorScheme.surface;
  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadBatches();
    _searchController.addListener(_onSearchChanged);
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
  Future<void> _loadBatches() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<BatchProvider>(context, listen: false);
    await provider.fetchBatches();
    setState(() {
      _filteredBatches = provider.batches;
      _isLoading = false;
    });
    _fadeController.forward();
    _slideController.forward();
     _scaleController.forward();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    final provider = Provider.of<BatchProvider>(context, listen: false);
    setState(() {
      _filteredBatches = provider.batches
          .where((batch) => batch.batchCode.toLowerCase().contains(query))
          .toList();
    });
  }

 @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
 
    _searchController.dispose();
    super.dispose();
  }

  void _openBottomSheet({BatchModel? batch}) {
    final codeController = TextEditingController(text: batch?.batchCode ?? '');
    final startDateController = TextEditingController(
      text: batch?.startDate != null
          ? DateFormat('yyyy-MM-dd').format(batch!.startDate)
          : '',
    );
    final endDateController = TextEditingController(
      text: batch?.endDate != null
          ? DateFormat('yyyy-MM-dd').format(batch!.endDate)
          : '',
    );
    DateTime? selectedStartDate = batch?.startDate;
    DateTime? selectedEndDate = batch?.endDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                
                // Title
                Text(
                  batch == null ? 'Add New Batch' : 'Update Batch',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 30),

                // Batch Code Field
                _buildAnimatedTextField(
                  controller: codeController,
                  label: 'Batch Code',
                  icon: Icons.code,
                  delay: 100,
                ),
                const SizedBox(height: 20),

                // Start Date Field
                _buildAnimatedTextField(
                  controller: startDateController,
                  label: 'Start Date',
                  icon: Icons.calendar_today,
                  readOnly: true,
                  delay: 200,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedStartDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: primaryColor,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      selectedStartDate = picked;
                      startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                    }
                  },
                ),
                const SizedBox(height: 20),

                // End Date Field
                _buildAnimatedTextField(
                  controller: endDateController,
                  label: 'End Date',
                  icon: Icons.event,
                  readOnly: true,
                  delay: 300,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedEndDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: primaryColor,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      selectedEndDate = picked;
                      endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                    }
                  },
                ),
                const SizedBox(height: 30),

                // Submit Button
                _buildAnimatedButton(
                  text: batch == null ? 'Add Batch' : 'Update Batch',
                  icon: batch == null ? Icons.add : Icons.update,
                  onPressed: () => _handleFormSubmit(
                    codeController,
                    selectedStartDate,
                    selectedEndDate,
                    batch,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    int delay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  // BoxShadow(
                  //   color: primaryColor.withOpacity(0.1),
                  //   blurRadius: 8,
                  //   offset: const Offset(0, 2),
                  // ),
                ],
              ),
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                onTap: onTap,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(color: primaryColor),
                  prefixIcon: Icon(icon, color: primaryColor),
                  
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: Colors.white),
              label: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleFormSubmit(
    TextEditingController codeController,
    DateTime? selectedStartDate,
    DateTime? selectedEndDate,
    BatchModel? batch,
  ) async {
    if (codeController.text.isNotEmpty &&
        selectedStartDate != null &&
        selectedEndDate != null) {
      if (selectedEndDate.isBefore(selectedStartDate)) {
        _showSnackBar('End date must be after start date.', Colors.orange);
        return;
      }

      final newBatch = BatchModel(
        id: batch?.id ?? '',
        batchCode: codeController.text.trim(),
        startDate: selectedStartDate,
        endDate: selectedEndDate,
        studentmap: batch?.studentmap ?? {},
        studentCount: batch?.studentCount ?? 0,
      );

      try {
        await Provider.of<BatchProvider>(context, listen: false)
            .addOrUpdateBatch(newBatch);
        await _loadBatches();
        Navigator.pop(context);
        _showSnackBar(
          batch == null ? 'Batch added successfully!' : 'Batch updated successfully!',
          Colors.green,
        );
      } catch (e) {
        Navigator.pop(context);
        _showSnackBar('Something went wrong!', Colors.red);
      }
    }
  }

  Future<void> _deleteBatch(String id) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Batch', style: TextStyle(color: textColor)),
        content: Text('Are you sure you want to delete this batch?', style: TextStyle(color: textColor)),
        backgroundColor: cardColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: primaryColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      await FirebaseFirestore.instance.collection('batches').doc(id).delete();
      await _loadBatches();
      _showSnackBar('Batch deleted successfully', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                // Header with search
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            // BoxShadow(
                            //   color: primaryColor.withOpacity(0.1),
                            //   blurRadius: 8,
                            //   offset: const Offset(0, 2),
                            // ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'Search batches...',
                            hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                            prefixIcon: Icon(Icons.search, color: primaryColor),
                            filled: true,
                            fillColor: surfaceColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: primaryColor, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            
                // Batch List
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: loadingWidget()
                        )
                      : Consumer<BatchProvider>(
                        builder: (context, provider, _) {
                          if (_filteredBatches.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.group_outlined,
                                    size: 80,
                                    color: primaryColor.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No batches found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: textColor.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                                
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredBatches.length,
                            itemBuilder: (context, index) {
                              final batch = _filteredBatches[index];

                               return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildBatchCard(batch),
            );
                              // return TweenAnimationBuilder<double>(
                              //   duration: Duration(milliseconds: 500 + (index * 100)),
                              //   tween: Tween(begin: 0.0, end: 1.0),
                              //   curve: Curves.elasticOut,
                              //   builder: (context, value, child) {
                              //     return Transform.translate(
                              //       offset: Offset(0, 50 * (1 - value)),
                              //       child: Opacity(
                              //         opacity: value.clamp(0.0, 1.0),
                              //         child: _buildBatchCard(batch),
                              //       ),
                              //     );
                              //   },
                              // );
                            },
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
               child: const Icon(Icons.add),
          onPressed: () => _openBottomSheet(),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
                 elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildBatchCard(BatchModel batch) {
    final now = DateTime.now();
    final isActive = batch.startDate.isBefore(now) && batch.endDate.isAfter(now);
    final isPending = batch.startDate.isAfter(now);
    final isCompleted = batch.endDate.isBefore(now);

    Color statusColor = isActive 
        ? primaryColor
        : isPending 
            ? Colors.orange 
            : Colors.grey;

    String statusText = isActive 
        ? 'Ongoing' 
        : isPending 
            ? 'Upcoming' 
            : 'Completed';

    return Material(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            // BoxShadow(
            //   color: primaryColor.withOpacity(0.1),
            //   blurRadius: 15,
            //   offset: const Offset(0, 5),
            // ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          batch.batchCode,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor, width: 1),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _openBottomSheet(batch: batch),
                        icon: Icon(Icons.edit, color: primaryColor),
                        style: IconButton.styleFrom(
                          backgroundColor: primaryColor.withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _deleteBatch(batch.id),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Student count
              Row(
                children: [
                  Icon(Icons.people, color: primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${batch.studentCount} Students',
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Date range
              Row(
                children: [
                  Icon(Icons.calendar_today, color: primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${DateFormat('MMM dd, yyyy').format(batch.startDate)} - ${DateFormat('MMM dd, yyyy').format(batch.endDate)}',
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}