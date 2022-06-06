import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:multi_vending_grocery_app/providers/auth_provider.dart';
import 'package:multi_vending_grocery_app/providers/location_provider.dart';
import 'package:multi_vending_grocery_app/screens/login_screen.dart';
import 'package:multi_vending_grocery_app/screens/main_screen.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);
  static const String id = 'map-screen';

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng currentLocation = const LatLng(28.529918076937708, 77.25392945998702);
  late GoogleMapController mapController;
  bool isLoading = false;
  bool loggedIn = false;
  User? user;
  @override

  void initState() {
    getCurrentUser();
    super.initState();
  }

  Future<void> getCurrentUser() async {
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
    if (user != null) {
      setState(() {
        loggedIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final locationData = Provider.of<LocationProvider>(context);
    final _auth = Provider.of<AuthProvider>(context);
    setState(() {
      currentLocation = LatLng(locationData.latitude, locationData.longitude);
    });
    void onCreate(GoogleMapController controller) {
      setState(() {
        mapController = controller;
      });
    }

    return Container(
      color: Colors.deepPurpleAccent,
      child: SafeArea(
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: currentLocation, zoom: 14.4746),
                  zoomControlsEnabled: true,
                  minMaxZoomPreference: const MinMaxZoomPreference(1.5, 20.8),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.normal,
                  mapToolbarEnabled: true,
                  onCameraMove: (CameraPosition position) {
                    setState(() {
                      isLoading = true;
                    });
                    locationData.onCameraMove(position);
                  },
                  onMapCreated: onCreate,
                  onCameraIdle: () {
                    setState(() {
                      isLoading = false;
                    });
                    locationData.getMoveCamera();
                  },
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 45),
                    height: 50,
                    width: 50,
                    child: Image.asset('assets/marker.png'),
                  ),
                ),
                const Center(
                  child: SpinKitPulse(
                    color: Colors.black54,
                    size: 50,
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  child: Container(
                    height: size.height / 2.8,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isLoading
                              ? const LinearProgressIndicator()
                              : Container(),
                          TextButton.icon(
                            onPressed: () {

                            },
                            icon: const Icon(Icons.location_searching),
                            label: Text(
                              isLoading
                                  ? "Locating..." : locationData.selectedAddress == null ? "Locating..."
                                  : "${locationData.selectedAddress?.featureName}",
                              style: const TextStyle(fontSize: 20),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Text(
                            isLoading
                                ? "" : locationData.selectedAddress == null ? ""
                                : "${locationData.selectedAddress?.addressLine}",
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(height: size.height / 40),
                          SizedBox(
                            width: double.infinity,
                            height: size.height / 18,
                            child: AbsorbPointer(
                              absorbing: isLoading ? true : false,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: isLoading
                                        ? MaterialStateProperty.all(Colors.grey)
                                        : MaterialStateProperty.all(
                                            Colors.deepPurple)),
                                onPressed: () {
                                  locationData.savePreferences();
                                  if (loggedIn == false) {
                                    Navigator.pushReplacementNamed(
                                        context, LoginScreen.id);
                                  } else {
                                    setState(() {
                                      _auth.latitude = locationData.latitude;
                                      _auth.longitude = locationData.longitude;
                                      _auth.address = locationData.selectedAddress?.addressLine;
                                      _auth.location = locationData.selectedAddress?.featureName;
                                    });
                                    _auth.updateUser(
                                        id: user?.uid,
                                        number: user?.phoneNumber,
                                    ).then((value){
                                      if(value==true){
                                        Navigator.pushReplacementNamed(context, MainScreen.id);
                                      }
                                    });
                                  }
                                },
                                child: const Text("Confirm Location"),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
