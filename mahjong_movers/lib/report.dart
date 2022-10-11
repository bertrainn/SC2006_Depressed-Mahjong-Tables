import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<bool> isTypeSelected = [
    false,
    false,
    false,
  ];
  final String phoneNumber = "911";
  final TextEditingController _t1 = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  String email = "";
  bool emailValid = false;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme:
              IconThemeData(color: const Color.fromARGB(255, 33, 126, 50)),
          backgroundColor: const Color.fromARGB(255, 33, 126, 50),
          elevation: 2.0,
          centerTitle: true,
          title: Text(
            "Report",
            style: TextStyle(
                color: Color.fromARGB(255, 235, 240, 236),
                fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Color.fromARGB(255, 235, 240, 236),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.popAndPushNamed(context, '/home');
            },
          ),
        ),
        body: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 25.0,
              ),
              Text(
                "  Please select the type of the report",
                style: TextStyle(
                  color: Color.fromARGB(255, 69, 66, 66),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15.0),
              GestureDetector(
                child: buildCheckItem(
                    title: "Verbal Abuse", isSelected: isTypeSelected[0]),
                onTap: () {
                  setState(() {
                    isTypeSelected[0] = !isTypeSelected[0];
                  });
                },
              ),
              GestureDetector(
                child: buildCheckItem(
                    title: "Work-related accident",
                    isSelected: isTypeSelected[1]),
                onTap: () {
                  setState(() {
                    isTypeSelected[1] = !isTypeSelected[1];
                  });
                },
              ),
              GestureDetector(
                child: buildCheckItem(
                    title: "Other issues", isSelected: isTypeSelected[2]),
                onTap: () {
                  setState(() {
                    isTypeSelected[2] = !isTypeSelected[2];
                  });
                },
              ),
              SizedBox(
                height: 20.0,
              ),
              TextFormField(
                onChanged: (val) {
                  if (val.length > 0 &&
                      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(val)) email = val;
                },
                controller: _t1,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                validator: (String? text) {
                  if (text == null || text.isEmpty) {
                    return "Enter a value";
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(email)) {
                    return "Enter valid email";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  fillColor: Color(0xffe6e6e6),
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  hintText: 'Enter Your Email',
                  hintStyle: TextStyle(
                      color: Colors.blueGrey,
                      fontFamily: 'RobotoSlab',
                      fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 33, 126, 50)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 33, 126, 50)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 33, 126, 50)),
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              TextFormField(
                maxLines: 6,
                maxLength: 500,
                controller: _controller,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: " Please briefly describe the issue",
                  hintStyle: TextStyle(
                    fontSize: 13.2,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              TextFormField(
                  maxLines: 6,
                  maxLength: 500,
                  controller: _controller,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: " Please briefly describe the issue",
                    hintStyle: TextStyle(
                      fontSize: 13.0,
                      color: Color(0xFFC5C5C5),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFE5E5E5),
                      ),
                    ),
                    filled: true,
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (String? text) {
                    if (text == null || text.isEmpty) {
                      return "Enter a value";
                    }
                    return null;
                  }),
              SizedBox(
                height: 20.0,
              ),
              Container(
                padding: const EdgeInsets.only(left: 120),
                child: Material(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                    elevation: 5.0,
                    child: MaterialButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Submit!"),
                                content: const Text("Successful Sumbit!"),
                                actions: [
                                  TextButton(
                                      child: const Text("Ok"),
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          // We will use this var to show the result
                                          // of this operation to the user
                                          String message;
                                          try {
                                            // Get a reference to the `feedback` collection
                                            final collection = FirebaseFirestore
                                                .instance
                                                .collection('reports');
                                            await collection.doc().set({
                                              'timestamp':
                                                  FieldValue.serverTimestamp(),
                                              'report': _controller.text,
                                            });
                                            message =
                                                'Report sent successfully';
                                          } catch (e) {
                                            message =
                                                'Error when sending report';
                                          }

                                          Navigator.of(context).popUntil(
                                              (route) => route.isFirst);
                                          Navigator.popAndPushNamed(
                                              context, '/home');
                                        }
                                      }),
                                ],
                              );
                            });
                      },
                      minWidth: 200.0,
                      height: 42.0,
                      child: const Text(
                        'Submit',
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 33, 126, 50),
                        ),
                      ),
                      filled: true,
                    ),
                    textInputAction: TextInputAction.done,
                    validator: (String? text) {
                      if (text == null || text.isEmpty) {
                        return "Enter a value";
                      }
                      return null;
                    }),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 120),
                  child: Material(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                    elevation: 5.0,
                    child: MaterialButton(
                        minWidth: 200.0,
                        height: 42.0,
                        child: const Text(
                          'Submit',
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() == true) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Submit!"),
                                    content: const Text("Successful Sumbit!"),
                                    actions: [
                                      TextButton(
                                          child: const Text("Ok"),
                                          onPressed: () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              // We will use this var to show the result
                                              // of this operation to the user
                                              String message;
                                              try {
                                                // Get a reference to the `feedback` collection
                                                final collection =
                                                    FirebaseFirestore.instance
                                                        .collection('reports');
                                                await collection.doc().set({
                                                  'timestamp': FieldValue
                                                      .serverTimestamp(),
                                                  'report': _controller.text,
                                                  'email': email,
                                                });
                                                message =
                                                    'Report sent successfully';
                                              } catch (e) {
                                                message =
                                                    'Error when sending report';
                                              }

                                              Navigator.of(context).popUntil(
                                                  (route) => route.isFirst);
                                              Navigator.popAndPushNamed(
                                                  context, '/home');
                                            }
                                          }),
                                    ],
                                  );
                                });
                          }
                          ;
                        }),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(240, 212, 20, 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(240, 250, 20, 20),
                child: ElevatedButton.icon(
                    onPressed: _callNumber,
                    label: Text('Emergency \n       Call'),
                    icon: Icon(Icons.call),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 209, 59, 59))),
              ),
            ])));
  }

  _callNumber() async {
    var url = Uri.parse("Tel:911");
    var url = Uri.parse("tel:911");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget buildCheckItem({required String title, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.all(6.0),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.circle,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
          SizedBox(width: 10.0),
          Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue : Colors.grey),
          ),
        ],
      ),
    );
  }
}
