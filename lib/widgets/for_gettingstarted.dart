import 'package:flutter/material.dart';
import 'package:finedger/constants/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  const ButtonText({super.key, required this.onPress, required this.buttonLabel});

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

class OTPForm extends StatefulWidget {
  const OTPForm({
    super.key,
    required this.controller,
    required this.validator,
    required this.keyboardType,
    required this.labelText,
  });

  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final TextInputType keyboardType;
  final String labelText;

  @override
  State<OTPForm> createState() => _OTPFormState();
}

class _OTPFormState extends State<OTPForm> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      autovalidateMode: AutovalidateMode.onUnfocus,
      decoration: InputDecoration(
        labelText: widget.labelText,
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
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
    required this.controller,
    required this.validator,
    required this.keyboardType,
    required this.obscureText,
    required this.labelText,
    this.showSuffixIcon = false,
  });

  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final String labelText;
  final bool showSuffixIcon;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool _obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: widget.showSuffixIcon ? _obscurePassword : widget.obscureText,
      autovalidateMode: AutovalidateMode.onUnfocus,
      decoration: InputDecoration(
        suffixIcon: widget.showSuffixIcon
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
                ),
              )
            : null,
        labelText: widget.labelText,
        errorMaxLines: 2,
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
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.controller,
    required this.validator,
    required this.keyboardType,
    required this.obscureText,
    required this.hintText,
    required this.enableSuggestions,
    required this.autoCorrect,
  });

  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final bool enableSuggestions;
  final bool autoCorrect;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      child: TextFormField(
        validator: widget.validator,
        controller: widget.controller,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        enableSuggestions: widget.enableSuggestions,
        autocorrect: widget.autoCorrect,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          border: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: kGrayColor, fontSize: 15.0),
          contentPadding: const EdgeInsets.fromLTRB(15.0, 8.0, 8.0, 8.0),
        ),
      ),
    );
  }
}

class FederatedIdentitySignInButton extends StatelessWidget {
  const FederatedIdentitySignInButton({
    super.key,
    required this.icon,
    required this.label, required this.onPressed,
  });

  final Icon icon;
  final String label;
  final VoidCallback onPressed;

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
        onPressed: onPressed,
      ),
    );
  }
}

class SmallButton extends StatelessWidget {
  const SmallButton({
    super.key,
    required this.buttonLabel,
    required this.onPress,
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
    super.key,
    required this.keyboardType,
    required this.hintText,
    required this.obscureText,
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
