
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekort/Presentation/auth/login.dart';
import 'package:tekort/Providers/employeeprovider.dart';
import 'package:tekort/core/core/common/loading.dart';
import 'package:tekort/core/core/themes/themeprovider/themeprovider.dart';
import 'package:tekort/core/core/utils/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}
class _AccountScreenState extends State<AccountScreen> {
  String? profileImageUrl;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EmployeeProvider>(context, listen: false);
      if (provider.name == null ||
          provider.email == null ||
          provider.customId == null) {
        provider.fetchEmployeeDetails();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final employee = Provider.of<EmployeeProvider>(context);
    final themeprovider = Provider.of<ThemeSwitch>(context, listen: false);
    if (employee.isLoading) {
      return Scaffold(body: Center(child: loadingWidget()));
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.22,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: backgroundcolor, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color.fromARGB(255, 223, 238, 228),
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl!)
                          : null,
                      child: profileImageUrl == null
                          ? Text(
                              employee.name != null && employee.name!.isNotEmpty
                                  ? employee.name![0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: blackColor,
                              ),
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.name ?? 'no user',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: backgroundcolor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          employee.email ?? 'N/A',
                          style: TextStyle(
                            fontSize: 14,
                            color: backgroundcolor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMenuItem(
                      icon: Icons.person_2_outlined,
                      title: 'Profile Details',
                      onTap: () {
                        _showPersonalBottomSheet();
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.support_agent_outlined,
                      title: 'Support',
                      onTap: () {
                        _showSupportBottomSheet();
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.logout_outlined,
                      title: 'Logout',
                      isDestructive: true,
                      onTap: () {
                        _showLogoutDialog();
                      },
                    ),
                    _buildMenuItem(
  icon: Icons.info_outline,
  title: 'How to Use This App',
  onTap: () {
    _showInstructionsBottomSheet();
  },
),                    _buildMenuItemWithSwitch(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      value: themeprovider.isDarkMode,
                      onChanged: (value) {
                        themeprovider.switchThemeData(!value);
                      },
                    ),                      Center(
                        child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: socialMediaList
                                            .map(
                        (item) => Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: _buildSocialIcon(context, item),
                        ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                      ),                  ],
                ),
              ),
            ),
            SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        icon,
        color: isDestructive ?  Colors.grey[700] : Colors.grey[700],
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey[400],
        size: 16,
      ),
      onTap: onTap,
    );
  }
  Widget _buildMenuItemWithSwitch({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: Colors.grey[700], size: 24),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: primaryColor,
        inactiveThumbColor: primaryColor,
      ),
    );
  }
  Widget _buildDetailRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(child: Text(value, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
  void _showPersonalBottomSheet() {
    final employee = Provider.of<EmployeeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'Personal Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            _buildDetailRow(Icons.person, employee.name ?? 'N/A'),
            _buildDetailRow(Icons.email, employee.email ?? 'N/A'),
            _buildDetailRow(Icons.phone, employee.phoneno ?? 'N/A'),
            _buildDetailRow(
              Icons.lock,
              employee.password ?? '********',
            ), // Masked password
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  void _showSupportBottomSheet() {
    final employee = Provider.of<EmployeeProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Support',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              onTap: () {
                final email = "admin@tekort.in"?? '';
                if (email.isNotEmpty) {
                  launchUrl(Uri(scheme: 'mailto', path: email));
                }
              },
              leading: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.email, color: primaryColor),
              ),
              title: Text("admin@tekort.in" ?? 'No Email'),
              subtitle: Text('Email Support'),
            ),
            ListTile(
              onTap: () {
                const phoneNumber = '9385414405';
                launchUrl(Uri(scheme: 'tel', path: phoneNumber));
              },
              leading: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.phone, color: primaryColor),
              ),
              title: Text('9385414405'),
              subtitle: Text('Phone Support'),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
