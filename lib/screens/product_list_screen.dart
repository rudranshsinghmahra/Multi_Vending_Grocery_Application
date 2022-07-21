import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/providers/store_provider.dart';
import 'package:multi_vending_grocery_app/widgets/products/product_filter_widget.dart';
import 'package:provider/provider.dart';
import '../widgets/products/product_list.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({Key? key}) : super(key: key);
  static const String id = 'product-list-screen';
  @override
  Widget build(BuildContext context) {
    var storeProvider = Provider.of<StoreProvider>(context);
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              title: Text(
                storeProvider.selectedProductCategory.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              expandedHeight: 110,
              flexibleSpace: Padding(
                padding: const EdgeInsets.only(top: 117),
                child: Container(
                  height: 56,
                  color: Colors.grey,
                  child: const ProductFilterWidget(),
                ),
              ),
            )
          ];
        },
        body: ListView(
          padding: EdgeInsets.zero,
          children: const [
            ProductListWidget(),
          ],
        ),
      ),
    );
  }
}
