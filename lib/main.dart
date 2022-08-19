import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:multi_vending_grocery_app/providers/auth_provider.dart';
import 'package:multi_vending_grocery_app/providers/cart_provider.dart';
import 'package:multi_vending_grocery_app/providers/coupons_provider.dart';
import 'package:multi_vending_grocery_app/providers/location_provider.dart';
import 'package:multi_vending_grocery_app/providers/orders_provider.dart';
import 'package:multi_vending_grocery_app/providers/store_provider.dart';
import 'package:multi_vending_grocery_app/screens/cart_screen.dart';
import 'package:multi_vending_grocery_app/screens/home_screen.dart';
import 'package:multi_vending_grocery_app/screens/landing_screen.dart';
import 'package:multi_vending_grocery_app/screens/login_screen.dart';
import 'package:multi_vending_grocery_app/screens/main_screen.dart';
import 'package:multi_vending_grocery_app/screens/map_screen.dart';
import 'package:multi_vending_grocery_app/screens/my_orders_screen.dart';
import 'package:multi_vending_grocery_app/screens/otp_verification_screen.dart';
import 'package:multi_vending_grocery_app/screens/payments/razorpay/razorpay_payment.dart';
import 'package:multi_vending_grocery_app/screens/payments/stripe/create_new_card_screen.dart';
import 'package:multi_vending_grocery_app/screens/payments/stripe/credit_card_list.dart';
import 'package:multi_vending_grocery_app/screens/payments/stripe/existing-cards.dart';
import 'package:multi_vending_grocery_app/screens/payments/stripe/payment_home.dart';
import 'package:multi_vending_grocery_app/screens/product_details_screen.dart';
import 'package:multi_vending_grocery_app/screens/product_list_screen.dart';
import 'package:multi_vending_grocery_app/screens/profile_update_screen.dart';
import 'package:multi_vending_grocery_app/screens/profile_screen.dart';
import 'package:multi_vending_grocery_app/screens/register_screen.dart';
import 'package:multi_vending_grocery_app/screens/splash_screen.dart';
import 'package:multi_vending_grocery_app/screens/vendors_home_screen.dart';
import 'package:multi_vending_grocery_app/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51LKyZBSBEstQDuHJU3EZBj63isas2wMmw0tHXQF9Wmze0bFhNO2q4bublyNr6dX8sAPgwfecvrE1WMxEDCHuSoTx00aiOseXH1';
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
        ChangeNotifierProvider(
          create: (_) => CouponProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(),
        )
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
        CartScreen.id: (context) => const CartScreen(),
        UpdateProfile.id: (context) => const UpdateProfile(),
        PaymentHome.id: (context) => const PaymentHome(),
        MyOrdersScreen.id: (context) => const MyOrdersScreen(),
        CreditCardList.id: (context) => const CreditCardList(),
        CreateNewCard.id: (context) => const CreateNewCard(),
        ExistingCardsPage.id: (context) => const ExistingCardsPage(),
        RazorpayPayment.id: (context) => const RazorpayPayment(),
        OtpVerificationScreen.id: (context) => const OtpVerificationScreen(),
      },
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple, fontFamily: 'Lato'),
    );
  }
}
