import 'package:flutter/material.dart';
import 'package:finedger/constants/constants.dart';

class LargeButton extends StatelessWidget {
  const LargeButton({
    super.key,
    required this.onPress,
    required this.buttonLabel,
    required this.backgroundColor,
  });

  final VoidCallback onPress;
  final String buttonLabel;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return SizedBox(
      // padding: const EdgeInsets.symmetric(
      //     vertical: 0.0, horizontal: 47.0),
      width: double.infinity,
      height: screenHeight * 0.06,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          backgroundColor: backgroundColor,
        ),
        onPressed: onPress,
        child: Text(
          buttonLabel,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class ButtonText extends StatelessWidget {
  const ButtonText(
      {super.key, required this.onPress, required this.buttonLabel});

  final String buttonLabel;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPress,
      child: Text(
        buttonLabel,
        style: const TextStyle(
          color: kBlueColor,
        ),
      ),
    );
  }
}

class SignUpForm extends StatelessWidget {
  const SignUpForm({
    super.key, required this.keyboardType, required this.labelText, required this.obscureText,
  });

  final TextInputType keyboardType;
  final String labelText;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        floatingLabelStyle: const TextStyle(
          color: kBlueColor,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: kBlueColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: kBlueColor,
          ),
        ),
        border: const OutlineInputBorder(),
        labelText: labelText,
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key, required this.hintText, required this.keyboardType, required this.obscureText,
  });

  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      child: TextFormField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration:  InputDecoration(
          fillColor: Colors.white,
          filled: true,
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: kGrayColor,
              fontSize: 15.0),
          contentPadding: const EdgeInsets.fromLTRB(15.0, 8.0, 8.0, 8.0),
        ),
      ),
    );
  }
}

class FederatedIdentitySignInButton extends StatelessWidget {
  const FederatedIdentitySignInButton({
    super.key, required this.icon, required this.label,
  });

  final Icon icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 33.0,
      child: OutlinedButton.icon(
        iconAlignment: IconAlignment.start,
        label: Text(
          label,
          style: const TextStyle(color: kGrayColor),
        ),
        icon: icon,
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.5),
              side: const BorderSide(color: kGrayColor),
            ),
          ),
        ),
        onPressed: () {},
      ),
    );
  }
}

class SmallButton extends StatelessWidget {
  const SmallButton({
    super.key, required this.buttonLabel, required this.onPress,
  });

  final String buttonLabel;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          backgroundColor: kLightBlueColor,
        ),
        onPressed: onPress,
        child: Text(
          buttonLabel,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class ChangePasswordForm extends StatelessWidget {
  const ChangePasswordForm({
    super.key, required this.keyboardType, required this.hintText, required this.obscureText,
  });

  final TextInputType keyboardType;
  final String hintText;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return SizedBox(
      height: screenHeight * 0.073,
      child: TextFormField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          floatingLabelStyle: const TextStyle(
            color: kBlueColor,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
              color: kBlueColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
              color: Colors.red,
            ),
          ),
          border: const OutlineInputBorder(),
          hintText: hintText,
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
        ),
      ),
    );
  }
}