import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class RatePage extends StatefulWidget {
  const RatePage({Key? key}) : super(key: key);

  @override
  State<RatePage> createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _selectableRating = ['1', '2', '3', '4', '5'];
  String _rating = "1";

  void UpdateRating(String UID, String rate) {
    double computeRating = 0;
    int points = 0;
    var userInfo = FirebaseFirestore.instance
        .collection('user')
        .doc(UID)
        .get()
        .then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      computeRating = data['rating'];
      points = data['points'];
    });

    computeRating += int.parse(rate);
    computeRating = computeRating / 2;
    points += int.parse(rate) * 2;
    FirebaseFirestore.instance
        .collection('user')
        .doc(UID)
        .update({"rating": computeRating, "points": points});
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

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
            title: const Text(
              "Rate the user",
              style: TextStyle(color: Colors.white),
            ),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          )),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            Text("Rate the user below"),
            Form(
                key: _formKey,
                //autovalidateMode: AutovalidateMode.always,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        DropdownButtonFormField<String>(
                          value: _selectableRating[0],
                          hint: const Text(
                            'Select Rating',
                          ),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            border: UnderlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(32.0)),
                            ),
                          ),
                          onChanged: (newValue) {
                            _rating = newValue!;
                          },
                          validator: (value) =>
                              value == null ? 'field required' : null,
                          items: _selectableRating.map((ratingValue) {
                            return DropdownMenuItem(
                              value: ratingValue,
                              child: Text(ratingValue),
                            );
                          }).toList(),
                        ),
                        const SizedBox(
                          height: 24.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Material(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30.0)),
                            elevation: 5.0,
                            child: MaterialButton(
                              onPressed: (() {
                                UpdateRating(arguments['UID'], _rating);
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Success!"),
                                        content: const Text("Rate Successful!"),
                                        actions: [
                                          TextButton(
                                            child: const Text("Ok"),
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection('transaction')
                                                  .doc(arguments['jobID'])
                                                  .update({"jobStatus": 6});
                                              Navigator.of(context).popUntil(
                                                  (route) => route.isFirst);

                                              Navigator.popAndPushNamed(
                                                  context, '/home');
                                            },
                                          )
                                        ],
                                      );
                                    });
                              }),
                              minWidth: 200.0,
                              height: 42.0,
                              child: const Text(
                                'Rate the user',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 500.0,
                        ),
                      ],
                    ),
                  ),
                )),

            // This is to make it scroll nicely
            const SizedBox(
              height: 100.0,
            ),
          ],
        ),
      ),
    );
  }
}
