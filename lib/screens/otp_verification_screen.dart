import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/auth_provider.dart';
import '../services/services_user.dart';
import 'landing_screen.dart';
import 'main_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({Key? key, this.number}) : super(key: key);
  final String? number;
  static const String id = 'otp-verify-screen';

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late String smsOtp;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationCode = "";
  bool isLoading = false;
  final UserServices _userServices = UserServices();
  DocumentSnapshot? documentSnapshot;
  late String _currentScreen;

  Future verifyPhoneNumber() async {
    setState(() {
      isLoading = true;
    });
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: "${widget.number}",
        verificationCompleted: (PhoneAuthCredential credential) async {
          isLoading = false;
          await _auth.signInWithCredential(credential).then((value) async {
            showAlert("Verified");
          });
        },
        verificationFailed: (FirebaseAuthException exception) {
          isLoading = false;
          showAlert("Verification Failed");
        },
        codeSent: (String verificationId, int? forceRespondToken) {
          isLoading = false;
          showAlert("Verification Code Sent");
          setState(() {
            verificationCode = verificationId;
          });
          // smsOtpDialog(context, number);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          isLoading = false;
          setState(() {
            verificationCode = verificationId;
          });
        },
      );
    } catch (e) {
      showAlert("Error Occurred: ${e.toString()}");
      isLoading = false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    verifyPhoneNumber();
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    setState(() {
      _currentScreen = authProvider.currentScreen;
    });
    return Scaffold(
      backgroundColor: const Color.fromRGBO(178, 182, 231, 1.0),
      body: SingleChildScrollView(
        reverse: true,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(80),
                      bottomRight: Radius.circular(80))),
              height: MediaQuery.of(context).size.height * 0.45,
              width: MediaQuery.of(context).size.width,
              child: Lottie.network(
                  "https://assets7.lottiefiles.com/packages/lf20_wpf1kujc.json"),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 5),
              child: Text("Verification",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            ),
            const Text(
              "You will get an OTP via SMS",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 8, left: 40, right: 40),
              child: TextField(
                maxLength: 6,
                style:
                    const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                obscureText: true,
                onChanged: (code) {
                  smsOtp = code;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 20, left: 70, right: 70, bottom: 10),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  onPressed: () async {
                    try {
                      PhoneAuthCredential phoneAuthCredentials =
                          PhoneAuthProvider.credential(
                              verificationId: verificationCode,
                              smsCode: smsOtp);
                      final User? user = (await _auth
                              .signInWithCredential(phoneAuthCredentials))
                          .user;

                      if (user != null) {
                        setState(() {
                          isLoading = false;
                        });
                        _userServices.getUserDataById(user.uid).then((value) {
                          if (value.exists) {
                            //User Data Already Exists
                            if (_currentScreen == "Login") {
                              //need to check user data already exists in database or not.
                              //if its 'login' no new data so no need to update
                              if (value['address'] != null) {
                                Navigator.pushReplacementNamed(
                                    context, MainScreen.id);
                              }
                              Navigator.pushReplacementNamed(
                                  context, LandingScreen.id);
                            } else {
                              //Need to update new Selected Address
                              authProvider.updateUser(
                                  id: user.uid, number: user.phoneNumber);
                              Navigator.pushReplacementNamed(
                                  context, MainScreen.id);
                            }
                          } else {
                            //User Data Does not Exists
                            //Will Create new Data in Database
                            authProvider.createUser(
                                id: user.uid, number: user.phoneNumber);
                            Navigator.pushReplacementNamed(
                                context, LandingScreen.id);
                          }
                        });
                      }
                    } catch (e) {
                      setState(() {});
                      print(e.toString());
                      showAlert("Invalid OTP");
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    "VERIFY",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Didn't receive the verification OTP? ",
                  style: TextStyle(fontSize: 15),
                ),
                GestureDetector(
                  onTap: () {
                    verifyPhoneNumber();
                    showAlert("OTP Send Successfully");
                  },
                  child: const Text(
                    "Resend again",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
