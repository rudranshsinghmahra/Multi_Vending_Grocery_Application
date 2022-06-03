import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi_vending_grocery_app/providers/auth_provider.dart';
import 'package:multi_vending_grocery_app/providers/cart_provider.dart';
import 'package:multi_vending_grocery_app/providers/location_provider.dart';
import 'package:multi_vending_grocery_app/providers/store_provider.dart';
import 'package:multi_vending_grocery_app/screens/home_screen.dart';
import 'package:multi_vending_grocery_app/screens/landing_screen.dart';
import 'package:multi_vending_grocery_app/screens/login_screen.dart';
import 'package:multi_vending_grocery_app/screens/main_screen.dart';
import 'package:multi_vending_grocery_app/screens/map_screen.dart';
import 'package:multi_vending_grocery_app/screens/product_details_screen.dart';
import 'package:multi_vending_grocery_app/screens/product_list_screen.dart';
import 'package:multi_vending_grocery_app/widgets/products/product_list.dart';
import 'package:multi_vending_grocery_app/screens/profile_screen.dart';
import 'package:multi_vending_grocery_app/screens/register_screen.dart';
import 'package:multi_vending_grocery_app/screens/splash_screen.dart';
import 'package:multi_vending_grocery_app/screens/vendors_home_screen.dart';
import 'package:multi_vending_grocery_app/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => StoreProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => const SplashScreen(),
        HomeScreen.id: (context) => const HomeScreen(),
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        MapScreen.id: (context) => const MapScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        RegistrationScreen.id: (context) => const RegistrationScreen(),
        LandingScreen.id: (context) => const LandingScreen(),
        MainScreen.id: (context) => const MainScreen(),
        ProfileScreen.id: (context) => const ProfileScreen(),
        VendorHomeScreen.id: (context) => const VendorHomeScreen(),
        ProductListScreen.id: (context) => const ProductListScreen(),
        ProductDetailsScreen.id: (context) => const ProductDetailsScreen(),
      },
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple, fontFamily: 'Lato'),
    );
  }
}
