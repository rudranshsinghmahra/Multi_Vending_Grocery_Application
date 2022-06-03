import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartServices {
  CollectionReference cart = FirebaseFirestore.instance.collection('cart');
  User? user = FirebaseAuth.instance.currentUser;

  Future addToCart(document) async {
    cart.doc(user?.uid).set({
      'user': user?.uid,
      'sellerUid': document['seller']['sellerUid'],
      'shopName': document['seller']['shopName'],
    });
    return cart.doc(user?.uid).collection('products').add({
      "productId": document['productId'],
      "productName": document['productName'],
      "weight": document['weight'],
      "price": document['price'],
      "comparedPrice": document['comparedPrice'],
      "sku": document['sku'],
      "qty": 1,
      "total": document['price'],
    });
  }

  Future updateCartQty(docId, qty, total) async {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('cart')
        .doc(user?.uid)
        .collection('products')
        .doc(docId);

    return FirebaseFirestore.instance
        .runTransaction((transaction) async {
          //Get the Document
          DocumentSnapshot documentSnapshot =
              await transaction.get(documentReference);

          if (!documentSnapshot.exists) {
            throw Exception("Product Does not Exist in Cart");
          }
          //Perform an update on the document
          transaction.update(documentReference, {
            'qty': qty,
            'total': total,
          });

          return qty;
        })
        .then((value) => print("Updated Cart"))
        .catchError((error) => print("Failed to update Cart : $error"));
  }

  Future<void> removeFromCart(docId) async {
    cart.doc(user?.uid).collection('products').doc(docId).delete();
  }

  Future checkData() async {
    final snapshot = await cart.doc(user?.uid).collection('products').get();
    if (snapshot.docs.isEmpty) {
      cart.doc(user?.uid).delete();
    }
  }

  Future deleteCart() async {
    final result =
        await cart.doc(user?.uid).collection('products').get().then((snapshot) {
      for (DocumentSnapshot documentSnapshot in snapshot.docs) {
        documentSnapshot.reference.delete();
      }
    });
  }

  Future<String> checkSeller() async {
    final snapshot = await cart.doc(user?.uid).get();
    return snapshot.exists ? snapshot['shopName'] : null;
  }

  Future getShopName() async {
    DocumentSnapshot documentSnapshot = await cart.doc(user?.uid).get();
    return documentSnapshot;
  }

}
