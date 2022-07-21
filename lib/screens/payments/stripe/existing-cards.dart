import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:multi_vending_grocery_app/providers/orders_provider.dart';


import '../../../services/payment_gateways/stripe_payment_service.dart';

class ExistingCardsPage extends StatefulWidget {
  const ExistingCardsPage({Key? key}) : super(key: key);
  static const String id = "existing-cards";

  @override
  ExistingCardsPageState createState() => ExistingCardsPageState();
}

class ExistingCardsPageState extends State<ExistingCardsPage> {
  StripeService stripeService = StripeService();
  OrderProvider orderProvider = OrderProvider();

  // Future payViaExistingCard(BuildContext context, card, amount) async {
  //   ProgressDialog dialog = ProgressDialog(context);
  //   dialog.style(message: 'Please wait...');
  //   await dialog.show();
  //   var expiryArr = card['expiryDate'].split('/');
  //   CreditCard stripeCard = CreditCard(
  //     number: card['cardNumber'],
  //     expMonth: int.parse(expiryArr[0]),
  //     expYear: int.parse(expiryArr[1]),
  //   );
  //   var response = await StripeService.payViaExistingCard(
  //       '${amount}00', 'INR', stripeCard);
  //   await dialog.hide();
  //   ScaffoldMessenger.of(context)
  //       .showSnackBar(SnackBar(
  //         content: Text("${response.message}"),
  //         duration: Duration(milliseconds: 1200),
  //       ))
  //       .closed
  //       .then((_) {
  //     Navigator.pop(context);
  //     Navigator.pop(context);
  //   });
  //   return response;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose existing card'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: stripeService.cards.get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data?.size == 0) {
            return const Center(
              child: Text("No saved cards currently"),
            );
          }

          return Container(
            padding: const EdgeInsets.all(20),
            child: ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (BuildContext context, int index) {
                var card = snapshot.data?.docs[index];
                return InkWell(
                  onTap: () {
                    // payViaExistingCard(context, card, orderProvider.amount)
                    //     .then((response) {
                    //   if (response.success == true) {
                    //     orderProvider.success = true;
                    //   }
                    // });
                  },
                  child: CreditCardWidget(
                    cardNumber: card!['cardNumber'],
                    expiryDate: card['expiryDate'],
                    cardHolderName: card['cardHolderName'],
                    cvvCode: card['cvvCode'],
                    showBackView: false,
                    onCreditCardWidgetChange: (CreditCardBrand) {},
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
