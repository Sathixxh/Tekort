import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekort/Presentation/auth/login.dart';
import 'package:tekort/Providers/employeeprovider.dart';
import 'package:tekort/core/core/common/loading.dart';
import 'package:tekort/core/core/themes/themeprovider/themeprovider.dart';
import 'package:tekort/core/core/utils/styles.dart';
import 'package:tekort/main.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});
  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? profileImageUrl;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EmployeeProvider>(context, listen: false);
      if (provider.name == null ||
          provider.email == null ||
          provider.customId == null) {
        provider
            .fetchEmployeeDetails(); // only fetch if data not already available
      }
    });
  }

  Widget build(BuildContext context) {
    final employee = Provider.of<EmployeeProvider>(context);
    final themeprovider = Provider.of<ThemeSwitch>(context, listen: false);
    if (employee.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Drawer(
      width: MediaQuery.of(context).size.height * 0.4,
      backgroundColor: themeprovider.isDarkMode ? blackColor : backgroundcolor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: primaryColor,
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(4), // Border effect
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: backgroundcolor, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: const Color.fromARGB(
                        255,
                        255,
                        255,
                        255,
                      ).withOpacity(0.1),
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl!)
                          : null,
                      child: profileImageUrl == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: const Color.fromARGB(255, 255, 255, 255),
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    employee.name!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: backgroundcolor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 5),
                  Text(
                    employee.email!,
                    style: TextStyle(
                      fontSize: 14,
                      color: backgroundcolor,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    employee.customId!,
                    style: TextStyle(
                      fontSize: 14,
                      color: backgroundcolor,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.brightness_6),
                    title: Text("Theme", style: TextStyle()),
                    trailing: Consumer<ThemeSwitch>(
                      builder: (context, themeProvider, child) {
                        return Switch(
                          value: themeProvider.isLightMode,
                          onChanged: (value) {
                            themeProvider.switchThemeData(value);
                          },
                          activeColor: primaryColor, // Light mode icon color
                          inactiveThumbColor:
                              Colors.grey.shade300, // Dark mode icon color
                        );
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text("Logout", style: TextStyle()),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('uid');
                      await prefs.remove('email');
                      await prefs.remove('role');
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      );
                    },
                  ),
                  ExpansionTile(
                    leading: Icon(Icons.support_agent),
                    title: Text("Suppo22rt", style: TextStyle()),
                    children: [
                      ListTile(
                        leading: Icon(Icons.email),
                        title: Text(
                          employee.email ?? 'No Email',
                          style: TextStyle(),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.phone),
                        title: Text("9385414405", style: TextStyle()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.abc),
                  Icon(Icons.facebook),
                  Icon(Icons.email),
                  Icon(
                    Icons.linked_camera,
                  ), // can replace with LinkedIn SVG/icon
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




  // void _showSocialMediaBottomSheet() {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) => Container(
      
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //               SizedBox(height: 20),
  //           Text(
  //             'Follow us on Social Media',
  //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //           ),
  //           SizedBox(height: 20),

  //           SingleChildScrollView(
  //             scrollDirection: Axis.horizontal,
  //             child: Row(
  //               children: socialMediaList
  //                   .map(
  //                     (item) => Padding(
  //                       padding: const EdgeInsets.all(18.0),
  //                       child: _buildSocialIcon(context, item),
  //                     ),
  //                   )
  //                   .toList(),
  //             ),
  //           ),

  //           SizedBox(height: 20),
  //         ],
  //       ),
  //     ),
  //   );
  // }




  // in below code logic vise working perfelty so main requiremnt is ui design wiith animation so iwant amzing animation with clean and neet and super an fd fabulur animation and ui iwant with theme vise light mode and dark mode