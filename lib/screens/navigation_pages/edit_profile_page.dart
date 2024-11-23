import 'package:finedger/widgets/for_gettingstarted.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class EditProfilePage extends StatefulWidget {
  final String userId; // Pass user ID to the page

  const EditProfilePage({super.key, required this.userId});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // final List<String> countries = [...]; // Keep your countries list here

  // Controllers for the text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  // Key to uniquely identify the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Store the selected phone number and ISO code
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'PH');

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Function to load the user data from Firestore
  void _loadUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

    if (userDoc.exists) {
      setState(() {
        _firstNameController.text = userDoc['firstName'] ?? '';
        _lastNameController.text = userDoc['lastName'] ?? '';
        _labelController.text = userDoc['label'] ?? '';
        _phoneNumberController.text = userDoc['phoneNumber'] ?? '';
      });
    }
  }

  // Function to update the user data in Firestore
  void _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'label': _labelController.text,
          'phoneNumber': _phoneNumber.phoneNumber,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit profile'),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              top: screenWidth * 0.05,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    height: screenHeight * 0.073,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: "First name",
                        labelStyle: TextStyle(fontSize: 13.0),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    height: screenHeight * 0.073,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: "Last Name",
                        labelStyle: TextStyle(fontSize: 13.0),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    height: screenHeight * 0.073,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: TextFormField(
                      controller: _labelController,
                      decoration: const InputDecoration(
                        labelText: "Label",
                        labelStyle: TextStyle(fontSize: 13.0),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            _phoneNumber = number;
                          },
                          initialValue: _phoneNumber,
                          textFieldController: _phoneNumberController,
                          selectorConfig: const SelectorConfig(
                            trailingSpace: false,
                            selectorType: PhoneInputSelectorType.DIALOG,
                          ),
                          countries: const ['PH'], // Only allow phone numbers from the Philippines
                          inputDecoration: const InputDecoration(
                            isDense: true,
                            labelText: 'Phone Number',
                            floatingLabelStyle: TextStyle(fontSize: 13.0),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          formatInput: false,
                          validator: (value) {
                            // Custom validator to ensure the phone number is not empty or invalid
                            if (value == null || value.isEmpty || value.length != 10) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  SmallButton(
                    buttonLabel: 'SUBMIT',
                    onPress: _updateUserData,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
