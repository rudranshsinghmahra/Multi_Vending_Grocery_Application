import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderService {
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');

  Future<DocumentReference> saveOrder(Map<String, dynamic> data) {
    var result = orders.add(data);
    return result;
  }

  Color statusColor(DocumentSnapshot documentSnapshot) {
    if (documentSnapshot['orderStatus'] == "Accepted") {
      return Colors.blueGrey;
    }
    if (documentSnapshot['orderStatus'] == "Rejected") {
      return Colors.red;
    }
    if (documentSnapshot['orderStatus'] == "Picked-Up") {
      return Colors.pink;
    }
    if (documentSnapshot['orderStatus'] == "Out for Delivery") {
      return Colors.purple;
    }
    if (documentSnapshot['orderStatus'] == "Delivered") {
      return Colors.green;
    }
    return Colors.orange;
  }

  Icon statusIcon(DocumentSnapshot documentSnapshot) {
    if (documentSnapshot['orderStatus'] == "Accepted") {
      return Icon(
        Icons.assignment_turned_in_outlined,
        color: statusColor(documentSnapshot),
        size: 22,
      );
    }
    if (documentSnapshot['orderStatus'] == "Picked-Up") {
      return Icon(
        Icons.cases,
        color: statusColor(documentSnapshot),
        size: 22,
      );
    }
    if (documentSnapshot['orderStatus'] == "Out For Delivery") {
      return Icon(
        Icons.delivery_dining,
        color: statusColor(documentSnapshot),
        size: 22,
      );
    }
    if (documentSnapshot['orderStatus'] == "Rejected") {
      return Icon(
        Icons.cancel_outlined,
        color: statusColor(documentSnapshot),
        size: 22,
      );
    }
    if (documentSnapshot['orderStatus'] == "Delivered") {
      return Icon(
        Icons.shopping_bag_outlined,
        color: statusColor(documentSnapshot),
        size: 22,
      );
    }
    return Icon(
      Icons.assignment_turned_in_outlined,
      color: statusColor(documentSnapshot),
      size: 22,
    );
  }

  String statusComment(document) {
    if (document['orderStatus'] == "Picked-Up") {
      return "Your order is picked by the courier";
    }
    if (document['orderStatus'] == "Out for Delivery") {
      return "Your delivery person is ${document['deliveryBoy']['name']}";
    }
    if (document['orderStatus'] == "Delivered") {
      return "You order is completed";
    }
    if (document['orderStatus'] == "Rejected") {
      return "Your Order is Rejected by ${document['orderStatus']['shopName']}";
    }
    return "Your order is accepted by Seller : ${document['seller']['shopName']}";
  }
}
