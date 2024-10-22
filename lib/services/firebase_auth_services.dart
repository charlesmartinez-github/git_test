import 'dart:developer';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      log('Something went wrong');
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      log('Something went wrong');
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log('Something went wrong');
    }
  }
}

class EmailOTPSender {
  EmailOTP myOtp = EmailOTP();
  Future<void> sendOTPto(String email) async {
    EmailOTP.config(
        appEmail: 'finedger@email.com',
        appName: 'FinEdger',
        otpLength: 6,
        emailTheme: EmailTheme.v1,
        //expiry: 300000
    );
    var sendOTP = await EmailOTP.sendOTP(email: email);
    if (sendOTP) {
      log('OTP Sent');
    } else {
      log('Error');
    }
  }

  Future<bool> verifyOTP(String otp) async {
    if (EmailOTP.verifyOTP(otp: otp)) {
      return true;
    } else {
      return false;
    }
  }

  String? getOTP() {
    return EmailOTP.getOTP();
  }

}
