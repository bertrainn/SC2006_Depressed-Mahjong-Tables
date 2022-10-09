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
  // temporary
  int currentNavIndex = 4;

  String name = "";
  String email = "";
  int phone = 0;
  String picURL = "";
  int rating = 0;
  int points = 0;
  int reportCount = 0;

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
          rating = data["rating"];
          points = data["points"];
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                const Image(
                  image: AssetImage("assets/icons/mm_logo.png"),
                  width: 70,
                  height: 70,
                ),
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
                  bottom: 0,
                  child: IconButton(
                    onPressed: () {
                      print("upload picture");
                    },
                    icon: Icon(Icons.add_a_photo_rounded, color: Colors.green),
                    iconSize: 25,
                    splashRadius: 10.0,
                  ),
                ),
              ]),
            ]),
      ),
    );
  }
}
