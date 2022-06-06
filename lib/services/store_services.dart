import 'package:cloud_firestore/cloud_firestore.dart';

class StoreServices {

  CollectionReference vendors = FirebaseFirestore.instance.collection('vendors');

  getTopPickedStore() {
    return vendors
        .where('accVerified', isEqualTo: true)
        .where('isTopPicked', isEqualTo: true)
        .where('shopOpen', isEqualTo: true)
        .orderBy('shopName')
        .snapshots();
  }

  getNearbyStores() {
    return vendors
        .where('accVerified', isEqualTo: true)
        .where('shopOpen', isEqualTo: true)
        .orderBy('shopName')
        .snapshots();
  }

  getNearbyStorePagination() {
    return vendors
        .where('accVerified', isEqualTo: true)
        .where('shopOpen', isEqualTo: true)
        .orderBy('shopName');
  }

  Future getShopDetails(sellerUid) async{
    DocumentSnapshot snapshot = await vendors.doc(sellerUid).get();
    return snapshot;
  }

}
