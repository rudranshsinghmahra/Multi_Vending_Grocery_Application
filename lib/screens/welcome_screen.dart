import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/providers/auth_provider.dart';
import 'package:multi_vending_grocery_app/providers/location_provider.dart';
import 'package:multi_vending_grocery_app/screens/map_screen.dart';
import 'package:multi_vending_grocery_app/screens/on_board_screen.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);
  static const String id = 'welcome-screen';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final Size size = MediaQuery.of(context).size;
    TextEditingController _phoneNumberController = TextEditingController();
    final locationData = Provider.of<LocationProvider>(context, listen: false);
    bool _validPhoneNumber = false;

    void showBottomSheet(context) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter stateSetter) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0, left: 20),
                    child: Text(
                      "Login",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
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
                    padding:
                        const EdgeInsets.only(top: 8.0, left: 20, right: 20),
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
                          stateSetter(() {
                            _validPhoneNumber = true;
                          });
                        } else {
                          stateSetter(
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
                                        : MaterialStateProperty.all(
                                            Colors.grey)),
                                onPressed: () {
                                  stateSetter(() {
                                    auth.isLoading = true;
                                  });
                                  String number =
                                      '+91${_phoneNumberController.text}';
                                  auth.verifyPhoneNumber(
                                    context: context,
                                    number: number,
                                    // latitude: null,
                                    // longitude: null,
                                    // address: null
                                  );
                                  // auth.isLoading = false;
                                },
                                child: auth.isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
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
              );
            },
          );
        },
      );
    }

    return Container(
      color: Colors.deepPurpleAccent,
      child: SafeArea(
        child: Scaffold(
          body: SizedBox(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    height: size.height / 10,
                    width: size.width / 3.5,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(178, 182, 231, 1.0),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(1000),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {},
                      child: Icon(
                        Icons.arrow_forward,
                        size: size.width / 12,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    const Expanded(child: OnBoardScreen()),
                    const Text(
                      "Ready to Order from your Nearest Shop?",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                    ),
                    SizedBox(
                      height: size.height / 45,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("New User?",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                        SizedBox(height: 50,child: Image.asset('assets/forward_arrow.gif')),
                        TextButton(
                          style: ButtonStyle(
                              elevation: MaterialStateProperty.all(1),
                              backgroundColor: MaterialStateProperty.all(
                                const Color.fromRGBO(178, 182, 231, 1.0),
                              )),
                          onPressed: () async {
                            setState(() {
                              locationData.isLoading = true;
                            });
                            await locationData.getMyCurrentPosition();
                            if (locationData.permissionAllowed) {
                              Navigator.pushReplacementNamed(context, MapScreen.id);
                              setState(() {
                                locationData.isLoading = false;
                              });
                            } else {
                              setState(() {
                                locationData.isLoading = false;
                              });
                            }
                          },
                          child: locationData.isLoading
                              ? const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Text(
                            "Set Location",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.height / 45,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          auth.screen = "Login";
                        });
                        showBottomSheet(context);
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: "Already a customer?",
                          children: [
                            TextSpan(
                                text: " Login",
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.deepPurpleAccent,
                                    fontWeight: FontWeight.w500))
                          ],
                          style: TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height / 30,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
