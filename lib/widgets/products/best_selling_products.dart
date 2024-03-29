import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/providers/store_provider.dart';
import 'package:multi_vending_grocery_app/services/product_services.dart';
import 'package:multi_vending_grocery_app/widgets/products/product_card_widget.dart';
import 'package:provider/provider.dart';

class BestSellingProduct extends StatelessWidget {
  const BestSellingProduct({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ProductServices _services = ProductServices();
    var _storeProvider = Provider.of<StoreProvider>(context);

    //Will only show seller selected products
    return FutureBuilder<QuerySnapshot>(
      future: _services.products
          .where('published', isEqualTo: true)
          .where('collection', isEqualTo: "Best Selling")
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
            if (snapshot.data.docs.length > 0)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.teal[100],
                        borderRadius: BorderRadius.circular(4)),
                    height: 56,
                    child: const Center(
                      child: Text(
                        "Best Selling Products",
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
