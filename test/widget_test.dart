// // This is a basic Flutter widget test.
// //
// // To perform an interaction with a widget in your test, use the WidgetTester
// // utility in the flutter_test package. For example, you can send tap and scroll
// // gestures. You can also use WidgetTester to find child widgets in the widget
// // tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// import 'package:tekort/main.dart';

// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(const MyApp());

//     // Verify that our counter starts at 0.
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);

//     // Tap the '+' icon and trigger a frame.
//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();

//     // Verify that our counter has incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
// }




// class EmployeesScreen extends StatefulWidget {
//   @override
//   State<EmployeesScreen> createState() => _EmployeesScreenState();
// }

// class _EmployeesScreenState extends State<EmployeesScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   TextEditingController _searchController = TextEditingController();
// String _searchQuery = '';
//   String _role = 'employee';
//   String? _selectedCourse;
//   final List<String> _roles = ['admin', 'employee', 'staff'];
//   @override
// void initState() {
//   super.initState();
//   _searchController.addListener(() {
//     setState(() {
//       _searchQuery = _searchController.text.toLowerCase();
//     });
//   });
// }
//   void _resetControllers() {
//     _emailController.clear();
//     _passwordController.clear();
//     _phoneController.clear();
//     _nameController.clear();
//     _role = 'employee';
   
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
//     _selectedCourse = userData['course'];

//     } else {
//       _resetControllers();
//     }

//     await showModalBottomSheet(
//       isScrollControlled: true,
//       context: context,
//       builder: (ctx) {
//         return Consumer<CourseProvider>(
//           builder: (context, provider, child) {
//             final courseTitles = provider.courses.map((c) => c.title).toList();

//             if (!isEdit && (_selectedCourse == null || _selectedCourse!.isEmpty)) {
//   _selectedCourse = courseTitles.isNotEmpty ? courseTitles.first : null;
// }            return Padding(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(ctx).viewInsets.bottom,
//                 left: 16,
//                 right: 16,
//                 top: 16,
//               ),
//               child: Form(
//                 key: _formKey,
//                 child: Wrap(
//                   children: [
//                     Text(
//                       isEdit ? "Edit Employee" : "Add New Employee",
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 10),

//                     TextFormField(
//                       controller: _nameController,
//                       decoration: InputDecoration(labelText: 'Name'),
//                       validator: (value) =>
//                           value == null || value.isEmpty ? 'Required' : null,
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
//                       decoration: InputDecoration(labelText: 'Phone'),
//                       keyboardType: TextInputType.phone,
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
//                       items: _roles
//                           .map((role) => DropdownMenuItem(
//                                 value: role,
//                                 child: Text(role),
//                               ))
//                           .toList(),
//                       onChanged: (val) {
//                         setState(() {
//                           _role = val!;
//                         });
//                       },
//                       validator: (val) =>
//                           val == null || val.isEmpty ? 'Select a role' : null,
//                     ),

//                     DropdownButtonFormField<String>(
//   value: courseTitles.contains(_selectedCourse) ? _selectedCourse : null,
//   decoration: InputDecoration(labelText: 'Course'),
//   items: courseTitles
//       .map((course) => DropdownMenuItem(
//             value: course,
//             child: Text(course),
//           ))
//       .toList(),
//   onChanged: (val) {
//     setState(() {
//       _selectedCourse = val!;
//     });
//   },
//   validator: (val) =>
//       val == null || val.isEmpty ? 'Select a course' : null,
// ),

//                     SizedBox(height: 16),

//                      ElevatedButton(
//                       onPressed: () async {
//                         if (!_formKey.currentState!.validate()) return;
            
//                         try {
//                           if (isEdit && docId != null) {
//                             // update existing user
//                             await FirebaseFirestore.instance
//                                 .collection('users')
//                                 .doc(docId)
//                                 .update({
//                               'name': _nameController.text.trim(),
//                               'email': _emailController.text.trim(),
//                               'phone': _phoneController.text.trim(),
//                               'role': _role,
//                               'course': _selectedCourse,
//                             });
//                           } else {
//                             // create new user
//                             UserCredential userCredential = await FirebaseAuth
//                                 .instance
//                                 .createUserWithEmailAndPassword(
//                                   email: _emailController.text.trim(),
//                                   password: _passwordController.text.trim(),
//                                 );
//                             final uid = userCredential.user!.uid;
            
//                             final snapshot = await FirebaseFirestore.instance
//                                 .collection('users')
//                                 .orderBy('customId', descending: true)
//                                 .limit(1)
//                                 .get();
//                             String newCustomId = "Tek001";
//                             if (snapshot.docs.isNotEmpty) {
//                               String lastId = snapshot.docs.first['customId'];
//                               int lastNum =
//                                   int.parse(lastId.replaceAll(RegExp(r'[^0-9]'), ''));
//                               newCustomId =
//                                   "Tek${(lastNum + 1).toString().padLeft(3, '0')}";
//                             }
            
//                             await FirebaseFirestore.instance
//                                 .collection('users')
//                                 .doc(uid)
//                                 .set({
//                               'uid': uid,
//                               'name': _nameController.text.trim(),
//                               'customId': newCustomId,
//                               'email': _emailController.text.trim(),
//                               'phone': _phoneController.text.trim(),
//                               'password': _passwordController.text.trim(),
//                               'role': _role,
//                               'course': _selectedCourse,
//                             });
//                           }
            
//                           Navigator.pop(ctx);
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                                 content: Text(isEdit
//                                     ? "User updated successfully"
//                                     : "User added successfully")),
//                           );
//                         } catch (e) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text("Error: $e")),
//                           );
//                         }
//                       },
//                       child: Text(isEdit ? "Update" : "Add"),
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
//         appBar: AppBar(title: Text('Users')),
//         body: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8),
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   labelText: 'Search by email, name, or ID',
//                   prefixIcon: Icon(Icons.search),
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance.collection('users').snapshots(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData)
//                     return Center(child: CircularProgressIndicator());

//                   final docs = snapshot.data!.docs;
//                   final filteredDocs = docs.where((doc) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     final email = data['email']?.toString().toLowerCase() ?? '';
//                     final name = data['name']?.toString().toLowerCase() ?? '';
//                     final customId = data['customId']?.toString().toLowerCase() ?? '';
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
//                         margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                         child: ListTile(
//                           title: Text('${data['customId']} - ${data['email']}'),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Phone: ${data['phone']} | Role: ${data['role']}'),
//                               Text('Course: ${data['course'] ?? 'N/A'}'),
//                               Text('Password: ${data['password']}'),
//                               Text('Name: ${data['name']}'),
//                             ],
//                           ),
//                           trailing: IconButton(
//                             icon: Icon(Icons.edit),
//                             onPressed: () => _showUserFormBottomSheet(
//                               context,
//                               isEdit: true,
//                               docId: user.id,
//                               userData: data,
//                             ),
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
// }  in thi scode working amazing i want add one mor elogi clik ewhenever iamdding new employe that tim eiamslect corse lik eflutter and clcik addbbutton that time i want in my course collectio i want  update the  no-ofcount vale +1 insde my course 