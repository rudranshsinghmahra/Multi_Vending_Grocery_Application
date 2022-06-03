import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/widgets/products/best_selling_products.dart';
import 'package:multi_vending_grocery_app/widgets/products/featured_products.dart';
import 'package:multi_vending_grocery_app/widgets/products/recently_added_products.dart';
import 'package:multi_vending_grocery_app/widgets/vendor_app_bar.dart';
import 'package:multi_vending_grocery_app/widgets/vendor_banner.dart';

import '../widgets/categories_widget.dart';

class VendorHomeScreen extends StatelessWidget {
  const VendorHomeScreen({Key? key}) : super(key: key);
  static const String id = "vendor-home-screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            const VendorAppBar(),
          ];
        },
        body: ListView(
          padding: EdgeInsets.zero,
          children: const [
            VendorBanner(),
            VendorCategories(),
            FeaturedProducts(),
            BestSellingProduct(),
            RecentlyAddedProducts(),
          ],
        ),
      ),
    );
  }
}
