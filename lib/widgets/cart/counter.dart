import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi_vending_grocery_app/services/cart_services.dart';

class CounterForCard extends StatefulWidget {
  const CounterForCard({Key? key, required this.documentSnapshot})
      : super(key: key);
  final DocumentSnapshot? documentSnapshot;
  @override
  State<CounterForCard> createState() => _CounterForCardState();
}

class _CounterForCardState extends State<CounterForCard> {
  User? user = FirebaseAuth.instance.currentUser;
  CartServices cartServices = CartServices();
  int _qty = 1;
  bool _exists = false;
  bool _updating = false;
  String? docId;

  @override
  void initState() {
    getCartData();
    super.initState();
  }

  getCartData() {
    FirebaseFirestore.instance
        .collection('cart')
        .doc(user?.uid)
        .collection('products')
        .where('productId', isEqualTo: widget.documentSnapshot?['productId'])
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.forEach((doc) {
          if (doc['productId'] == widget.documentSnapshot?['productId']) {
            setState(() {
              _qty = doc['qty'];
              docId = doc.id;
              _exists = true;
            });
          }
        });
      } else {
        setState(() {
          _exists = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _exists
        ? StreamBuilder(
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              return SizedBox(
                height: 28,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _updating = true;
                        });
                        if (_qty == 1) {
                          cartServices.removeFromCart(docId).then((value) {
                            setState(() {
                              _updating = false;
                              _exists = false;
                            });
                            cartServices.checkData();
                          });
                        }
                        if (_qty > 1) {
                          setState(() {
                            _qty--;
                          });
                          var total = _qty * widget.documentSnapshot?['price'];
                          cartServices
                              .updateCartQty(docId, _qty, total)
                              .then((value) {
                            setState(() {
                              _updating = false;
                            });
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.pink,
                            ),
                            borderRadius: BorderRadius.circular(4)),
                        child: Padding(
                          padding: EdgeInsets.only(left: 3, right: 3),
                          child: Icon(
                            _qty == 1 ? Icons.delete_outlined : Icons.remove,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: double.infinity,
                      width: 30,
                      color: Colors.pink,
                      child: Center(
                        child: FittedBox(
                          child: _updating
                              ? Container(
                                  height: 20,
                                  width: 20,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : Text(
                                  _qty.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _updating = true;
                          _qty++;
                        });
                        var total = _qty * widget.documentSnapshot?['price'];
                        cartServices
                            .updateCartQty(docId, _qty, total)
                            .then((value) {
                          setState(() {
                            _updating = false;
                          });
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.pink,
                            ),
                            borderRadius: BorderRadius.circular(4)),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 3, right: 3),
                          child: Icon(
                            Icons.add,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        : StreamBuilder(
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              return Container(
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      EasyLoading.show(status: "Adding to Cart");
                      cartServices.checkSeller().then(
                        (shopName) {
                          if (shopName ==
                              widget.documentSnapshot?['seller']['sellerUid']) {
                            setState(() {
                              _exists = true;
                            });
                            cartServices
                                .addToCart(widget.documentSnapshot)
                                .then((value) {
                              EasyLoading.showSuccess("Added To Cart");
                            });
                            return;
                          }
                          if (shopName == null) {
                            setState(() {
                              _exists = true;
                            });
                            cartServices
                                .addToCart(widget.documentSnapshot)
                                .then((value) {
                              EasyLoading.showSuccess("Added To Cart");
                            });
                            return;
                          }
                          if (shopName !=
                              widget.documentSnapshot?['seller']['shopName']) {
                            EasyLoading.dismiss();
                            showDialog(shopName);
                          }
                        },
                      );
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          );
  }

  showDialog(shopName) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Replace Cart Item?"),
          content: Text(
              "Your cart contains item from $shopName. Do you want to discard the selection and add items from ${widget.documentSnapshot?['seller']['shopName']}"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "No",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                cartServices.deleteCart().then((value) {
                  cartServices.addToCart(widget.documentSnapshot).then((value) {
                    setState(() {
                      _exists = true;
                    });
                    Navigator.pop(context);
                  });
                });
              },
              child: Text("Yes",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }
}
