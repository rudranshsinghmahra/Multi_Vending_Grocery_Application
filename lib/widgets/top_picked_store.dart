import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:multi_vending_grocery_app/screens/vendors_home_screen.dart';
import 'package:multi_vending_grocery_app/services/store_services.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

import '../providers/store_provider.dart';

class TopPickedStore extends StatefulWidget {
  const TopPickedStore({Key? key}) : super(key: key);

  @override
  State<TopPickedStore> createState() => _TopPickedStoreState();
}

class _TopPickedStoreState extends State<TopPickedStore> {
  @override
  Widget build(BuildContext context) {
    final StoreServices _storeServices = StoreServices();
    final storeData = Provider.of<StoreProvider>(context);
    storeData.getUserLocation(context);

    String getDistance(location) {
      var distance = Geolocator.distanceBetween(storeData.userLatitude,
          storeData.userLongitude, location.latitude, location.longitude);
      var distanceInKm = distance / 1000;
      return distanceInKm.toStringAsFixed(2);
    }

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
            storeData.userLatitude,
            storeData.userLongitude,
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
          padding: const EdgeInsets.only(left: 10, right: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 20),
                child: Row(
                  children: [
                    SizedBox(height: 30, child: Image.asset('assets/like.gif')),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      "Top Picked Store Near To You",
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
                    )
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: snapshot.data!.docs.map(
                    (DocumentSnapshot document) {
                      if (double.parse(getDistance(document['location'])) <=
                          10) {
                        return InkWell(
                          onTap: () {
                            storeData.getSelectedStore(
                                document, getDistance(document['location']));
                            PersistentNavBarNavigator
                                .pushNewScreenWithRouteSettings(
                              context,
                              settings: const RouteSettings(
                                  name: VendorHomeScreen.id),
                              screen: const VendorHomeScreen(),
                              withNavBar: true,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          child: Padding(
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
