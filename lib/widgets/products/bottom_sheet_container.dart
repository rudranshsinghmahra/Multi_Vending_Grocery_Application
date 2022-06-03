import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/widgets/products/save_for_later.dart';

import 'add_to_cart_widget.dart';

class BottomSheetContainer extends StatefulWidget {
  const BottomSheetContainer({Key? key, this.documentSnapshot})
      : super(key: key);
  final DocumentSnapshot? documentSnapshot;

  @override
  State<BottomSheetContainer> createState() => _BottomSheetContainerState();
}

class _BottomSheetContainerState extends State<BottomSheetContainer> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
            flex: 1,
            child: SaveForLater(documentSnapshot: widget.documentSnapshot)),
        Flexible(
            flex: 1,
            child:
                AddToCardWidget(documentSnapshot: widget.documentSnapshot)),
      ],
    );
  }
}
