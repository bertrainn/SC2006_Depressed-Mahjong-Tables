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
import './widget/profileFieldWidget.dart';
import './widget/statsWidget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //late Timer timer;
  int currentNavIndex = 3;

  String name = "";
  String email = "";
  int phone = 0;
  String picURL = "";
  int rating = 0;
  int points = 0;
  int reportCount = 0;
  String about = "";

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
          print(rating);
          rating = data["rating"] as int;
          print(rating);
          points = data["points"] as int;
          data.containsKey("about") ? about = data["about"] : about = "";
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
                Image(
                  image: AssetImage("assets/icons/mm_logo.png"),
                  width: 70,
                  height: 70,
                ),
                const Text(
                  "Mahjong Movers",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // setState(() {
                  //   // temporary -> we need a settings page i thik
                  //   Navigator.pushNamed(context, '/settings');
                  // });
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
              SizedBox(height: 15),
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
                      padding: EdgeInsets.only(bottom: 1),
                      onPressed: () {
                        print("edit profile");
                        setState(() {
                          Navigator.pushReplacementNamed(
                              context, '/editProfile');
                        });
                      },
                      icon: Icon(Icons.edit, color: Colors.white),
                      iconSize: 22,
                      splashRadius: 10.0,
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 6),
              Center(
                child: Text(name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StatsWidget("Rating", rating, Colors.orange),
                  StatsWidget("Points", points, Colors.green),
                  StatsWidget("Report", reportCount, Colors.red)
                ],
              ),
              SizedBox(height: 40),
              Column(
                children: [
                  ProfileFieldWidget("Phone Number", phone.toString()),
                  SizedBox(height: 10),
                  ProfileFieldWidget("Email Address", email),
                  SizedBox(height: 10),
                  ProfileFieldWidget("About you", about),
                  SizedBox(height: 10),
                ],
              )
            ]),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentNavIndex,
        onTap: (index) {
          setState(() {
            currentNavIndex = index;
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(
                  context,
                  '/task',
                );
                break;
              case 1:
                Navigator.pushReplacementNamed(
                  context,
                  '/home',
                );
                break;
              case 2:
                Navigator.pushReplacementNamed(
                  context,
                  '/rewards',
                );
                break;
              case 4:
                Navigator.pushReplacementNamed(
                  context,
                  '/report',
                );
                break;
              default:
                break;
            }
          });
        },
        backgroundColor: const Color.fromARGB(255, 33, 126, 50),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Task',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_sharp),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard_rounded),
            label: 'Rewards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'report',
          )
        ],
      ),
    );
  }
}
