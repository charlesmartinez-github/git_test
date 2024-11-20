import 'package:finedger/providers/account_provider.dart';
import 'package:finedger/screens/navigation_pages/navigation.dart';
import 'package:finedger/services/firebase_auth_services.dart';
import 'package:flutter/material.dart';
import 'package:finedger/widgets/for_gettingstarted.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'signup_page.dart';
import 'package:finedger/constants/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? validateEmail(String? email) {
    RegExp emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    final isEmailValid = emailRegex.hasMatch(email ?? '');
    if (email!.isEmpty) {
      return 'Email is required';
    }
    if (!isEmailValid) {
      return 'Please enter a valid email';
    }
    return null;
  }

  bool isChecked = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Container(
                //color: Colors.redAccent,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.10,
                  vertical: screenHeight * 0.05,
                ),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      'images/finedger_logo.png',
                      width: 200.0,
                      height: 200.0,
                    ),
                    LoginForm(
                      controller: _emailController,
                      validator: validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                      hintText: 'Email',
                      enableSuggestions: true,
                      autoCorrect: true,
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    LoginForm(
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      hintText: 'Password',
                      enableSuggestions: false,
                      autoCorrect: false,
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    LargeButton(
                      //Login Button
                      onPress: () {
                        if (_formKey.currentState!.validate()) {
                          _signIn(context);
                        }
                      },
                      buttonLabel: 'Login',
                      backgroundColor: kBlueColor,
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    const Text('or Sign up to get started'),
                    SizedBox(height: screenHeight * 0.005),
                    LargeButton(
                        onPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return const SignupPage();
                              },
                            ),
                          );
                        },
                        buttonLabel: 'Sign Up',
                        backgroundColor: kGreenColor),
                    SizedBox(height: screenHeight * 0.005),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: CheckboxListTile(
                            checkColor: Colors.white,
                            activeColor: const Color(0xff30437a),
                            title: const Text(
                              'Remember me',
                              style: TextStyle(fontSize: 11.0),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            value: isChecked,
                            onChanged: (bool? value) {
                              setState(
                                () {
                                  isChecked = value!;
                                },
                              );
                            },
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                                color: Color(0xff30437a), fontSize: 11.0),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                      child: const FederatedIdentitySignInButton(
                        icon: Icon(FontAwesomeIcons.google),
                        label: 'Continue with Google',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                      child: const FederatedIdentitySignInButton(
                        icon: Icon(FontAwesomeIcons.apple),
                        label: 'Continue with Apple',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                      child: const FederatedIdentitySignInButton(
                        icon: Icon(FontAwesomeIcons.facebook),
                        label: 'Continue with Facebook',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _signIn(BuildContext context) async {
    final user = await _auth.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (user != null) {
      // Check if the widget is still mounted

      if (context.mounted) {
        context.read<AccountProvider>().setSelectedAccount(null);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return const Navigation(passedPageIndex: 0);
            },
          ),
        );
      }
    }
  }
}
