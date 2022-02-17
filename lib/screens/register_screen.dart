import 'package:flutter/material.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({Key? key}) : super(key: key);
  static const String id = 'register-screen';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepPurpleAccent,
      child: SafeArea(
        child: Scaffold(
          body: SizedBox(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(tag: 'logo',
                        child: Image.asset('assets/logo.png')),
                    TextField(),
                    TextField(),
                    TextField(),
                    TextField(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
