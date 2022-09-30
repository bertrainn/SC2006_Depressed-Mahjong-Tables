import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class JobInfoPage extends StatefulWidget {
  const JobInfoPage({Key? key}) : super(key: key);

  @override
  State<JobInfoPage> createState() => _JobInfoPageState();
}

class _JobInfoPageState extends State<JobInfoPage> {
  //late Timer timer;

  String locationNameMap = '';
  late GeoPoint geoPointListMap;

  String locationName = '';
  late GeoPoint geoPointList;
  String jobName = '';
  String jobDesc = '';
  double jobPrice = 0.0;
  int jobDate = 0;
  String jobID = '';

  // Future<void> RetrieveTransactionData(String jobID) async {
  //   FirebaseFirestore.instance
  //       .collection('transaction')
  //       .doc(jobID)
  //       .get()
  //       .then((DocumentSnapshot) {
  //     locationName = DocumentSnapshot.get('locationName');
  //     geoPointList = DocumentSnapshot.get('location');
  //     jobName = DocumentSnapshot.get('job');
  //     jobDesc = DocumentSnapshot.get('jobDescription');
  //     jobPrice = DocumentSnapshot.get('transactionAmount');
  //     jobDate = DocumentSnapshot.get('jobTime');
  //     jobID = DocumentSnapshot.id;
  //   });
  //   await Future.delayed(Duration(seconds: 1));
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   Future.delayed(Duration.zero, () {
  //     setState(() {
  //       arguments = ModalRoute.of(context).settings.arguments;
  //     });

  //     RetrieveTransactionData(arguments['jobID']);
  //   });
  // }
  // }

  //late GoogleMapController mapController;

  //final LatLng _center = const LatLng(1.3502136, 103.8068375);

  //final Map<String, Marker> _markers = {};
  // Future<void> _onMapCreated(GoogleMapController controller) async {
  //   //mapController = controller;

  //   FirebaseFirestore.instance
  //       .collection('transaction')
  //       .where('transactionAccepted', isEqualTo: false)
  //       .snapshots()
  //       .listen((snapshot) {
  //     //iterate each client
  //     snapshot.docs.forEach((transaction) {
  //       setState(() {
  //         //_controllerList.add(Completer());
  //         geoPointListMap.add(transaction.get('location'));
  //         locationNameMap.add(transaction.get('locationName'));
  //       });
  //     });
  //   });
  //   await Future.delayed(Duration(seconds: 1));
  //   print(geoPointListMap);

  //   setState(() {
  //     _markers.clear();
  //     for (int i = 0; i < geoPointListMap.length; i++) {
  //       final marker = Marker(
  //         markerId: MarkerId(locationNameMap[i]),
  //         position:
  //             LatLng(geoPointListMap[i].latitude, geoPointListMap[i].longitude),
  //         infoWindow: InfoWindow(title: locationNameMap[i]),
  //       );
  //       _markers[locationNameMap[i]] = marker;
  //     }
  //     print(_markers);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    return Scaffold(
      extendBody: true,
      //extendBodyBehindAppBar: false,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: AppBar(
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.only()),
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 33, 126, 50),
            title: const Text(
              "View Job",
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

            // Card(
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(30.0),
            //   ),
            //   child: Column(
            //     mainAxisSize: MainAxisSize.max,
            //     children: <Widget>[
            //       SizedBox(
            //         width: 400,
            //         height: 300,
            //         child: GoogleMap(
            //           myLocationButtonEnabled: false,
            //           mapType: MapType.normal,
            //           initialCameraPosition: CameraPosition(
            //             target: _center,
            //             zoom: 10.0,
            //           ),
            //           onMapCreated: _onMapCreated,
            //           markers: _markers.values.toSet(),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

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
                        "\n"),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Accept Job"),
                  )
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
