import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class JobInfoPage extends StatefulWidget {
  const JobInfoPage({Key? key}) : super(key: key);

  @override
  State<JobInfoPage> createState() => _JobInfoPageState();
}

class _JobInfoPageState extends State<JobInfoPage> {
  //late Timer timer;

  String locationNameMap = '';
  late GeoPoint geoPointListMap;

  Future<void>? _launched;

  String locationName = '';
  late GeoPoint geoPointList;
  String jobName = '';
  String jobDesc = '';
  double jobPrice = 0.0;
  int jobDate = 0;
  String jobID = '';
  String jobPayment = '';
  String requestorID = '';
  String servicerID = '';
  String displayName = '';
  String displayNameR = '';
  String psiStr = '';
  int jobStatus = 0;
  int transactionCreatedTime = 0;
  int transactionAcceptedTime = 0;
  int psi = 0;
  bool canDelete = false;
  bool canDeleteS = false;

  void RetrieveTransactionData(String jobID) async {
    FirebaseFirestore.instance
        .collection('transaction')
        .doc(jobID)
        .get()
        .then((DocumentSnapshot) {
      setState(() {
        locationName = DocumentSnapshot.get('locationName');
        geoPointList = DocumentSnapshot.get('location');
        jobName = DocumentSnapshot.get('job');
        jobDesc = DocumentSnapshot.get('jobDescription');
        jobPrice = DocumentSnapshot.get('transactionAmount').toDouble();
        jobDate = DocumentSnapshot.get('jobTime');
        jobID = DocumentSnapshot.id;
        jobPayment = DocumentSnapshot.get('payment');
        requestorID = DocumentSnapshot.get('requestor');
        servicerID = DocumentSnapshot.get('servicer');
        jobStatus = DocumentSnapshot.get('jobStatus');
        transactionCreatedTime =
            DocumentSnapshot.get('transactionCreatedDateTime');
        transactionAcceptedTime =
            DocumentSnapshot.get('transactionAcceptedDateTime');
      });
    });
    if (servicerID != "") {
      FirebaseFirestore.instance
          .collection('user')
          .doc(servicerID)
          .get()
          .then((user) {
        setState(() {
          displayName = user['name'];
        });
      });
    }
    if (requestorID != "") {
      FirebaseFirestore.instance
          .collection('user')
          .doc(requestorID)
          .get()
          .then((user) {
        setState(() {
          displayNameR = user['name'];
        });
      });
    }
    //await Future.delayed(Duration(seconds: 1));
  }

