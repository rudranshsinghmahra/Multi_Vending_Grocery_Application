import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_credit_card/custom_card_type_icon.dart';
import 'package:flutter_credit_card/glassmorphism_config.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi_vending_grocery_app/services/payment_gateways/stripe_payment_service.dart';

class CreateNewCard extends StatefulWidget {
  const CreateNewCard({Key? key}) : super(key: key);
  static const String id = "create-card";

  @override
  State<StatefulWidget> createState() {
    return CreateNewCardState();
  }
}

class CreateNewCardState extends State<CreateNewCard> {
  StripeService stripeService = StripeService();

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 2.0,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Card"),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 30,
            ),
            CreditCardWidget(
              glassmorphismConfig:
                  useGlassMorphism ? Glassmorphism.defaultConfig() : null,
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
              obscureCardNumber: true,
              obscureCardCvv: true,
              isHolderNameVisible: true,
              cardBgColor: Colors.red,
              backgroundImage: useBackgroundImage ? 'assets/card_bg.png' : null,
              isSwipeGestureEnabled: true,
              onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
              customCardTypeIcons: <CustomCardTypeIcon>[
                CustomCardTypeIcon(
                  cardType: CardType.mastercard,
                  cardImage: Image.asset(
                    'assets/mastercard.png',
                    height: 48,
                    width: 48,
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    CreditCardForm(
                      formKey: formKey,
                      obscureCvv: true,
                      obscureNumber: true,
                      cardNumber: cardNumber,
                      cvvCode: cvvCode,
                      isHolderNameVisible: true,
                      isCardNumberVisible: true,
                      isExpiryDateVisible: true,
                      cardHolderName: cardHolderName,
                      expiryDate: expiryDate,
                      themeColor: Colors.black,
                      textColor: Colors.black,
                      cardNumberDecoration: InputDecoration(
                        labelText: 'Card Number',
                        hintText: 'XXXX XXXX XXXX XXXX',
                        hintStyle: TextStyle(color: Colors.black),
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: border,
                        enabledBorder: border,
                      ),
                      expiryDateDecoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.black),
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: border,
                        enabledBorder: border,
                        labelText: 'Expired Date',
                        hintText: 'XX/XX',
                      ),
                      cvvCodeDecoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.black),
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: border,
                        enabledBorder: border,
                        labelText: 'CVV',
                        hintText: 'XXX',
                      ),
                      cardHolderDecoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.black),
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: border,
                        enabledBorder: border,
                        labelText: 'Card Holder Name',
                      ),
                      onCreditCardModelChange: onCreditCardModelChange,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: <Widget>[
                    //      Text(
                    //       'Glassmorphism',
                    //       style: TextStyle(
                    //         color: Theme.of(context).primaryColor,
                    //         fontSize: 18,
                    //       ),
                    //     ),
                    //     Switch(
                    //       value: useGlassMorphism,
                    //       inactiveTrackColor: Colors.grey,
                    //       activeColor: Theme.of(context).primaryColor,
                    //       activeTrackColor: Colors.green,
                    //       onChanged: (bool value) => setState(() {
                    //         useGlassMorphism = value;
                    //       }),
                    //     ),
                    //   ],
                    // ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: <Widget>[
                    //      Text(
                    //       'Card Image',
                    //       style: TextStyle(
                    //         color: Theme.of(context).primaryColor,
                    //         fontSize: 18,
                    //       ),
                    //     ),
                    //     Switch(
                    //       value: useBackgroundImage,
                    //       inactiveTrackColor: Colors.grey,
                    //       activeColor: Theme.of(context).primaryColor,
                    //       activeTrackColor: Colors.green,
                    //       onChanged: (bool value) => setState(() {
                    //         useBackgroundImage = value;
                    //       }),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        primary: const Color(0xff1b447b),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        child: const Text(
                          'Validate',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'halter',
                            fontSize: 14,
                            package: 'flutter_credit_card',
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          EasyLoading.show(status: "Please Wait");
                          stripeService.saveCard({
                            "cardNumber": cardNumber,
                            "expiryDate": expiryDate,
                            "cardHolderName": cardHolderName,
                            "cvvCode": cvvCode,
                            "showBackView": false,
                            "uid" : stripeService.user?.uid,
                          }).whenComplete((){
                            EasyLoading.showSuccess("Card Saved Successfully").then((value){
                              Navigator.pop(context);
                            });
                          });
                        } else {
                          print('invalid!');
                        }
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
