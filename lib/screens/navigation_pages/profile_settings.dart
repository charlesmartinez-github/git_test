import 'package:finedger/screens/getting_started/login_page.dart';
import 'package:finedger/screens/navigation_pages/change_password_page.dart';
import 'package:finedger/screens/navigation_pages/contact_us_page.dart';
import 'package:finedger/screens/navigation_pages/edit_profile_page.dart';
import 'package:finedger/screens/navigation_pages/notification_page.dart';
import 'package:finedger/screens/navigation_pages/privacy_policy_page.dart';
import 'package:finedger/widgets/for_gettingstarted.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
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
                CircleAvatar(
                  radius: 65.0,
                  backgroundImage: const AssetImage('images/logo.png'),
                  child: IconButton(
                      onPressed: () {}, icon: const Icon(Icons.edit)),
                ),
                const Text(
                  'Francis Oaquiera',
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                ),
                // const Text('francisgerald.oaquiera.dl@domain.com'),
                // const Text('+639479637899'),
                // const SizedBox(height: 20.0),
                Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
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
                              style: const ButtonStyle(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return const EditProfilePage();
                                }));
                              },
                              child: const Text(
                                'Edit Profile Information',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            const Icon(FontAwesomeIcons.bell),
                            TextButton(
                              style: const ButtonStyle(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return const NotificationPage();
                                }));
                              },
                              child: const Text(
                                'Notifications',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  shadowColor: Colors.black,
                  child: Container(
                    margin: const EdgeInsets.all(15.0),
                    //color: Colors.redAccent,
                    child: Column(
                      children: [
                        Row(
                          children: <Widget>[
                            const Icon(Icons.messenger_outline),
                            TextButton(
                              style: const ButtonStyle(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return const ContactUsPage();
                                }));
                              },
                              child: const Text(
                                'Contact Us',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            const Icon(Icons.lock_outline_sharp),
                            TextButton(
                              style: const ButtonStyle(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return const PrivacyPolicyPage();
                                }));
                              },
                              child: const Text(
                                'Privacy Policy',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  shadowColor: Colors.black,
                  child: Container(
                    margin: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Row(
                          children: <Widget>[
                            const Icon(Icons.accessibility_new),
                            TextButton(
                              style: const ButtonStyle(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return const ChangePasswordPage();
                                }));
                              },
                              child: const Text(
                                'Change Password',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            const Icon(FontAwesomeIcons.comment),
                            TextButton(
                              style: const ButtonStyle(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return const ContactUsPage();
                                }));
                              },
                              child: const Text(
                                'Send Feedback',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
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
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
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
}
