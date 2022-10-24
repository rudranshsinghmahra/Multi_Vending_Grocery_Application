import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/providers/store_provider.dart';
import 'package:multi_vending_grocery_app/services/product_services.dart';
import 'package:provider/provider.dart';

class ProductFilterWidget extends StatefulWidget {
  const ProductFilterWidget({Key? key}) : super(key: key);

  @override
  State<ProductFilterWidget> createState() => _ProductFilterWidgetState();
}

class _ProductFilterWidgetState extends State<ProductFilterWidget> {
  List _subCatList = [];
  final ProductServices _services = ProductServices();

  @override
  void didChangeDependencies() {
    var _store = Provider.of<StoreProvider>(context);
    FirebaseFirestore.instance
        .collection('products')
        .where('categoryName.mainCategory',
            isEqualTo: _store.selectedProductCategory)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                setState(() {
                  _subCatList.add(doc['categoryName']['subCategory']);
                });
              })
            });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var store = Provider.of<StoreProvider>(context);
    return FutureBuilder<DocumentSnapshot>(
        future: _services.category.doc(store.selectedProductCategory).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Something Went Wrong");
          }

          if (!snapshot.hasData) {
            return Container();
          }
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return ListView(
            scrollDirection: Axis.horizontal,
            children: [
              const SizedBox(
                width: 10,
              ),
              ActionChip(
                elevation: 4,
                label: Text("All ${store.selectedProductCategory}"),
                onPressed: () {
                  store
                      .selectedCategorySub(null); // This will remove the filter
                },
                backgroundColor: Colors.white,
              ),
              ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                physics: const ScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child:
                        _subCatList.contains(data['subCategory'][index]['name'])
                            ? ActionChip(
                                elevation: 4,
                                label: Text(data['subCategory'][index]['name']),
                                onPressed: () {
                                  store.selectedCategorySub(
                                      data['subCategory'][index]['name']);
                                },
                                backgroundColor: Colors.white,
                              )
                            : Container(),
                  );
                },
                itemCount: data.length,
              )
            ],
          );
        });
  }
}
