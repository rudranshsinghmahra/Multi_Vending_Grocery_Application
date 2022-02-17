import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:multi_vending_grocery_app/screens/welcome_screen.dart';
import 'package:multi_vending_grocery_app/services/services_user.dart';
import 'package:multi_vending_grocery_app/services/store_services.dart';

class TopPickedStore extends StatefulWidget {
  const TopPickedStore({Key? key}) : super(key: key);

  @override
  _TopPickedStoreState createState() => _TopPickedStoreState();
}

class _TopPickedStoreState extends State<TopPickedStore> {
  final StoreServices _storeServices = StoreServices();
  UserServices _userServices = UserServices();
  User? user = FirebaseAuth.instance.currentUser;
  var _userLatitude = 0.0;
  var _userLongitude = 0.0;

  @override
  void initState() {
    _userServices.getUserDataById(user!.uid).then((value){
      if(user!=null){
        setState(() {
          _userLatitude = value.data()['latitude'];
          _userLongitude = value.data()['longitude'];
        });
      }else{
        Navigator.pushReplacementNamed(context, WelcomeScreen.id);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: StreamBuilder<QuerySnapshot>(
      stream: _storeServices.getTopPickedStore(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        List actualShopDistance = [];
        for(int i = 0;i<= snapshot.data!.docs.length;i++){
          var distance = Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
        }
        return Column(
          children: [
            Flexible(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: snapshot.data!.docs.map(
                  (DocumentSnapshot document) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SizedBox(
                        width: 80,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: Card(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    document['imageUrl'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              child: Text(
                                document['shopName'],
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Text("20Km",style: TextStyle(
                              color: Colors.grey,fontSize: 14
                            ),),
                          ],
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            )
          ],
        );
      },
    ));
  }
}
