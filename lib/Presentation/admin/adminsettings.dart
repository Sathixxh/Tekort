
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tekort/Models/batchmodel.dart';
import 'package:tekort/Presentation/admin/addupdatebatchscrenn.dart';
import 'package:tekort/Presentation/admin/addupdatestudents.dart';
import 'package:tekort/Presentation/admin/addupdatetask.dart';
import 'package:tekort/Providers/batchprovider.dart';
import 'package:tekort/Presentation/admin/admindashboard.dart';
import 'package:tekort/core/core/utils/styles.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Two tabs: Courses and Employees
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Dashboard'),
          bottom: TabBar(
            dividerColor: backgroundcolor,
            tabs: [
              Tab(text: 'Courses'),
              Tab(text: 'Employees'),
              Tab(text: 'Batch'),
              Tab(text: 'Task'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CourseListScreen(),
            EmployeesScreen(), // This should be your actual employee screen
            BatchScreennew(),
            TaskScreennew(),
          ],
        ),
      ),
    );
  }
}

class BatchScreen extends StatefulWidget {
  const BatchScreen({Key? key}) : super(key: key);
  @override
  State<BatchScreen> createState() => _BatchScreenState();
}
class _BatchScreenState extends State<BatchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<BatchModel> _filteredBatches = [];
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<BatchProvider>(context, listen: false);
    provider.fetchBatches().then((_) {
      setState(() {
        _filteredBatches = provider.batches;
      });
    });
    _searchController.addListener(_onSearchChanged);
  }
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    final provider = Provider.of<BatchProvider>(context, listen: false);
    setState(() {
      _filteredBatches = provider.batches
          .where((batch) => batch.batchCode.toLowerCase().contains(query))
          .toList();
    });  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  void _openBottomSheet({BatchModel? batch}) {
    final codeController = TextEditingController(text: batch?.batchCode ?? '');
    final startDateController = TextEditingController(
      text: batch?.startDate != null
          ? DateFormat('yyyy-MM-dd').format(batch!.startDate)          : '',
    );
    final endDateController = TextEditingController(
      text: batch?.endDate != null
          ? DateFormat('yyyy-MM-dd').format(batch!.endDate)          : '',
    );
    DateTime? selectedStartDate = batch?.startDate;
    DateTime? selectedEndDate = batch?.endDate;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Batch Code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: startDateController,
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedStartDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    selectedStartDate = picked;
                    startDateController.text = DateFormat(
                      'yyyy-MM-dd',
                    ).format(picked);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: endDateController,
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedEndDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    selectedEndDate = picked;
                    endDateController.text = DateFormat(
                      'yyyy-MM-dd',
                    ).format(picked);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'End Date',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (codeController.text.isNotEmpty &&
                      selectedStartDate != null &&
                      selectedEndDate != null) {
                    if (selectedEndDate!.isBefore(selectedStartDate!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('End date must be after start date.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    final newBatch = BatchModel(
                      id: batch?.id ?? '',
                      batchCode: codeController.text.trim(),
                      startDate: selectedStartDate!,
                      endDate: selectedEndDate!,
                      studentmap: batch?.studentmap ?? {},
                      studentCount: batch?.studentCount ?? 0,
                    );
                    try {
                      await Provider.of<BatchProvider>(
                        context,
                        listen: false,
                      ).addOrUpdateBatch(newBatch);
                      final provider = Provider.of<BatchProvider>(
                        context,
                        listen: false,
                      );
                      await provider.fetchBatches();
                      setState(() {
                        _filteredBatches = provider.batches
                            .where(
                              (b) => b.batchCode.toLowerCase().contains(
                                _searchController.text.toLowerCase(),
                              ),
                            )
                            .toList();
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            batch == null
                                ? 'Batch added successfully!'
                                : 'Batch updated successfully!',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Something went wrong!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(batch == null ? 'Add Batch' : 'Update Batch'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _deleteBatch(String id) async {
    await FirebaseFirestore.instance.collection('batches').doc(id).delete();
    final provider = Provider.of<BatchProvider>(context, listen: false);
    await provider.fetchBatches();
    setState(() {
      _filteredBatches = provider.batches
          .where(
            (b) => b.batchCode.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),          )          .toList();    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Batch deleted'),
        backgroundColor: Colors.red,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by Batch Code',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer<BatchProvider>(
                builder: (context, provider, _) {
                  if (_filteredBatches.isEmpty) {
                    return const Center(child: Text('No batches found.'));
                  }
                  return ListView.builder(
                    itemCount: _filteredBatches.length,
                    itemBuilder: (_, index) {
                      final batch = _filteredBatches[index];
                      final now = DateTime.now();
                      final isActive =
                          batch.startDate.isBefore(now) &&
                          batch.endDate.isAfter(now);
                      return Card(
                        child: ListTile(
                          title: Text(batch.batchCode),
                          subtitle: Text(
                            "Students: ${batch.studentCount}\n"
                            "${DateFormat('yyyy-MM-dd').format(batch.startDate)} - "
                            "${DateFormat('yyyy-MM-dd').format(batch.endDate)}"
                            "${isActive ? '\nStatus: Ongoing' : ''}",
                            style: TextStyle(
                              color: isActive ? Colors.green : Colors.grey,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _openBottomSheet(batch: batch),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteBatch(batch.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openBottomSheet(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}