  Future<void> fetchPSI() async {
    final response = await http.get(Uri.parse(
        'https://api.data.gov.sg/v1/environment/psi?date=2022-10-22'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var psiReading = jsonDecode(response.body);

      psi = psiReading['items'][2]["readings"]["pm25_twenty_four_hourly"]
          ["national"];

      if (psi >= 0 && psi <= 55) {
        psiStr = "Normal";
      } else if (psi >= 56 && psi <= 150) {
        psiStr = "Elevated";
      } else if (psi >= 151 && psi <= 250) {
        psiStr = "High";
      } else {
        psiStr = "Very High";
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load PSI');
    }
  }

  LatLng _center = LatLng(1.3502136, 103.8068375);

  final Map<String, Marker> _markers = {};
  Future<void> _onMapCreated(GoogleMapController controller) async {
    setState(() {
      _markers.clear();

      final marker = Marker(
        markerId: MarkerId(locationName),
        position: LatLng(geoPointList.latitude, geoPointList.longitude),
        infoWindow: InfoWindow(title: locationName),
      );
      _markers[locationName] = marker;
    });
    //await Future.delayed(Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    RetrieveTransactionData(arguments['jobID']);
    fetchPSI();

    _center = LatLng(geoPointList.latitude, geoPointList.longitude);

    if ((DateTime.now().millisecondsSinceEpoch - transactionCreatedTime) <=
        180000) {
      canDelete = true;
    }

    if ((DateTime.now().millisecondsSinceEpoch - transactionAcceptedTime) <=
        180000) {
      canDeleteS = true;
    }

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
              "View Job",
              style: TextStyle(color: Colors.white),
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.local_police),
                onPressed: () async {
                  await launchUrl(Uri(scheme: 'tel', path: '999'));
                  // setState(() async {
                  //   await launchUrl(Uri(scheme: 'tel', path: '999'));
                  // });
                },
              ),
              IconButton(
                icon: const Icon(Icons.chat),
                onPressed: () {
                  setState(() {
                    Navigator.pushNamed(context, '/chat',
                        arguments: {'jobID': arguments['jobID']});
                  });
                },
              ),
            ],
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
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(
                    width: 400,
                    height: 300,
                    child: GoogleMap(
                      myLocationButtonEnabled: false,
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: _center,
                        zoom: 15.0,
                      ),
                      onMapCreated: _onMapCreated,
                      markers: _markers.values.toSet(),
                    ),
                  ),
                ],
              ),
            ),
            if (jobStatus == 1)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ListTile(
                      title: Text("Job Name: " + jobName + "\n"),
                      subtitle: Text("Job Description: " +
                          jobDesc +
                          "\n\n" +
                          "Price: \$" +
                          jobPrice.toString() +
                          "\n\n" +
                          "DateTime: " +
                          DateFormat.yMd()
                              .add_jm()
                              .format(
                                  DateTime.fromMillisecondsSinceEpoch(jobDate))
                              .toString() +
                          "\n\n" +
                          "PSI Level: " +
                          psiStr +
                          "\n\n" +
                          "Mode of Payment: " +
                          jobPayment +
                          "\n\n" +
                          "Person Service: " +
                          displayName +
                          "\n\n" +
                          "Person Requested: " +
                          displayNameR),
                    ),
                    if (canDeleteS)
                      TextButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Success!"),
                                  content: const Text("Job Retracted!"),
                                  actions: [
                                    TextButton(
                                      child: const Text("Ok"),
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('transaction')
                                            .doc(arguments['jobID'])
                                            .update({
                                          "jobStatus": 0,
                                          'transactionAcceptedDateTime': 0,
                                          'transactionAccepted': false,
                                          'servicer': ""
                                        });
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);

                                        Navigator.popAndPushNamed(
                                            context, '/home',
                                            arguments: {});
                                      },
                                    )
                                  ],
                                );
                              });
                        },
                        child: const Text("Retract Job"),
                      ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Success!"),
                                content: const Text(
                                    "Job Accepted Successfully! Now awaiting for Requestor to confirm!"),
                                actions: [
                                  TextButton(
                                    child: const Text("Ok"),
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('transaction')
                                          .doc(arguments['jobID'])
                                          .update({"jobStatus": 2});
                                      Navigator.of(context)
                                          .popUntil((route) => route.isFirst);

                                      Navigator.popAndPushNamed(
                                          context, '/rate', arguments: {
                                        "UID": requestorID,
                                        "jobID": arguments['jobID'],
                                        "servicer": true
                                      });
                                    },
                                  )
                                ],
                              );
                            });
                      },
                      child: const Text("Job Done"),
                    ),
                  ],
                ),
              ),
            if (jobStatus == 2)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ListTile(
                      title: Text("Job Name: " + jobName + "\n"),
                      subtitle: Text("Job Description: " +
                          jobDesc +
                          "\n\n" +
                          "Price: \$" +
                          jobPrice.toString() +
                          "\n\n" +
                          "DateTime: " +
                          DateFormat.yMd()
                              .add_jm()
                              .format(
                                  DateTime.fromMillisecondsSinceEpoch(jobDate))
                              .toString() +
                          "\n\n" +
                          "PSI Level: " +
                          psiStr +
                          "\n\n" +
                          "Mode of Payment: " +
                          jobPayment +
                          "\n\n" +
                          "Person Service: " +
                          displayName +
                          "\n\n" +
                          "Person Requested: " +
                          displayNameR),
                    ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Success!"),
                                content: const Text("Job Completed!"),
                                actions: [
                                  TextButton(
                                    child: const Text("Ok"),
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('transaction')
                                          .doc(arguments['jobID'])
                                          .update({"jobStatus": 3});
                                      Navigator.of(context)
                                          .popUntil((route) => route.isFirst);

                                      Navigator.popAndPushNamed(
                                          context, '/rate', arguments: {
                                        "UID": servicerID,
                                        "jobID": arguments['jobID']
                                      });
                                    },
                                  )
                                ],
                              );
                            });
                      },
                      child: const Text("Job Done"),
                    ),
                  ],
                ),
              ),
            if (servicerID != '' && jobStatus == 0)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ListTile(
                      title: Text("Job Name: " + jobName + "\n"),
                      subtitle: Text("Job Description: " +
                          jobDesc +
                          "\n\n" +
                          "Price: \$" +
                          jobPrice.toString() +
                          "\n\n" +
                          "DateTime: " +
                          DateFormat.yMd()
                              .add_jm()
                              .format(
                                  DateTime.fromMillisecondsSinceEpoch(jobDate))
                              .toString() +
                          "\n\n" +
                          "PSI Level: " +
                          psiStr +
                          "\n\n" +
                          "Mode of Payment: " +
                          jobPayment +
                          "\n\n"),
                    ),
                    if (canDeleteS)
                      TextButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Success!"),
                                  content: const Text("Job Retracted!"),
                                  actions: [
                                    TextButton(
                                      child: const Text("Ok"),
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('transaction')
                                            .doc(arguments['jobID'])
                                            .update({
                                          "jobStatus": 0,
                                          'transactionAcceptedDateTime': 0,
                                          'servicer': ""
                                        });
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);

                                        Navigator.popAndPushNamed(
                                            context, '/home',
                                            arguments: {});
                                      },
                                    )
                                  ],
                                );
                              });
                        },
                        child: const Text("Retract Job"),
                      ),
                  ],
                ),
              ),
            if (servicerID == '')
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ListTile(
                      title: Text("Job Name: " + jobName + "\n"),
                      subtitle: Text("Job Description: " +
                          jobDesc +
                          "\n\n" +
                          "Price: \$" +
                          jobPrice.toString() +
                          "\n\n" +
                          "DateTime: " +
                          DateFormat.yMd()
                              .add_jm()
                              .format(
                                  DateTime.fromMillisecondsSinceEpoch(jobDate))
                              .toString() +
                          "\n\n" +
                          "PSI Level: " +
                          psiStr +
                          "\n\n" +
                          "Mode of Payment: " +
                          jobPayment +
                          "\n\n" +
                          "Person Service: Yet to be found"),
                    ),
                    if (canDelete)
                      TextButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Success!"),
                                  content: const Text("Job Deleted!!"),
                                  actions: [
                                    TextButton(
                                      child: const Text("Ok"),
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('transaction')
                                            .doc(arguments['jobID'])
                                            .update({"jobStatus": 6});
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);

                                        Navigator.popAndPushNamed(
                                            context, '/home',
                                            arguments: {});
                                      },
                                    )
                                  ],
                                );
                              });
                        },
                        child: const Text("Delete Job"),
                      ),
                  ],
                ),
              ),
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
