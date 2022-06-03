import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';

class VendorAppBar extends StatelessWidget {
  const VendorAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _store = Provider.of<StoreProvider>(context);

    GeoPoint location = _store.storeDetails?['location'];
    Future mapLauncher() async {
      final availableMaps = await MapLauncher.installedMaps;

      await availableMaps.first.showMarker(
        coords: Coords(location.latitude, location.longitude),
        title: "${_store.storeDetails?['shopName']} is here",
      );
    }

    _callNumber(String phoneNumber) async {
      String number = phoneNumber;
      await FlutterPhoneDirectCaller.callNumber(number);
    }

    return SliverAppBar(
      floating: true,
      snap: true,
      expandedHeight: 260,
      flexibleSpace: SizedBox(
        child: Padding(
          padding: const EdgeInsets.only(top: 110),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(_store.storeDetails?['imageUrl']))),
                child: Container(
                    color: Colors.grey.withOpacity(0.7),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          Text(
                            _store.storeDetails?['dialog'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          Text(
                            _store.storeDetails?['email'],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                          Text(
                            _store.storeDetails?['address'],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                          Text(
                            "Distance: ${_store.distance} km",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Row(
                            children: const [
                              Icon(
                                Icons.star,
                                color: Colors.white,
                              ),
                              Icon(
                                Icons.star,
                                color: Colors.white,
                              ),
                              Icon(
                                Icons.star,
                                color: Colors.white,
                              ),
                              Icon(
                                Icons.star_half,
                                color: Colors.white,
                              ),
                              Icon(
                                Icons.star_outline,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "(3.5)",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.phone,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    _callNumber(_store.storeDetails?['mobile']);
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.map,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    mapLauncher();
                                  },
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )),
              ),
            ),
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.search))
      ],
      title: Text(
        _store.storeDetails!['shopName'],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
