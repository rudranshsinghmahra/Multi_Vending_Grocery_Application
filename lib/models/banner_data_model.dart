class BannerDataModel{
  late String image;
  BannerDataModel({required this.image});
  BannerDataModel.fromJson(Map<String,dynamic> map){
    image = map['images'];
  }
}

class VendorBannerDataModel{
  late String image;
  VendorBannerDataModel({required this.image});
  VendorBannerDataModel.fromJson(Map<String,dynamic> map){
    image = map['imageUrl'];
  }
}