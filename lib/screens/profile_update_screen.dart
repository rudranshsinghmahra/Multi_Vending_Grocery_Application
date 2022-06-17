import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi_vending_grocery_app/services/services_user.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({Key? key}) : super(key: key);
  static const String id = "update-profile";

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final _formKey = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailController = TextEditingController();
  var mobileController = TextEditingController();
  final UserServices _user = UserServices();

  @override
  void initState() {
    _user.getUserDataById(user!.uid).then((value) {
      if (mounted) {
        setState(() {
          firstNameController.text = value['firstName'];
          lastNameController.text = value['lastName'];
          emailController.text = value['email'];
          mobileController.text = user!.phoneNumber.toString();
        });
      }
    });
    super.initState();
  }

  updateProfile() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .update({
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'email': emailController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Update Profile",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomSheet: InkWell(
        onTap: () {
          if(_formKey.currentState!.validate()){
            EasyLoading.show(status: "Updating Profile");
            updateProfile().then((value) {
              EasyLoading.showSuccess("Updated Successfully");
              Navigator.pop(context);
            });
          }
        },
        child: Container(
          width: double.infinity,
          height: 50,
          color: Colors.blueGrey,
          child: const Center(
              child: Text(
            "Update",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          )),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    controller: firstNameController,
                    decoration: const InputDecoration(
                        labelText: "First Name",
                        labelStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.zero),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter First Name";
                      }
                      return null;
                    },
                  )),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: TextFormField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                        labelText: "Last Name",
                        labelStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.zero),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Last Name";
                      }
                      return null;
                    },
                  )),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: mobileController,
                enabled: false,
                decoration: const InputDecoration(
                    labelText: "Mobile Number",
                    labelStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.zero),
              ),
              Expanded(
                  child: TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                    labelText: "Email Id",
                    labelStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.zero),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Email-ID";
                  }
                  return null;
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}
