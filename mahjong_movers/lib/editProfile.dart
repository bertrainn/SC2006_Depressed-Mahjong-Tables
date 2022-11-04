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
  final _formKeyProfile = GlobalKey<FormState>();
  // temporary

  String name = "";
  String newName = "";
  String email = "";
  String newEmail = "";
  int? phone = null;
  int? newPhone = null;
  String picURL = "";
  String _password = "";
  String about = "";
  String newAbout = "";
  bool _showPassword = false;
  String _newPassword = "";
  XFile? pickedImage;
  File? pickedImageFile;

  final ImagePicker _picker = ImagePicker();

  // Future pickUploadImage() async {
  //   // final image = await ImagePicker().pickImage(
  //   //   source: ImageSource.gallery,
  //   //   maxWidth: 512,
  //   //   maxHeight: 512,
  //   //   imageQuality: 75,
  //   // );

  //   final image = await ImagePicker().pickImage(
  //     source: ImageSource.gallery,
  //     maxWidth: 512,
  //     maxHeight: 512,
  //     imageQuality: 75,
  //   );
  //   if (image == null) return;
  //   final imageTemp = File(image.path);
  //   setState(() {
  //     pickedImage = imageTemp;
  //   });

  // Reference ref = FirebaseStorage.instance.ref().child("profilepic.jpg");
  // await ref.putFile(File(image!.path));
  // String url = (await ref.getDownloadURL()).toString();
  // print(url);
  // }

  Future<String> uploadImage(var imageFile) async {
    final _userID = FirebaseAuth.instance.currentUser!.uid;
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("images/user/profile_images/${_userID}");
    UploadTask uploadTask = ref.putFile(imageFile);
    String imageUrl = "";
    uploadTask.then((res) {
      var url = res.ref.getDownloadURL();
      print(url);
      imageUrl = url.toString();
    });
    setState(() {
      picURL = imageUrl;
    });
    return imageUrl;
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
      print("setState for picURL");
      picURL = url;
    });
  }

  void RetrieveUserData() async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          name = data['name'];
          email = data['email'];
          phone = data["phone"];
          about = data["about"];
          picURL = data["picURL"];
        });
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  void _changePassword(String password) async {
    //Create an instance of the current user.
    final user = await FirebaseAuth.instance.currentUser;
    //Pass in the password to updatePassword.
    user?.updatePassword(password).then((_) {
      print("Successfully changed password");
    }).catchError((error) {
      print("Password can't be changed" + error.toString());
      //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
    });
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );
    setState(() {
      pickedImageFile = File(pickedFile!.path);
    });
  }

  bool _submit() {
    if (_formKeyProfile.currentState!.validate()) {
      update();
      print("successful");
      return true;
    } else {
      print("errors");
      return false;
    }
  }

  Future update() async {
    Map<String, Object> toUpdate = {};

    final docRef = FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser?.uid);
    if (name != newName && name != "") {
      print("newName != null");
      toUpdate["name"] = newName;
    }
    if (newEmail != "") {
      toUpdate["email"] = newEmail;
    }
    if (newPhone != null) {
      toUpdate["phone"] = newPhone as int;
    }
    if (newAbout != "") {
      toUpdate["about"] = newAbout;
    }
    if (_newPassword != "") {
      _changePassword(_newPassword);
    }
    if (toUpdate.isEmpty) {
      print("nothing to update");
      return;
    }
    if (picURL != "") {
      print("picUrl");
      uploadImage(pickedImageFile);
    }

    try {
      docRef.update(toUpdate);
    } catch (e) {
      print("some error occurred");
    }
  }

  @override
  void initState() {
    super.initState();
    RetrieveUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        //extendBodyBehindAppBar: false,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: AppBar(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only()),
              centerTitle: true,
              backgroundColor: Color.fromRGBO(33, 126, 50, 1),
              leading: IconButton(
                //alignment: Alignment.center,
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    Navigator.pushNamed(context, '/profile');
                  });
                },
              ),
              title: Row(
                //mainAxisAlignment: MainAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const Text(
                    "Edit Profile",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              systemOverlayStyle: SystemUiOverlayStyle.dark,
            )),
        body: Form(
          key: _formKeyProfile,
          child: ListView(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              children: [
                ImageProfile(),
                SizedBox(height: 20),
                TextFormField(
                    decoration: InputDecoration(
                      // isDense: true,
                      contentPadding: EdgeInsets.only(
                          top: 20, bottom: 10, right: 20, left: 20),
                      labelText: "Display Name",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: name,
                      hintStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    onChanged: (value) => setState(() => newName = value)),
                TextFormField(
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        value
                            .contains(RegExp(r'[A-Z]', caseSensitive: false))) {
                      return "Enter valid phone number";
                    } else if (value != null &&
                        value.isNotEmpty &&
                        value.length < 8) {
                      return "Phone number too short";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) =>
                      setState(() => newPhone = int.parse(value)),
                  // keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    // isDense: true,
                    contentPadding: EdgeInsets.only(
                        top: 20, bottom: 10, right: 20, left: 20),
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
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}')
                              .hasMatch(value!))) {
                        return "Enter valid email";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      // isDense: true,
                      contentPadding: EdgeInsets.only(
                          top: 20, bottom: 10, right: 20, left: 20),
                      labelText: "Email Address",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: email,
                      hintStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    onChanged: (value) => setState(() => newEmail = value)),
                TextFormField(
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        !RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[!@#\$&*~]).{8,}$')
                            .hasMatch(value!)) {
                      String msg =
                          "Passwords must be at least 8-characters long, mixcased,\n alphanumeric, and has at least one special character\n('%', '#', '@')";
                      return msg;
                    }
                  },
                  obscureText: !_showPassword,
                  obscuringCharacter: "*",
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: ((builder) => getDecision()),
                          );
                        },
                        icon: Icon(Icons.mode_sharp, color: Colors.grey)),
                    contentPadding: EdgeInsets.only(
                        top: 20, bottom: 10, right: 20, left: 20),
                    labelText: "Password",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: "********",
                    hintStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  readOnly: true,
                ),
                TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                          top: 20, bottom: 10, right: 20, left: 20),
                      labelText: "About You",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: (about == "")
                          ? "Please input a description of yourself."
                          : about,
                      hintStyle: (about == "")
                          ? TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            )
                          : TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                    ),
                    onChanged: (value) => setState(() => newAbout = value)),
                SizedBox(height: 35),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 30),
                      OutlinedButton(
                          onPressed: () {
                            Navigator.popAndPushNamed(context, '/profile');
                          },
                          child: const Text("Cancel")),
                      OutlinedButton(
                          onPressed: () {
                            _submit()
                                ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Success!"),
                                        content: Text(
                                            "Account information has been updated"),
                                      );
                                    })
                                : showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("We are sorry :("),
                                        content: Text(
                                            "There were errors, please try again"),
                                      );
                                    });
                          },
                          child: const Text("Make Changes")),
                      SizedBox(width: 30),
                    ])
              ]),
          // ]),
        ));
  }

  Widget ImageProfile() {
    return Stack(children: [
      Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
                width: 4, color: Theme.of(context).scaffoldBackgroundColor),
            boxShadow: [
              BoxShadow(
                  spreadRadius: 2,
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(0, 10))
            ],
            shape: BoxShape.circle,
            color: Colors.white,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: pickedImageFile == null
                  ? AssetImage("assets/images/dummy_profile_pic_2.jpeg")
                  : FileImage(File(pickedImage!.path)) as ImageProvider,
            ),
          ),
        ),
      ),
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
              showModalBottomSheet(
                context: context,
                builder: ((builder) => bottomSheet()),
              );
            },
            icon: Icon(Icons.add_a_photo_rounded, color: Colors.white),
            iconSize: 20.5,
            splashRadius: 10.0,
          ),
        ),
      ),
    ]);
  }

  Widget bottomSheet() {
    return Container(
        height: 100,
        width: double.infinity,
        child: Column(children: <Widget>[
          SizedBox(height: 10),
          Text("Choose Profile Photo",
              style: TextStyle(
                fontSize: 20,
              )),
          SizedBox(height: 2),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFe8e8e8),
                      blurRadius: 3.0,
                      offset: Offset(0, 3.4),
                    )
                  ],
                  borderRadius: BorderRadius.circular(10)),
              child: TextButton.icon(
                icon: Icon(Icons.photo_camera_rounded),
                onPressed: () {
                  print("camera chosen");
                  takePhoto(ImageSource.camera);
                },
                label: Text(
                  "Camera",
                ),
              ),
            ),
            SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFe8e8e8),
                    blurRadius: 3.0,
                    offset: Offset(0, 3.4),
                  )
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton.icon(
                icon: Icon(Icons.image),
                onPressed: () {
                  print("pick from gallery chosen");
                  takePhoto(ImageSource.gallery);
                },
                label: Text("Gallery"),
              ),
            ),
          ]),
        ]));
  }

  Widget getDecision() {
    return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5), topRight: Radius.circular(5)),
        ),
        child: Column(children: <Widget>[
          SizedBox(height: 15),
          Text("Confirm Change Password?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
          SizedBox(height: 26),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextButton.icon(
              icon: Icon(
                Icons.check_circle_outline,
                size: 30,
              ),
              onPressed: () {
                print("confirmed");
                Navigator.pushReplacementNamed(context, '/changePassword');
              },
              label: Text(
                "Yes",
              ),
            ),
            SizedBox(width: 20),
            TextButton.icon(
              icon: Icon(
                Icons.arrow_back_ios_outlined,
                size: 30,
              ),
              onPressed: () {
                print("go back");
                Navigator.pop(context);
              },
              label: Text(
                "Back",
              ),
            ),
          ])
        ]));
  }
}
