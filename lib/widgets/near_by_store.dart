import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:multi_vending_grocery_app/providers/cart_provider.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/store_provider.dart';
import '../services/store_services.dart';

class NearByStore extends StatefulWidget {
  const NearByStore({Key? key}) : super(key: key);

  @override
  State<NearByStore> createState() => _NearByStoreState();
}

class _NearByStoreState extends State<NearByStore> {
  StoreServices storeServices = StoreServices();
  PaginateRefreshedChangeListener refreshChangeListener =
      PaginateRefreshedChangeListener();

  @override
  Widget build(BuildContext context) {
    final storeData = Provider.of<StoreProvider>(context);
    final _cart = Provider.of<CartProvider>(context);
    storeData.getUserLocation(context);

    String getDistance(location) {
      var distance = Geolocator.distanceBetween(storeData.userLatitude,
          storeData.userLongitude, location.latitude, location.longitude);
      var distanceInKm = distance / 1000;
      return distanceInKm.toStringAsFixed(2);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: storeServices.getNearbyStores(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
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

          SchedulerBinding.instance?.addPostFrameCallback((_) =>
            setState(() {
              _cart.getDistance(actualShopDistance[0]);
            })
          );
          if (actualShopDistance[0] > 10) {
            return Container();
          }
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RefreshIndicator(
                  child: PaginateFirestore(
                    bottomLoader: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
                    header: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Padding(
                            padding:
                                EdgeInsets.only(left: 8, right: 8, top: 20),
                            child: Text(
                              "All Nearby Store",
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 18),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: 8, right: 8, bottom: 10),
                            child: Text(
                              "Find Quality Products Near You",
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilderType: PaginateBuilderType.listView,
                    itemBuilder: (context, documentSnapshots, index) => Padding(
                      padding: const EdgeInsets.all(4),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 110,
                              child: Card(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    documentSnapshots[index]['imageUrl'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  documentSnapshots[index]['shopName'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(documentSnapshots[index]['dialog'],
                                    style: kStoreCardStyle),
                                const SizedBox(
                                  height: 3,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width - 250,
                                  child: Text(
                                    documentSnapshots[index]['address'],
                                    overflow: TextOverflow.ellipsis,
                                    style: kStoreCardStyle,
                                  ),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  "${getDistance(documentSnapshots[index]['location'])}km",
                                  overflow: TextOverflow.ellipsis,
                                  style: kStoreCardStyle,
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Row(
                                  children: const [
                                    Icon(
                                      //this is to show rating
                                      Icons.star,
                                      size: 12,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      "3.2",
                                      style: kStoreCardStyle,
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    query: storeServices.getNearbyStorePagination(),
                    listeners: [
                      refreshChangeListener,
                    ],
                    footer: SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Stack(
                          children: [
                            const Center(
                              child: Text(
                                "**That's all folks**",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            Image.asset(
                              'assets/city.png',
                              color: Colors.black12,
                            ),
                            Positioned(
                              right: 5,
                              top: 68,
                              child: SizedBox(
                                width: 100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Made By :",
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                    Text(
                                      "RUDRANSH",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Anton',
                                          letterSpacing: 2,
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    isLive: true,
                  ),
                  onRefresh: () async {
                    refreshChangeListener.refreshed = true;
                  },
                )
              ],
            ),
          );
        }
      },
    );
  }
}
