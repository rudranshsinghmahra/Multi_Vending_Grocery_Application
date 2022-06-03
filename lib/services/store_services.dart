import 'package:cloud_firestore/cloud_firestore.dart';

class StoreServices {

  getTopPickedStore() {
    return FirebaseFirestore.instance
        .collection('vendors')
        .where('accVerified', isEqualTo: true)
        .where('isTopPicked', isEqualTo: true)
        .where('shopOpen', isEqualTo: true)
        .orderBy('shopName')
        .snapshots();
  }

  getNearbyStores() {
    return FirebaseFirestore.instance
        .collection('vendors')
        .where('accVerified', isEqualTo: true)
        .where('shopOpen', isEqualTo: true)
        .orderBy('shopName')
        .snapshots();
  }

  getNearbyStorePagination() {
    return FirebaseFirestore.instance
        .collection('vendors')
        .where('accVerified', isEqualTo: true)
        .where('shopOpen', isEqualTo: true)
        .orderBy('shopName');
  }
}
