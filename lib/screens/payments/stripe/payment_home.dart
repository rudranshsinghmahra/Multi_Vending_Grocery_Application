import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:multi_vending_grocery_app/providers/orders_provider.dart';
import 'package:http/http.dart' as http;
import 'package:multi_vending_grocery_app/screens/payments/razorpay/razorpay_payment.dart';
import 'package:multi_vending_grocery_app/screens/payments/stripe/create_new_card_screen.dart';
import 'package:provider/provider.dart';

import 'existing-cards.dart';

class PaymentHome extends StatefulWidget {
  const PaymentHome({Key? key}) : super(key: key);
  static const String id = "payment-home";

  @override
  PaymentHomeState createState() => PaymentHomeState();
}

class PaymentHomeState extends State<PaymentHome> {
  Map<String, dynamic>? paymentIntentData;

  onItemPress(BuildContext context, int index, amount, orderProvider) async {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, CreateNewCard.id);
        break;
      case 1:
        makePaymentViaNewCard(orderProvider);
        break;
      case 2:
        Navigator.pushNamed(context, ExistingCardsPage.id);
        break;
    }
  }

  // payViaNewCard(
  //     BuildContext context, amount, OrderProvider orderProvider) async {
  //   ProgressDialog dialog = ProgressDialog(context);
  //   dialog.style(message: 'Please wait...');
  //   await dialog.show();
  //   var response = await StripeService.payWithNewCard(
  //       amount: '${amount}00', currency: 'INR');
  //   if (response.success == true) {
  //     orderProvider.success = true;
  //   }
  //   await dialog.hide();
  //   ScaffoldMessenger.of(context)
  //       .showSnackBar(SnackBar(
  //         content: Text("${response.message}"),
  //         duration:
  //             Duration(milliseconds: response.success == true ? 1200 : 3000),
  //       ))
  //       .closed
  //       .then((_) {
  //     Navigator.pop(context);
  //   });
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   StripeService.init();
  // }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //RAZOR PAY
            Material(
              elevation: 5,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 80,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 5, right: 55, left: 55, bottom: 5),
                    child: Image.asset(
                      "assets/razorpaylogo.png",
                      fit: BoxFit.fill,
                    ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RazorpayPayment.id);
                      },
                      child: const Text("Proceed to payment..."))),
            ),
            const Divider(
              color: Colors.grey,
            ),
            // PAYPAL
            Material(
              elevation: 5,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 80,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10, right: 40, left: 40, bottom: 10),
                    child: Image.asset(
                      "assets/paypallogo.png",
                      fit: BoxFit.fill,
                    ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {}, child: Text("Proceed to payment..."))),
            ),
            const Divider(
              color: Colors.grey,
            ),
            // STRIPE
            Material(
              elevation: 5,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 80,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 40, left: 40),
                    child: Image.asset(
                      "assets/stripelogo.png",
                      fit: BoxFit.fill,
                    ),
                  )),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    Icon? icon;
                    Text? text;

                    switch (index) {
                      case 0:
                        icon =
                            Icon(Icons.add_circle, color: theme.primaryColor);
                        text = Text('Add Cards');
                        break;
                      case 1:
                        icon = Icon(Icons.payment_outlined,
                            color: theme.primaryColor);
                        text = Text('Pay via new card');
                        break;
                      case 2:
                        icon =
                            Icon(Icons.credit_card, color: theme.primaryColor);
                        text = Text('Pay via existing card');
                        break;
                    }

                    return InkWell(
                      onTap: () {
                        onItemPress(context, index, orderProvider.amount,
                            orderProvider);
                        // makePayment(orderProvider);
                      },
                      child: ListTile(
                        title: text,
                        leading: icon,
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                        color: theme.primaryColor,
                      ),
                  itemCount: 3),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> makePaymentViaNewCard(OrderProvider orderProvider) async {
    try {
      paymentIntentData = await createPaymentIntent(
          orderProvider.amount.toString(),
          'INR',
          orderProvider); //json.decode(response.body);
      // print('Response body==>${response.body.toString()}');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret:
                      paymentIntentData!['client_secret'],
                  applePay: true,
                  googlePay: true,
                  testEnv: true,
                  style: ThemeMode.dark,
                  merchantCountryCode: 'INR',
                  merchantDisplayName: 'Grocery App'))
          .then((value) {});
      setState(() {});

      ///now finally display payment sheeet
      displayPaymentSheet(orderProvider);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet(OrderProvider orderProvider) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((newValue) {
        print('payment intent ${paymentIntentData!['id']}');
        print('payment intent ${paymentIntentData!['client_secret']}');
        print('payment intent ${paymentIntentData!['amount']}');
        print('payment intent $paymentIntentData');
        //orderPlaceApi(paymentIntentData!['id'].toString());
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Paid successfully")));
        orderProvider.success = true;
        Navigator.pop(context);
        setState(() {
          paymentIntentData = null;
        });
      }).onError((error, stackTrace) {
        print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(
      String amount, String currency, OrderProvider orderProvider) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount("${orderProvider.amount}"),
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      print(body);
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
                'Bearer sk_test_51LKyZBSBEstQDuHJuQy2LYmyXc7rVEh3SKzEQsXRl2WSNCaGFfhqbwwCNNgNOssudTHiL5PqcdOzgFvYabUHswvn00ypVAN721',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      print('Create Intent reponse ===> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount) * 100);
    return a.toString();
  }
}
