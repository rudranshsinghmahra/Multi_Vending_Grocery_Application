// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class UserModel{
//   static const NUMBER = 'number';
//   static const ID = 'id';
//
//   String? _number;
//   String? _id;
//
//   String? get number => _number;
//   String? get id => _id;
//
//   UserModel.fromSnapShot(DocumentSnapshot<Map<String,dynamic>> documentSnapshot){
//     _number = documentSnapshot.data()![NUMBER];
//     _id = documentSnapshot.data()![ID];
//   }
// }