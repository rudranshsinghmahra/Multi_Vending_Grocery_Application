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
  final UserServices _userServices = UserServices();
  User? user = FirebaseAuth.instance.currentUser;
  var _userLatitude = 0.0;
  var _userLongitude = 0.0;

  @override
  void initState() {
    _userServices.getUserDataById(user!.uid).then((value) {
      if (user != null) {
        if (mounted) {
          setState(() {
            _userLatitude = value['latitude'];
            _userLongitude = value['longitude'];
          });
        }
      } else {
        Navigator.pushReplacementNamed(context, WelcomeScreen.id);
      }
    });
    super.initState();
  }

  String getDistance(location) {
    var distance = Geolocator.distanceBetween(
        _userLatitude, _userLongitude, location.latitude, location.longitude);
    var distanceInKm = distance / 1000;
    return distanceInKm.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _storeServices.getTopPickedStore(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        List actualShopDistance = [];
        for (int i = 0; i <= snapshot.data!.docs.length - 1; i++) {
          var distance = Geolocator.distanceBetween(
            _userLatitude,
            _userLongitude,
            snapshot.data?.docs[i]['location'].latitude,
            snapshot.data?.docs[i]['location'].longitude,
          );
          var distanceInKm = distance / 1000;
          actualShopDistance.add(distanceInKm);
        }
        actualShopDistance
            .sort(); // this will sort with nearest distance. If nearest distance
        if (actualShopDistance[0] > 10) {
          return Column(
            children: const [
              Padding(
                padding: EdgeInsets.only(left: 20, top: 20),
                child: Text(
                  "No Store Within 10km",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )
            ],
          );
        }
        return Padding(
          padding: const EdgeInsets.only(left: 10,right: 8),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(height: 30,child: Image.asset('assets/like.gif')),
                  const SizedBox(width: 10,),
                  const Text("Top Picked Store Near To You",style: TextStyle(fontWeight: FontWeight.w900,fontSize: 22),)
                ],
              ),
              Flexible(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: snapshot.data!.docs.map(
                    (DocumentSnapshot document) {
                      if (double.parse(getDistance(document['location'])) <= 10) {
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Text(
                                  "${getDistance(document['location'])}km",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Column(
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(left: 20, top: 20),
                              child: Text(
                                "No Store Within 10km",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        );
                      }
                    },
                  ).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
