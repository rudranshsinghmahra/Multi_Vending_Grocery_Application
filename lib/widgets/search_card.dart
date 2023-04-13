import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../models/product_model.dart';
import '../screens/product_details_screen.dart';
import 'cart/counter.dart';

class SearchCard extends StatelessWidget {
  const SearchCard({
    Key? key,
    required this.offer,
    required this.product,
    required this.documentSnapshot,
  }) : super(key: key);

  final String? offer;
  final Product product;
  final DocumentSnapshot documentSnapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: Colors.grey))),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
        child: Row(
          children: [
            Stack(
              children: [
                Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                        context,
                        settings:
                            const RouteSettings(name: ProductDetailsScreen.id),
                        screen: ProductDetailsScreen(
                            documentSnapshot: product.documentSnapshot),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    child: SizedBox(
                      height: 140,
                      width: 130,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Hero(
                              tag:
                                  "product${product.documentSnapshot['productName']}",
                              child: Image.network(
                                  product.documentSnapshot['productImage']))),
                    ),
                  ),
                ),
                if (product.documentSnapshot['comparedPrice'] > 0)
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF9D78E2),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 3, bottom: 3),
                      child: Text(
                        "$offer% off",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.documentSnapshot['brand'],
                        style: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        product.documentSnapshot['productName'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 160,
                        padding:
                            const EdgeInsets.only(top: 10, bottom: 10, left: 6),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey[300]),
                        child: Text(
                          product.documentSnapshot['weight'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          Text(
                            "\Rs ${product.documentSnapshot['price'].toStringAsFixed(0)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Rs ${product.documentSnapshot['comparedPrice'].toStringAsFixed(0)}",
                            style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 160,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CounterForCard(
                              documentSnapshot: product.documentSnapshot,
                            )
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
