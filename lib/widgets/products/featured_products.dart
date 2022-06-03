import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/services/product_services.dart';
import 'package:multi_vending_grocery_app/widgets/products/product_card_widget.dart';
import 'package:provider/provider.dart';
import '../../providers/store_provider.dart';

class FeaturedProducts extends StatelessWidget {
  const FeaturedProducts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ProductServices _services = ProductServices();
    var _storeProvider = Provider.of<StoreProvider>(context);

    return FutureBuilder<QuerySnapshot>(
      future: _services.products
          .where('published', isEqualTo: true)
          .where('collection', isEqualTo: "Featured Products")
          .where('seller.sellerUid',
              isEqualTo: _storeProvider.storeDetails?['uid'])
          .get(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return const Text("Something Went Wrong");
        }
        if (!snapshot.hasData) {
          return Container();
        }
        return Column(
          children: [
            if(snapshot.data.docs.length>0)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: const Center(
                      child: Text(
                        "Featured Products",
                        style: TextStyle(
                            shadows: [
                              Shadow(
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 3.0,
                                  color: Colors.black)
                            ],
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: Colors.teal[100],
                        borderRadius: BorderRadius.circular(4)),
                    height: 56,
                  ),
                ),
              ),
            ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children:
                  snapshot.data.docs.map<Widget>((DocumentSnapshot document) {
                return ProductCard(documentSnapshot: document);
              }).toList(),
            )
          ],
        );
      },
    );
  }
}