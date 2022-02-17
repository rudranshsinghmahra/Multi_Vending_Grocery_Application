import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/screens/top_picked_store.dart';
import 'package:multi_vending_grocery_app/screens/welcome_screen.dart';
import 'package:multi_vending_grocery_app/widgets/images_slider.dart';
import 'package:multi_vending_grocery_app/widgets/my_appbar.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String id = 'home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _location = "";
  @override
  void initState() {
    getPreferences();
    super.initState();
  }

  Future<void> getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? location = prefs.getString('location');
    setState(() {
      _location = location;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.deepPurple,
      child: SafeArea(
        child: Scaffold(
          appBar: const PreferredSize(
            preferredSize: Size.fromHeight(130),
            child: MyAppBar(),
          ),
          body: Center(
            child: Column(
              children: [
                const ImageSlider(),
                Container(height: 300,child: TopPickedStore()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
