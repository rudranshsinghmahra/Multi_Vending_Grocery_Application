import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:toggle_bar/toggle_bar.dart';

class CodToggleSwitch extends StatelessWidget {
  const CodToggleSwitch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _cart = Provider.of<CartProvider>(context);
    return Container(
      color: Colors.white,
      child: ToggleBar(
        backgroundColor: Colors.grey[600],
        textColor: Colors.grey[300],
        selectedTabColor: Theme.of(context).primaryColor,
        labels: const ["Pay Online", "Cash On Delivery"],
        onSelectionUpdated: (index) {
          _cart.getPaymentMethod(index);
        },
      ),
    );
  }
}
