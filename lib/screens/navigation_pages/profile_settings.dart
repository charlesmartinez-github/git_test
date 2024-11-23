import 'package:finedger/screens/getting_started/login_page.dart';
import 'package:finedger/screens/navigation_pages/change_password_page.dart';
import 'package:finedger/screens/navigation_pages/contact_us_page.dart';
import 'package:finedger/screens/navigation_pages/edit_profile_page.dart';
import 'package:finedger/screens/navigation_pages/notification_page.dart';
import 'package:finedger/screens/navigation_pages/privacy_policy_page.dart';
import 'package:finedger/services/firebase_auth_services.dart';
import 'package:finedger/widgets/for_gettingstarted.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final _firebaseServices = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              top: screenWidth * 0.07,
            ),
            child: Column(
              children: <Widget>[
                FutureBuilder(
                    future: _firebaseServices.getUserFirstName(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: LinearProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text("Error: \${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("No data found"));
                      } else {
                        final userData = snapshot.data!;
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 65.0,
                              child: Text('${userData['firstName'][0]}${userData['lastName'][0]}', style: const TextStyle(fontSize: 40),),
                            ),
                            Text(
                              '${userData['firstName']} ${userData['lastName']}',
                              style: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                            ),
                            Text('${userData['email']}'),
                            Text('${userData['phoneNumber']}'),
                            const SizedBox(height: 20.0),
                          ],
                        );
                      }
                    }),
                Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  shadowColor: Colors.black,
                  child: Container(
                    //color: Colors.greenAccent,
                    margin: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Row(
                          children: <Widget>[
                            const Icon(Icons.newspaper),
                            TextButton(
                              style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              onPressed: () {
                                navigateToEditProfile(context);
                              },
                              child: const Text(
                                'Edit Profile Information',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            const Icon(FontAwesomeIcons.bell),
                            TextButton(
                              style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                                  return const NotificationPage();
                                }));
                              },
                              child: const Text(
                                'Notifications',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  shadowColor: Colors.black,
                  child: Container(
                    margin: const EdgeInsets.all(15.0),
                    //color: Colors.redAccent,
                    child: Column(
                      children: [
                        Row(
                          children: <Widget>[
                            const Icon(Icons.accessibility_new),
                            TextButton(
                              style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                                  return const PrivacyPolicyPage();
                                }));
                              },
                              child: const Text(
                                'Privacy Policy',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            const Icon(Icons.lock_outline_sharp),
                            TextButton(
                              style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                                  return const ChangePasswordPage();
                                }));
                              },
                              child: const Text(
                                'Change Password',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                SmallButton(
                    buttonLabel: 'SIGN OUT',
                    onPress: () {
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                        return const LoginPage();
                      }));
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  void navigateToEditProfile(BuildContext context) {
    // Get the currently logged-in user from Firebase Auth
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userId = currentUser.uid; // Get the user ID
      // Navigate to the EditProfilePage and pass the userId
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(userId: userId),
        ),
      );
    } else {
      // Handle the case when no user is logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is currently logged in')),
      );
    }
  }

}
