import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi_vending_grocery_app/constants.dart';
import 'package:multi_vending_grocery_app/providers/coupons_provider.dart';
import 'package:provider/provider.dart';

class CouponWidget extends StatefulWidget {
  const CouponWidget({Key? key, required this.couponVendor}) : super(key: key);
  final String couponVendor;

  @override
  State<CouponWidget> createState() => _CouponWidgetState();
}

class _CouponWidgetState extends State<CouponWidget> {
  Color _color = Colors.grey;
  bool _enable = false;
  bool _isVisible = false;
  TextEditingController couponController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var _coupon = Provider.of<CouponProvider>(context);
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0, right: 10, left: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextField(
                        controller: couponController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter Voucher Code",
                          filled: true,
                          fillColor: Colors.grey[300],
                        ),
                        onChanged: (String value) {
                          if (value.length < 3) {
                            setState(() {
                              _color = Colors.grey;
                              _enable = false;
                            });
                            if (value.isNotEmpty) {
                              _color = Theme.of(context).primaryColor;
                              _enable = true;
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  AbsorbPointer(
                    absorbing: _enable ? false : true,
                    child: OutlinedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(_color),
                      ),
                      onPressed: () {
                        EasyLoading.show(status: "Validating Coupon...");
                        _coupon
                            .getCouponDetails(
                                couponController.text, widget.couponVendor)
                            .then((value) {
                          if (value.data() == null) {
                            setState(() {
                              _coupon.discountRate = 0;
                              _isVisible = false;
                            });
                            EasyLoading.dismiss();
                            showAlertMessage(
                                couponController.text, "Not Valid");
                            return;
                          }
                          if (_coupon.expired == false) {
                            //not expired, coupon is valid
                            setState(() {
                              _isVisible = true;
                            });
                            EasyLoading.dismiss();
                            return;
                          }
                          if (_coupon.expired == false) {
                            //not expired, coupon is valid
                            setState(() {
                              _isVisible = true;
                            });
                            EasyLoading.dismiss();
                            showAlertMessage(couponController.text, "Expired");
                          }
                        });
                      },
                      child: const Text(
                        "Apply",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Visibility(
              visible: _isVisible,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DottedBorder(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: const Color.fromRGBO(253, 164, 131, 1),
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(couponController.text),
                              ),
                              Divider(
                                color: Colors.grey[800],
                              ),
                              Text("${_coupon.documentSnapshot?['details']}"),
                              Text(
                                  "${_coupon.documentSnapshot?['discountRate']} % discount on total purchase"),
                              const SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          right: -5,
                          top: -6,
                          child: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _coupon.discountRate = 0;
                                _isVisible = false;
                                couponController.clear();
                              });
                            },
                          ))
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  showAlertMessage(couponCode, validity) {
    showAlert(
        "This discount coupon $couponCode you have entered is $validity.Please try with another code");
  }
}
