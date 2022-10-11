// ignore_for_file: prefer_const_constructors

import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import './widget/profilePicWidget.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  // temporary
  int currentNavIndex = 3;

  String name = "";
  String email = "";
  int phone = 0;
  String picURL = "";
  String _password = "";
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    RetrieveUserData();
  }

  void pickUploadImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    Reference ref = FirebaseStorage.instance.ref().child("profilepic.jpg");
    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((value) {
      print(value);
    });
  }

  void loadImage() async {
    //current user id
    final _userID = FirebaseAuth.instance.currentUser!.uid;

    //collect the image name
    DocumentSnapshot variable = await FirebaseFirestore.instance
        .collection('data_user')
        .doc('user')
        .collection('personal_data')
        .doc(_userID)
        .get();

    //a list of images names (i need only one)
    var _file_name = variable['path_profile_image'];

    //select the image url
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("images/user/profile_images/${_userID}")
        .child(_file_name[0]);
    var url = await ref.getDownloadURL();
    setState(() {
      picURL = url;
    });
  }

  void RetrieveUserData() {
    FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        // print(data['email']);
        // print(data['name']);
        setState(() {
          name = data['name'];
          email = data['email'];
          phone = data["phone"];
          _password = data["password"];
        });
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      //extendBodyBehindAppBar: false,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: AppBar(
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.only()),
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 33, 126, 50),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                setState(() {
                  Navigator.pushNamed(context, '/profile');
                });
              },
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                const Text(
                  "Edit Profile",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.add_box_rounded),
                onPressed: () {
                  setState(() {
                    Navigator.pushNamed(context, '/newBooking');
                  });
                },
              ),
            ],
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          )),
      body: Container(
        child: ListView(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            children: [
              Stack(children: [
                ProfilePicWidget(picURL),
                Positioned(
                  right: 120,
                  bottom: 2,
                  child: Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 4,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      color: Colors.green,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.only(left: 0, right: 2, bottom: 2),
                      onPressed: () {
                        print("upload image");
                        pickUploadImage();
                      },
                      icon:
                          Icon(Icons.add_a_photo_rounded, color: Colors.white),
                      iconSize: 20.5,
                      splashRadius: 10.0,
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  // isDense: true,
                  contentPadding:
                      EdgeInsets.only(top: 20, bottom: 10, right: 20, left: 20),
                  labelText: "Display Name",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: name,
                  hintStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  // isDense: true,
                  contentPadding:
                      EdgeInsets.only(top: 20, bottom: 10, right: 20, left: 20),
                  labelText: "Phone Number",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: phone.toString(),
                  hintStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  // isDense: true,
                  contentPadding:
                      EdgeInsets.only(top: 20, bottom: 10, right: 20, left: 20),
                  labelText: "Email Address",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: email,
                  hintStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              TextFormField(
                obscureText: !_showPassword,
                obscuringCharacter: "*",
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                      icon: Icon(Icons.remove_red_eye, color: Colors.grey)),
                  contentPadding:
                      EdgeInsets.only(top: 20, bottom: 10, right: 20, left: 20),
                  labelText: "Password",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: "********",
                  hintStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 35),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(width: 30),
                OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/profile');
                    },
                    child: const Text("Cancel")),
                OutlinedButton(
                    onPressed: () {}, child: const Text("Make Changes")),
                SizedBox(width: 30),
              ])
            ]),
      ),
    );
  }
}
