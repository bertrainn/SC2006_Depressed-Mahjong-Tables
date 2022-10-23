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

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKeyProfilePassword = GlobalKey<FormState>();
  String? _oldPassword;
  String? _newPassword;
  String? _confirmNewPassword;
  bool _showPassword = false;
  bool _showOldPassword = false;
  bool _showCNPassword = false;
  String invalidPwdMsg = "There were errors, please try again.";

  Future<void> _changePassword(String currentPassword, String newPassword,
      String confirmNewPassword) async {
    //Create an instance of the current user.
    var user = await FirebaseAuth.instance.currentUser!;
    //Must re-authenticate user before updating the password. Otherwise it may fail or user get signed out.

    final cred = await EmailAuthProvider.credential(
        email: user.email!, password: currentPassword);
    await user.reauthenticateWithCredential(cred).then((value) async {
      await user.updatePassword(newPassword).then((_) {}).catchError((error) {
        print(error);
        return Future.error(error);
      });
    }).catchError((err) {
      if (err.code == "wrong-password") {
        setState(() => invalidPwdMsg =
            "Invalid Password, please input the correct old Password.");
      }
      print(err);
      return Future.error(err);
    });
  }

  Future<bool> _submit() async {
    bool success = true;
    if (!(_formKeyProfilePassword.currentState!.validate())) {
      return false;
    } else {
      try {
        await _changePassword(
            _oldPassword!, _newPassword!, _confirmNewPassword!);
      } catch (err) {
        success = false;
      }
      return success;
    }
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
              backgroundColor: const Color.fromARGB(255, 33, 126, 50),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const Text(
                    "Change Password",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              systemOverlayStyle: SystemUiOverlayStyle.dark,
            )),
        body: Form(
          key: _formKeyProfilePassword,
          child: ListView(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              children: [
                SizedBox(height: 20),
                TextFormField(
                    validator: (value) {
                      if (value == null || value == "") {
                        return "Field is required";
                      }
                    },
                    obscureText: !_showOldPassword,
                    obscuringCharacter: "*",
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _showOldPassword = !_showOldPassword;
                            });
                          },
                          icon: Icon(Icons.remove_red_eye,
                              color: _showOldPassword
                                  ? Colors.green
                                  : Colors.grey)),
                      contentPadding: EdgeInsets.only(
                          top: 20, bottom: 10, right: 20, left: 20),
                      labelText: "Enter Old Password",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    onChanged: (value) => setState(() => _oldPassword = value)),
                SizedBox(height: 10),
                TextFormField(
                    validator: (value) {
                      if (value == null || value == "") {
                        return "Field is required";
                      }
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
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                          icon: Icon(Icons.remove_red_eye,
                              color:
                                  _showPassword ? Colors.green : Colors.grey)),
                      contentPadding: EdgeInsets.only(
                          top: 20, bottom: 10, right: 20, left: 20),
                      labelText: "Enter New Password",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    onChanged: (value) => setState(() => _newPassword = value)),
                SizedBox(height: 10),
                TextFormField(
                    validator: (value) {
                      if (value == null || value == "") {
                        return "Field is required";
                      }
                      if (value != _newPassword) {
                        String msg =
                            "Make sure your confirmed password is correct";
                        return msg;
                      }
                    },
                    obscureText: !_showCNPassword,
                    obscuringCharacter: "*",
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _showCNPassword = !_showCNPassword;
                            });
                          },
                          icon: Icon(Icons.remove_red_eye,
                              color: _showCNPassword
                                  ? Colors.green
                                  : Colors.grey)),
                      contentPadding: EdgeInsets.only(
                          top: 20, bottom: 10, right: 20, left: 20),
                      labelText: "Confirm New Password",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    onChanged: (value) =>
                        setState(() => _confirmNewPassword = value)),
                SizedBox(height: 30),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 30),
                      OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel")),
                      OutlinedButton(
                          onPressed: () async {
                            await _submit()
                                ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      Future.delayed(Duration(seconds: 1), () {
                                        Navigator.pushNamed(
                                            context, '/profile');
                                      });
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
                                        title: Text("Errors :<"),
                                        content: Text(invalidPwdMsg),
                                      );
                                    });
                          },
                          child: const Text("Make Changes")),
                      SizedBox(width: 30),
                    ])
              ]),
        ));
  }
}
