import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:multi_vending_grocery_app/screens/payments/stripe/create_new_card_screen.dart';
import 'package:multi_vending_grocery_app/services/payment_gateways/stripe_payment_service.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class CreditCardList extends StatelessWidget {
  const CreditCardList({Key? key}) : super(key: key);
  static const String id = "manage-cards";

  @override
  Widget build(BuildContext context) {
    StripeService stripeService = StripeService();
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                context,
                settings: const RouteSettings(name: CreateNewCard.id),
                screen: const CreateNewCard(),
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
            icon: const Icon(Icons.add_circle_rounded),
            color: Colors.white,
          )
        ],
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text("Manage Cards"),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No saved cards currently",
                      style: TextStyle(fontSize: 20)),
                  const SizedBox(
                    height: 5,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        PersistentNavBarNavigator
                            .pushNewScreenWithRouteSettings(
                          context,
                          settings: const RouteSettings(name: CreateNewCard.id),
                          screen: const CreateNewCard(),
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                      child: const Text("Add Card"))
                ],
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.all(20),
            child: ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (BuildContext context, int index) {
                var card = snapshot.data?.docs[index];
                return Slidable(
                  key: const ValueKey(0),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    dismissible: DismissiblePane(onDismissed: () {
                      EasyLoading.show(status: "Please wait...");
                      stripeService.deleteCard(card?.id).then((value) {
                        EasyLoading.dismiss();
                      });
                    }),
                    children: [
                      SlidableAction(
                        backgroundColor: const Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                        onPressed: (BuildContext context) {
                          EasyLoading.show(status: "Please wait...");
                          stripeService.deleteCard(card?.id).then((value) {
                            EasyLoading.dismiss();
                          });
                        },
                      ),
                    ],
                  ),
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
