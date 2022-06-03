import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SaveForLater extends StatelessWidget {
  const SaveForLater({Key? key, this.documentSnapshot}) : super(key: key);
  final DocumentSnapshot? documentSnapshot;

  @override
  Widget build(BuildContext context) {
    Future saveForLater() async {
      CollectionReference _favourites =
          FirebaseFirestore.instance.collection('favourites');
      User? user = FirebaseAuth.instance.currentUser;
      return _favourites
          .add({"product": documentSnapshot?.data(), "customerId": user?.uid});
    }

    return InkWell(
      onTap: () {
        EasyLoading.show(status: "Saving");
        saveForLater().then((value) {
          EasyLoading.showSuccess("Saved Successfully");
        });
      },
      child: Container(
        height: 56,
        color: Colors.grey[800],
        child: Center(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    CupertinoIcons.bookmark,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Save for Later",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
