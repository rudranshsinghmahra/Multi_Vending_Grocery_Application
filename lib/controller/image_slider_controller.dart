import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:multi_vending_grocery_app/models/banner_data_model.dart';

class ImageSliderController extends GetxController {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  late List<BannerDataModel> bannerData;
  bool isLoading = true;
  int currentPage = 0;

  Future<void> getBannerData() async {
    await _fireStore.collection('slider').get().then((value) {
      bannerData =
          value.docs.map((e) => BannerDataModel.fromJson(e.data())).toList();
    });
  }

  void getAllData() async {
    await Future.wait([getBannerData()]).then((value) {
      isLoading = false;
      update();
    });
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getAllData();
  }
}
