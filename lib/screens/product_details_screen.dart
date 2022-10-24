import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/widgets/products/bottom_sheet_container.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({Key? key, this.documentSnapshot})
      : super(key: key);
  static const String id = "product_details_screen";
  final DocumentSnapshot? documentSnapshot;
  @override
  Widget build(BuildContext context) {
    var offer =
        (((documentSnapshot?['comparedPrice']) - (documentSnapshot?['price'])) /
            documentSnapshot?['comparedPrice'] *
            100);
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(CupertinoIcons.search),
          )
        ],
      ),
      bottomSheet: BottomSheetContainer(documentSnapshot: documentSnapshot),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, bottom: 2, top: 2),
                    child: Text(documentSnapshot?['brand']),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              documentSnapshot?['productName'],
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              documentSnapshot?['weight'],
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text(
                  "Rs ${documentSnapshot?['price'].toStringAsFixed(0)}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 10,
                ),
                if (offer > 0)
                  Text(
                    "Rs ${documentSnapshot?['comparedPrice']}",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.lineThrough),
                  ),
                const SizedBox(
                  width: 10,
                ),
                if (offer > 0)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8, right: 8, bottom: 3, top: 3),
                      child: Text(
                        "${offer.toStringAsFixed(0)}% Off",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 12),
                      ),
                    ),
                  )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Hero(
                  tag: "product${documentSnapshot?['productName']}",
                  child: Image.network(documentSnapshot?['productImage'])),
            ),
            Divider(
              color: Colors.grey[300],
              thickness: 6,
            ),
            Container(
              child: const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  "About This Product",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Divider(
              color: Colors.grey[300],
              thickness: 6,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpandableText(
                documentSnapshot?['description'],
                expandText: 'View More',
                collapseText: "View Less",
                maxLines: 2,
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
            Divider(
              color: Colors.grey[400],
            ),
            Container(
              child: const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  "Other Product Information",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Divider(
              color: Colors.grey[400],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SKU: ${documentSnapshot?['sku']}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "Seller: ${documentSnapshot?['seller']['shopName']}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 60,
            ),
          ],
        ),
      ),
    );
  }

  Future saveForLater() async {
    CollectionReference _favourites =
        FirebaseFirestore.instance.collection('favourites');
    User? user = FirebaseAuth.instance.currentUser;
    return _favourites
        .add({"product": documentSnapshot?.data(), "customerId": user?.uid});
  }
}
