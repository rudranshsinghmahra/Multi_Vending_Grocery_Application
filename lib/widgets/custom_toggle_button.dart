import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CustomToggleButton extends StatefulWidget {
  const CustomToggleButton({Key? key}) : super(key: key);

  @override
  State<CustomToggleButton> createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> {
  List<bool> isSelected = [true, false];
  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8),
            child: ToggleButtons(
              constraints:
                  BoxConstraints.expand(width: constraints.maxWidth / 2.1),
              borderRadius: BorderRadius.circular(20),
              color: Colors.black,
              selectedColor: Colors.white,
              renderBorder: false,
              fillColor: Theme.of(context).primaryColor,
              isSelected: isSelected,
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Pay Online"),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Cash On Delivery"),
                )
              ],
              onPressed: (int newIndex) {
                setState(() {
                  for (int index = 0; index < isSelected.length; index++) {
                    if (index == newIndex) {
                      isSelected[index] = true;
                    } else {
                      isSelected[index] = false;
                    }
                  }
                });
                cart.getPaymentMethod(newIndex);
              },
            ),
          );
        }),
      ),
    );
  }
}
