import 'package:finedger/constants/constants.dart';
import 'package:finedger/widgets/for_gettingstarted.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isCurrentPasswordHidden = true;
  bool _isNewPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  Future<void> _changePassword() async {
    try {
      // Step 1: Reauthenticate the user
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("No user currently signed in");
      }

      String email = user.email!;
      String currentPassword = _currentPasswordController.text;

      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Step 2: Update the password
      String newPassword = _newPasswordController.text;
      String confirmPassword = _confirmPasswordController.text;

      if (newPassword.isEmpty || confirmPassword.isEmpty) {
        throw Exception("New password fields cannot be empty");
      }

      if (newPassword != confirmPassword) {
        throw Exception("New password and confirmation do not match");
      }

      await user.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );

      // Clear text fields after successful update
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters long";
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return "Password must contain at least one uppercase letter";
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return "Password must contain at least one lowercase letter";
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return "Password must contain at least one numeric character";
    }
    if (!value.contains(RegExp(r'[!@#$%^&*()<>?/|}{~:]'))) {
      return "Password must contain at least one special character";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text('Change Password'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            top: screenWidth * 0.05,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Current password',
                  style: TextStyle(fontSize: 15.0),
                ),
                const SizedBox(height: 4.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: TextFormField(
                    controller: _currentPasswordController,
                    decoration: InputDecoration(
                      hintText: 'Enter current password',
                      hintStyle: const TextStyle(
                        color: kGrayColor,
                        fontWeight: FontWeight.normal,
                      ),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(_isCurrentPasswordHidden
                            ? FontAwesomeIcons.eye
                            : FontAwesomeIcons.eyeSlash),
                        onPressed: () {
                          setState(() {
                            _isCurrentPasswordHidden = !_isCurrentPasswordHidden;
                          });
                        },
                      ),
                    ),
                    obscureText: _isCurrentPasswordHidden,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Current password is required";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                const Text('New password'),
                const SizedBox(height: 4.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      hintText: 'min. 8 characters',
                      hintStyle: const TextStyle(
                        color: kGrayColor,
                        fontWeight: FontWeight.normal,
                      ),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(_isNewPasswordHidden
                            ? FontAwesomeIcons.eye
                            : FontAwesomeIcons.eyeSlash),
                        onPressed: () {
                          setState(() {
                            _isNewPasswordHidden = !_isNewPasswordHidden;
                          });
                        },
                      ),
                    ),
                    obscureText: _isNewPasswordHidden,
                    validator: _passwordValidator,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                const Text('Confirm password'),
                const SizedBox(height: 4.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      hintText: 'Confirm password',
                      hintStyle: const TextStyle(
                        color: kGrayColor,
                        fontWeight: FontWeight.normal,
                      ),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(_isConfirmPasswordHidden
                            ? FontAwesomeIcons.eye
                            : FontAwesomeIcons.eyeSlash),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                          });
                        },
                      ),
                    ),
                    obscureText: _isConfirmPasswordHidden,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Confirm password is required";
                      }
                      if (value != _newPasswordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                SmallButton(
                  buttonLabel: 'SAVE',
                  onPress: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _changePassword();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
