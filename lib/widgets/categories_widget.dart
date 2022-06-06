import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/providers/store_provider.dart';
import 'package:multi_vending_grocery_app/screens/product_list_screen.dart';
import 'package:multi_vending_grocery_app/services/product_services.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class VendorCategories extends StatefulWidget {
  const VendorCategories({Key? key}) : super(key: key);

  @override
  State<VendorCategories> createState() => _VendorCategoriesState();
}

class _VendorCategoriesState extends State<VendorCategories> {
  ProductServices productServices = ProductServices();

  List _categoriesList = [];

  @override
  void didChangeDependencies() {
    var _store = Provider.of<StoreProvider>(context);

    FirebaseFirestore.instance
        .collection('products')
        .where('seller.sellerUid', isEqualTo: _store.storeDetails?['uid'])
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        setState(() {
          _categoriesList.add(element['categoryName']['mainCategory']);
          print(element['categoryName']['mainCategory']);
        });
      });
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var _services = Provider.of<StoreProvider>(context);

    return FutureBuilder(
      future: productServices.category.get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Something Went Wrong"),
          );
        }
        if (_categoriesList.isEmpty) {
          return Container();
        }
        if (!snapshot.hasData) {
          return Container();
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      image: const DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/city.png')),
                    ),
                    child: const Text(
                      "Shop by Category",
                      style: TextStyle(
                          shadows: [
                            Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 3.0,
                                color: Colors.black)
                          ],
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 30),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Wrap(
                direction: Axis.horizontal,
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  return _categoriesList.contains(document['name'])
                      ? Padding(
                          padding: const EdgeInsets.all(3.5),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15)),
                            width: 120,
                            height: 180,
                            child: InkWell(
                              onTap: () {
                                _services.selectedCategory(document['name']);
                                _services.selectedCategorySub(null);
                                pushNewScreenWithRouteSettings(
                                  context,
                                  settings: const RouteSettings(
                                      name: ProductListScreen.id),
                                  screen: const ProductListScreen(),
                                  withNavBar: false,
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                        color: Colors.grey, width: 1.5)),
                                child: Column(
                                  children: [
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        height: 120,
                                        child:
                                            Image.network(document['images']),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8),
                                      child: Text(
                                        document['name'],
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : const Text("");
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
