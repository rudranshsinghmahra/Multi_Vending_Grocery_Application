import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/constants.dart';
import 'package:multi_vending_grocery_app/providers/location_provider.dart';
import 'package:multi_vending_grocery_app/screens/home_screen.dart';
import 'package:multi_vending_grocery_app/services/services_user.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String smsOtp;
  String verificationId = "";
  bool isLoading = false;
  final UserServices _userServices = UserServices();
  LocationProvider locationData = LocationProvider();
  late String screen;
  double? latitude;
  double? longitude;
  String? address;

  Future<void> verifyPhoneNumber({
    required BuildContext context,
    required String number,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: number,
        verificationCompleted: (PhoneAuthCredential credential) async {
          isLoading = false;
          await _auth.signInWithCredential(credential);
          showAlert("Verified");
        },
        verificationFailed: (FirebaseAuthException exception) {
          isLoading = false;
          showAlert("Verification Failed");
        },
        codeSent: (String _verificationId, int? forceRespondToken) {
          isLoading = false;
          showAlert("Verification Code Sent");
          verificationId = _verificationId;
          smsOtpDialog(context, number);
        },
        codeAutoRetrievalTimeout: (String _verificationId) {
          isLoading = false;
          verificationId = _verificationId;
        },
      );
    } catch (e) {
      showAlert("Error Occurred: ${e.toString()}");
      isLoading = false;
    }
  }

  Future<Future<dynamic>> smsOtpDialog(
      BuildContext context, String number) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: const [
              Text('Verification Code'),
              SizedBox(
                height: 6,
              ),
              Text(
                "Enter 6 Digit OTP received as SMS",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              )
            ],
          ),
          content: SizedBox(
            height: 85,
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 6,
              onChanged: (value) {
                smsOtp = value;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  PhoneAuthCredential phoneAuthCredentials =
                      PhoneAuthProvider.credential(
                          verificationId: verificationId, smsCode: smsOtp);

                  final User? user =
                      (await _auth.signInWithCredential(phoneAuthCredentials))
                          .user;

                  if (user != null) {
                    isLoading = false;
                    notifyListeners();
                    _userServices.getUserDataById(user.uid).then((value) {
                      if (value.exists) {
                        //User Data Already Exists
                        if (screen == "Login") {
                          Navigator.pushReplacementNamed(
                              context, HomeScreen.id);
                        } else {
                          //Need to update new Selected Address
                          updateUser(id: user.uid, number: user.phoneNumber);
                          Navigator.pushReplacementNamed(
                              context, HomeScreen.id);
                        }
                      } else {
                        //User Data Does not Exists
                        //Will Create new Data in Database
                        _createUser(id: user.uid, number: user.phoneNumber);
                        Navigator.pushReplacementNamed(context, HomeScreen.id);
                      }
                    });
                    print(screen);
                  }
                } catch (e) {
                  notifyListeners();
                  print(e.toString());
                  showAlert("Invalid OTP");
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Verify OTP"),
            ),
            TextButton(onPressed: (){
              verifyPhoneNumber(context: context,number: number);
              showAlert("OTP Send Successfully");
            }, child: const Text("Resend OTP"))
          ],
        );
      },
    );
  }

  void _createUser({
    String? id,
    String? number,
  }) {
    _userServices.createUser({
      'id': id,
      'number': number,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    });
    isLoading = false;
    notifyListeners();
  }

  Future<bool> updateUser({
    String? id,
    String? number,
  }) async {
    try {
      _userServices.updateUserData({
        'id': id,
        'number': number,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      });
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Error $e");
      return false;
    }
  }
}
