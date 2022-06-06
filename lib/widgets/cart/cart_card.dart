import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/widgets/cart/counter.dart';

class CartCard extends StatelessWidget {
  const CartCard({Key? key, required this.documentSnapshot}) : super(key: key);
  final DocumentSnapshot? documentSnapshot;

  @override
  Widget build(BuildContext context) {
    double savings =
        documentSnapshot?['comparedPrice'] - documentSnapshot?['price'];
    return Container(
      height: 120,
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey))),
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Row(
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    child: Image.network(
                      documentSnapshot?['productImage'],
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(documentSnapshot?['productName']),
                        Text(
                          documentSnapshot?['weight'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        if (documentSnapshot?['comparedPrice'] > 0)
                          Text(
                            documentSnapshot?['comparedPrice']
                                .toStringAsFixed(0),
                            style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontSize: 12),
                          ),
                        Text(
                          documentSnapshot?['price'].toStringAsFixed(0),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Positioned(
                  right: 0.0,
                  bottom: 0.0,
                  child: CounterForCard(
                    documentSnapshot: documentSnapshot,
                  )),
              if (savings > 0)
                Positioned(
                    child: CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: FittedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            "\Rs ${savings.toStringAsFixed(0)}",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "SAVED",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                    ),
                  ),
                ))
            ],
          )),
    );
  }
}