void _showInstructionsBottomSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'How to Use the Tekort App',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildInstructionPoint("1. Login using your registered email or credentials."),
            _buildInstructionPoint("2. On the Home screen, view your assigned courses."),
            _buildInstructionPoint("3. You'll see course progress and task completion status."),
            _buildInstructionPoint("4. Use the top-left button to Punch In and Punch Out once per day."),
            _buildInstructionPoint("5. Once both are done for the day, Punch buttons are hidden."),
            _buildInstructionPoint("6. For any queries, contact admin at: admin@tekort.in."),
            _buildInstructionPoint("7. If you've forgotten your password, reach out via call or email."),
            SizedBox(height: 20),
            Text(
              'About Tekort',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Tekort is a training and task management platform designed to streamline employee onboarding, course tracking, and attendance. It provides a structured interface to monitor progress and simplify communication with the admin team.",
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    ),
  );
}
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
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
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
socialMedialWidget(BuildContext context, bool isDark) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      GestureDetector(
        onTap: () => openApp(
          context,
          'Facebook',
          'https://www.facebook.com/profile.php?id=61570709564641',
          'https://play.google.com/store/apps/details?id=com.facebook.katana',
        ),
        child: Image.asset("assets/Facebook.png", height: 25.0, width: 25.0),
      ),
      SizedBox(width: 8),
      GestureDetector(
        onTap: () => openApp(
          context,
          'WhatsApp',
          'https://wa.me/message/SZGOAAP6RSDVN1',
          'https://play.google.com/store/apps/details?id=com.whatsapp',
        ),
        child: Image.asset("assets/Whatsapp.png", height: 25.0, width: 25.0),
      ),
      SizedBox(width: 8),
      GestureDetector(
        onTap: () => openApp(
          context,
          'Instagram',
          'instagram://user?username=flattradein',
          'https://play.google.com/store/apps/details?id=com.instagram',
        ),
        child: Image.asset("assets/Insta.png", height: 25.0, width: 25.0),
      ),
      SizedBox(width: 8),
      GestureDetector(
        onTap: () => openApp(
          context,
          'LinkedIn',
          'https://www.linkedin.com/company/tekort/',
          'https://play.google.com/store/apps/details?id=com.linkedin.android',
        ),
        child: Image.asset("assets/Linkedin.png", height: 25.0, width: 25.0),
      ),
      SizedBox(width: 8),
      GestureDetector(
        onTap: () => openApp(
          context,
          'Instagram',
          'https://www.instagram.com/tekort_official/',
          'https://play.google.com/store/apps/details?id=com.instagram.android',
        ),
        child: Image.asset("assets/Twitter.png", height: 25.0, width: 25.0),
      ),
      SizedBox(width: 8),
    ],
  );
}
void openApp(
  BuildContext context,
  String appName,
  String appUrl,
  String playStoreUrl,
) async {
  try {
    if (await launchUrl(Uri.parse(appUrl))) {
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('App Not Installed'),
            content: Text('The $appName app is not installed on your device.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Launch Play Store URL
                  launchUrl(Uri.parse(playStoreUrl));
                },
                child: const Text('Install from Play Store'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('App Not Installed'),
          content: Text('The $appName app is not installed on your device.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Launch Play Store URL
                launchUrl(Uri.parse(playStoreUrl));
              },
              child: const Text('Install from Play Store'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
class SocialMediaEntry {
  final String label;
  final IconData? iconData; // For Icons
  final String? iconAsset; // For image assets
  final String appUrl;
  final String playStoreUrl;

  SocialMediaEntry({
    required this.label,
    this.iconData,
    this.iconAsset,
    required this.appUrl,
    required this.playStoreUrl,
  });
}
final List<SocialMediaEntry> socialMediaList = [
  SocialMediaEntry(
    label: 'Facebook',
    iconData: Icons.facebook,
    appUrl: 'https://www.facebook.com/profile.php?id=61570709564641',
    playStoreUrl:
        'https://play.google.com/store/apps/details?id=com.facebook.katana',
  ),
  SocialMediaEntry(
    label: 'WhatsApp',
    iconAsset: 'assets/images/whatsapp.png',
    appUrl: 'https://wa.me/message/SZGOAAP6RSDVN1',
    playStoreUrl: 'https://play.google.com/store/apps/details?id=com.whatsapp',
  ),
  SocialMediaEntry(
    label: 'Instagram',
    iconAsset: 'assets/images/instagram.png',
    appUrl: 'instagram://user?username=flattradein',
    playStoreUrl: 'https://play.google.com/store/apps/details?id=com.instagram',
  ),
  SocialMediaEntry(
    label: 'LinkedIn',
    iconAsset: 'assets/images/linked-in.png',
    appUrl: 'https://www.linkedin.com/company/tekort/',
    playStoreUrl:
        'https://play.google.com/store/apps/details?id=com.linkedin.android',
  ),
  SocialMediaEntry(
    label: 'Website',
    iconData: Icons.language,
    appUrl: 'http://tekort.in/',
    playStoreUrl:
        'https://play.google.com/store/apps/details?id=com.android.chrome',
  ),
];
Widget _buildSocialIcon(BuildContext context, SocialMediaEntry item) {
  return GestureDetector(
    onTap: () => openApp(context, item.label, item.appUrl, item.playStoreUrl),
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: item.iconAsset != null
              ? Image.asset(item.iconAsset!, height: 20, width: 20)
              : Icon(item.iconData, size: 20, color: primaryColor),
        ),
        SizedBox(height: 5),
        Text(item.label, style: TextStyle(fontSize: 10)),
      ],
    ),
  );
}
Widget _buildInstructionPoint(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ", style: TextStyle(fontSize: 16)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ),
      ],
    ),
  );
}