import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StripeService {
  CollectionReference cards = FirebaseFirestore.instance.collection('cards');
  User? user = FirebaseAuth.instance.currentUser;

  Future saveCard(Map<String, dynamic> values) async {
    await cards.add(values);
  }

  Future deleteCard(id) async {
    await cards.doc(id).delete();
  }
}
