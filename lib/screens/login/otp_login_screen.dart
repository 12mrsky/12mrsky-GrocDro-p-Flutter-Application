import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OtpLoginScreen extends StatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController otpCtrl = TextEditingController();

  bool otpSent = false;
  bool loading = false;
  String verificationId = "";

  @override
  void dispose() {
    phoneCtrl.dispose();
    otpCtrl.dispose();
    super.dispose();
  }

  /// 📲 SEND OTP
  Future<void> sendOtp() async {
    if (phoneCtrl.text.length != 10) {
      _error("Enter valid 10 digit mobile number");
      return;
    }

    setState(() => loading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91${phoneCtrl.text.trim()}",
      verificationCompleted: (credential) async {
        await FirebaseAuth.instance
            .signInWithCredential(credential);
      },
      verificationFailed: (e) {
        _error(e.message ?? "OTP failed");
        setState(() => loading = false);
      },
      codeSent: (vid, _) {
        setState(() {
          verificationId = vid;
          otpSent = true;
          loading = false;
        });
      },
      codeAutoRetrievalTimeout: (vid) {
        verificationId = vid;
      },
    );
  }

  /// 🔐 VERIFY OTP
  Future<void> verifyOtp() async {
    if (otpCtrl.text.length != 6) {
      _error("Enter valid 6 digit OTP");
      return;
    }

    setState(() => loading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCtrl.text.trim(),
      );

      await FirebaseAuth.instance
          .signInWithCredential(credential);
    } catch (_) {
      _error("Invalid OTP");
      setState(() => loading = false);
    }
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text("Login with OTP"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter your mobile number",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "We will send you a verification code",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            /// 📱 PHONE FIELD
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                prefixText: "+91 ",
                hintText: "Mobile number",
                counterText: "",
                filled: true,
                fillColor: const Color(0xffF4F5F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            if (otpSent) ...[
              const SizedBox(height: 16),

              /// 🔢 OTP FIELD
              TextField(
                controller: otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: "Enter OTP",
                  counterText: "",
                  filled: true,
                  fillColor: const Color(0xffF4F5F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 30),

            /// 🟡 ACTION BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                    loading ? null : (otpSent ? verifyOtp : sendOtp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffF7CB45),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        otpSent ? "Verify OTP" : "Send OTP",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
