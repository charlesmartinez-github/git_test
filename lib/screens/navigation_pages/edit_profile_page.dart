import 'package:finedger/widgets/for_gettingstarted.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final List<String> countries = [
    'Afghanistan',
    'Albania',
    'Algeria',
    'Andorra',
    'Angola',
    'Antigua and Barbuda',
    'Argentina',
    'Armenia',
    'Australia',
    'Austria',
    'Azerbaijan',
    'Bahamas',
    'Bahrain',
    'Bangladesh',
    'Barbados',
    'Belarus',
    'Belgium',
    'Belize',
    'Benin',
    'Bhutan',
    'Bolivia',
    'Bosnia and Herzegovina',
    'Botswana',
    'Brazil',
    'Brunei',
    'Bulgaria',
    'Burkina Faso',
    'Burundi',
    'Cabo Verde',
    'Cambodia',
    'Cameroon',
    'Canada',
    'Central African Republic',
    'Chad',
    'Chile',
    'China',
    'Colombia',
    'Comoros',
    'Congo (Congo-Brazzaville)',
    'Costa Rica',
    'Croatia',
    'Cuba',
    'Cyprus',
    'Czechia (Czech Republic)',
    'Democratic Republic of the Congo',
    'Denmark',
    'Djibouti',
    'Dominica',
    'Dominican Republic',
    'Ecuador',
    'Egypt',
    'El Salvador',
    'Equatorial Guinea',
    'Eritrea',
    'Estonia',
    'Eswatini (fmr. "Swaziland")',
    'Ethiopia',
    'Fiji',
    'Finland',
    'France',
    'Gabon',
    'Gambia',
    'Georgia',
    'Germany',
    'Ghana',
    'Greece',
    'Grenada',
    'Guatemala',
    'Guinea',
    'Guinea-Bissau',
    'Guyana',
    'Haiti',
    'Honduras',
    'Hungary',
    'Iceland',
    'India',
    'Indonesia',
    'Iran',
    'Iraq',
    'Ireland',
    'Israel',
    'Italy',
    'Jamaica',
    'Japan',
    'Jordan',
    'Kazakhstan',
    'Kenya',
    'Kiribati',
    'Kuwait',
    'Kyrgyzstan',
    'Laos',
    'Latvia',
    'Lebanon',
    'Lesotho',
    'Liberia',
    'Libya',
    'Liechtenstein',
    'Lithuania',
    'Luxembourg',
    'Madagascar',
    'Malawi',
    'Malaysia',
    'Maldives',
    'Mali',
    'Malta',
    'Marshall Islands',
    'Mauritania',
    'Mauritius',
    'Mexico',
    'Micronesia',
    'Moldova',
    'Monaco',
    'Mongolia',
    'Montenegro',
    'Morocco',
    'Mozambique',
    'Myanmar (formerly Burma)',
    'Namibia',
    'Nauru',
    'Nepal',
    'Netherlands',
    'New Zealand',
    'Nicaragua',
    'Niger',
    'Nigeria',
    'North Korea',
    'North Macedonia',
    'Norway',
    'Oman',
    'Pakistan',
    'Palau',
    'Panama',
    'Papua New Guinea',
    'Paraguay',
    'Peru',
    'Philippines',
    'Poland',
    'Portugal',
    'Qatar',
    'Romania',
    'Russia',
    'Rwanda',
    'Saint Kitts and Nevis',
    'Saint Lucia',
    'Saint Vincent and the Grenadines',
    'Samoa',
    'San Marino',
    'Sao Tome and Principe',
    'Saudi Arabia',
    'Senegal',
    'Serbia',
    'Seychelles',
    'Sierra Leone',
    'Singapore',
    'Slovakia',
    'Slovenia',
    'Solomon Islands',
    'Somalia',
    'South Africa',
    'South Korea',
    'South Sudan',
    'Spain',
    'Sri Lanka',
    'Sudan',
    'Suriname',
    'Sweden',
    'Switzerland',
    'Syria',
    'Taiwan',
    'Tajikistan',
    'Tanzania',
    'Thailand',
    'Timor-Leste',
    'Togo',
    'Tonga',
    'Trinidad and Tobago',
    'Tunisia',
    'Turkey',
    'Turkmenistan',
    'Tuvalu',
    'Uganda',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States of America',
    'Uruguay',
    'Uzbekistan',
    'Vanuatu',
    'Vatican City',
    'Venezuela',
    'Vietnam',
    'Yemen',
    'Zambia',
    'Zimbabwe'
  ];

  String? _selectedValueGender;
  String? _selectedValueCountry;
  // Key to uniquely identify the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Store the selected phone number and ISO code
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'PH');

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
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              top: screenWidth * 0.05,
            ),
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
                    decoration: const InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(fontSize: 13.0),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: InputBorder.none,
                    ),
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
                    decoration: const InputDecoration(
                      labelText: "Label",
                      labelStyle: TextStyle(fontSize: 13.0),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Form(
                  key: _formKey,
                  child: Container(
                    height: screenHeight * 0.073,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Column(
                      children: [
                        // InternationalPhoneNumberInput widget
                        // for phone number input
                        InternationalPhoneNumberInput(
                          // Callback for when the input changes
                          onInputChanged: (PhoneNumber number) {
                            _phoneNumber = number;
                          },
                          // Callback for when the input is validated
                          onInputValidated: (bool value) {
                            // You can perform additional validation here if needed
                          },
                          // Configuration for the country selector
                          selectorConfig: const SelectorConfig(
                            trailingSpace: false,
                            selectorType: PhoneInputSelectorType.DIALOG,
                          ),
                          // Ignore blank input
                          ignoreBlank: false,
                          // Auto-validation mode
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          // Style for the country selector
                          selectorTextStyle: const TextStyle(color: Colors.black),
                          // Initial value for the phone number input
                          initialValue: _phoneNumber,
                          // Controller for the text field
                          textFieldController: TextEditingController(),
                          // Decoration for the input field
                          inputDecoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              labelText: 'Phone Number',
                              floatingLabelStyle: TextStyle(fontSize: 13.0),
                              floatingLabelBehavior: FloatingLabelBehavior.always),
                          // Format input (e.g., adding spaces between digits)
                          formatInput: false,
                        ),
                      ],
                    ),
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
                  child: DropdownButtonFormField(
                    items: const [],
                    onChanged: (value) {},
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelStyle: TextStyle(fontSize: 13.0),
                        labelText: 'Country',
                        floatingLabelBehavior: FloatingLabelBehavior.always),
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
                  child: DropdownButtonFormField(
                    items: const [],
                    onChanged: (value) {},
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelStyle: TextStyle(fontSize: 13.0),
                        labelText: 'Gender',
                        floatingLabelBehavior: FloatingLabelBehavior.always),
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
                    decoration: const InputDecoration(
                      labelText: "Address",
                      labelStyle: TextStyle(fontSize: 13.0),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                SmallButton(buttonLabel: 'SUBMIT', onPress: () {})
              ],
            ),
          ),
        ),
      ),
    );
  }
}
