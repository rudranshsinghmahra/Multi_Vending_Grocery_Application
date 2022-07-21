import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showAlert(String msg) {
  Fluttertoast.showToast(msg: msg);
}

const kApiKey = 'AIzaSyA4DCTbenrxwGbHlZIe1zQF2HA39776Js0';

const kStoreCardStyle = TextStyle(
  fontSize: 14,
  color: Colors.grey,
);