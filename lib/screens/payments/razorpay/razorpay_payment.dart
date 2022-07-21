import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_vending_grocery_app/providers/orders_provider.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:fluttertoast/fluttertoast.dart';

class RazorpayPayment extends StatefulWidget {
  const RazorpayPayment({Key? key}) : super(key: key);
  static const String id = "razor-pay";

  @override
  _RazorpayPaymentState createState() => _RazorpayPaymentState();
}

class _RazorpayPaymentState extends State<RazorpayPayment> {
  static const platform = MethodChannel("razorpay_flutter");
  late Razorpay _razorpay;
  bool? success;

  Future<void> openCheckout(OrderProvider orderProvider) async {
    User? user = FirebaseAuth.instance.currentUser;

    var options = {
      'key': 'rzp_test_QSLKf08aXAe8jK',
      'amount': "${orderProvider.amount}00",
      'name': orderProvider.shopName,
      'description': 'Grocery Purchase',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': user?.phoneNumber,
        'email': '${orderProvider.email}'
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      success = true;
    });
    print('Success Response: $response');
    Fluttertoast.showToast(msg: "SUCCESS: ${response.paymentId!}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Error Response: $response');
    Fluttertoast.showToast(
        msg: "ERROR: ${response.code} - ${response.message!}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External SDK Response: $response');
    Fluttertoast.showToast(msg: "EXTERNAL_WALLET: ${response.walletName!}");
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Razorpay Sample App'),
      ),
      body: Center(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Total Payable Amount: Rs ${orderProvider.amount}"),
                ElevatedButton(
                    onPressed: () {
                      openCheckout(orderProvider).whenComplete(() {
                        print("Response from the payment is : $success");
                        if (success = true) {
                          orderProvider.paymentStatus(true);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      });
                    },
                    child: const Text('Continue')),
              ],
            )
          ])),
    );
  }
}
