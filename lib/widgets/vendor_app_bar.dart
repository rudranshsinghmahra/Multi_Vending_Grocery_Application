import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:multi_vending_grocery_app/models/product_model.dart';
import 'package:multi_vending_grocery_app/widgets/search_card.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';
import '../providers/store_provider.dart';

class VendorAppBar extends StatefulWidget {
  const VendorAppBar({Key? key}) : super(key: key);

  @override
  State<VendorAppBar> createState() => _VendorAppBarState();
}

class _VendorAppBarState extends State<VendorAppBar> {
  static List<Product> product = [];
  String? offer;
  String? shopName;
  DocumentSnapshot? documentSnapshot;

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection('products')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          documentSnapshot = doc;

          offer = (((doc['comparedPrice']) - (doc['price'])) /
                  doc['comparedPrice'] *
                  100)
              .toStringAsFixed(0);
          product.add(Product(
              productName: doc['productName'],
              category: doc['categoryName']['mainCategory'],
              image: doc['productImage'],
              weight: doc['weight'],
              brand: doc['brand'],
              shopName: doc['seller']['shopName'],
              price: doc['price'],
              comparedPrice: doc['comparedPrice'],
              documentSnapshot: doc));
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    product.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var store = Provider.of<StoreProvider>(context);

    GeoPoint location = store.storeDetails?['location'];
    Future mapLauncher() async {
      final availableMaps = await MapLauncher.installedMaps;

      await availableMaps.first.showMarker(
        coords: Coords(location.latitude, location.longitude),
        title: "${store.storeDetails?['shopName']} is here",
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
                        image: NetworkImage(store.storeDetails?['imageUrl']))),
                child: Container(
                    color: Colors.grey.withOpacity(0.7),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          Text(
                            store.storeDetails?['dialog'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          Text(
                            store.storeDetails?['email'],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                          Text(
                            store.storeDetails?['address'],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                          Text(
                            "Distance: ${store.distance} km",
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
                                    _callNumber(store.storeDetails?['mobile']);
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
        IconButton(
            onPressed: () {
              setState(() {
                shopName = store.storeDetails?['shopName'];
              });
              showSearch(
                context: context,
                delegate: SearchPage<Product>(
                  onQueryUpdate: (s) => print(s),
                  items: product,
                  searchLabel: 'Search product',
                  suggestion: const Center(
                    child: Text('Filter product by name, category, price'),
                  ),
                  failure: const Center(
                    child: Text('No product found :('),
                  ),
                  filter: (product) => [
                    product.productName,
                    product.category,
                    product.brand,
                    product.price.toString(),
                  ],
                  builder: (product) => shopName != product.shopName
                      ? Container()
                      : SearchCard(
                          offer: offer,
                          product: product,
                          documentSnapshot: product.documentSnapshot,
                        ),
                ),
              );
            },
            icon: const Icon(CupertinoIcons.search))
      ],
      title: Text(
        store.storeDetails!['shopName'],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
