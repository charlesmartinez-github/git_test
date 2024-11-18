import 'package:email_otp/email_otp.dart';

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
      print('OTP Sent');
    } else {
      print('Error');
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