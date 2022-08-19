import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/providers/auth_provider.dart';
import 'package:multi_vending_grocery_app/providers/location_provider.dart';
import 'package:provider/provider.dart';

import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const String id = 'login-screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _validPhoneNumber = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final Size size = MediaQuery.of(context).size;
    final locationData = Provider.of<LocationProvider>(context);
    return Container(
      color: Colors.deepPurple,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20.0, left: 20),
                child: Text(
                  "Login",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 5.0, left: 20),
                child: Text(
                  "Enter Your Phone Number",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 20, right: 20),
                child: TextField(
                  controller: _phoneNumberController,
                  maxLength: 10,
                  style: const TextStyle(fontSize: 20),
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    prefix: Text(
                      "+91  ",
                      style: TextStyle(fontSize: 20),
                    ),
                    labelText: "Enter Your Phone Number",
                  ),
                  autofocus: true,
                  onChanged: (value) {
                    if (value.length == 10) {
                      setState(() {
                        _validPhoneNumber = true;
                      });
                    } else {
                      setState(
                        () {
                          _validPhoneNumber = false;
                        },
                      );
                    }
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: size.height / 18,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AbsorbPointer(
                          absorbing: _validPhoneNumber ? false : true,
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: _validPhoneNumber
                                    ? MaterialStateProperty.all(
                                        Colors.deepPurple)
                                    : MaterialStateProperty.all(Colors.grey)),
                            onPressed: () {
                              setState(() {
                                auth.isLoading = true;
                                auth.currentScreen = "MapScreen";
                                auth.latitude = locationData.latitude;
                                auth.longitude = locationData.longitude;
                                auth.address =
                                    locationData.selectedAddress?.addressLine;
                              });
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtpVerificationScreen(
                                      number:
                                          '+91${_phoneNumberController.text}'),
                                ),
                              ).then((value) {
                                setState(() {
                                  _phoneNumberController.clear();
                                  auth.isLoading = false;
                                });
                              });
                            },
                            child: auth.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text(
                                    _validPhoneNumber
                                        ? "Continue"
                                        : "Enter Phone Number",
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
