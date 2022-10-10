import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //late Timer timer;
  int currentNavIndex = 1;

  int noOfJobs = 0;

  List<String> locationNameMap = [];
  List<GeoPoint> geoPointListMap = [];

  List<String> locationName = [];
  List<GeoPoint> geoPointList = [];
  List<String> jobName = [];
  List<String> jobDesc = [];
  List<double> jobPrice = [];
  List<int> jobDate = [];
  List<String> jobID = [];

  @override
  void initState() {
    super.initState();
    RetrieveTransactionData();
  }

  void RetrieveTransactionData() {
    noOfJobs = 0;
    FirebaseFirestore.instance
        .collection('transaction')
        .where('transactionAccepted', isEqualTo: false)
        .where('jobStatus', isEqualTo: 0)
        .where('requestor',
            isNotEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots()
        .listen((snapshot) {
      //iterate each client
      snapshot.docs.forEach((transaction) {
        setState(() {
          //_controllerList.add(Completer());
          geoPointList.add(transaction.get('location'));
          locationName.add(transaction.get('locationName'));
          jobName.add(transaction.get('job'));
          jobDesc.add(transaction.get('jobDescription'));
          jobPrice.add(transaction.get('transactionAmount'));
          jobDate.add(transaction.get('jobTime'));
          jobID.add(transaction.id);

          ++noOfJobs;
        });
      });
    });
  }

  void AcceptTransaction(String transactionID) {
    FirebaseFirestore.instance
        .collection('transaction')
        .doc(transactionID)
        .update({
      "servicer": FirebaseAuth.instance.currentUser?.uid,
      "transactionAcceptedDateTime": DateTime.now().millisecondsSinceEpoch,
      "transactionAccepted": true,
      "jobStatus": 1
    });
  }

  //late GoogleMapController mapController;

  final LatLng _center = const LatLng(1.3502136, 103.8068375);

  final Map<String, Marker> _markers = {};
  Future<void> _onMapCreated(GoogleMapController controller) async {
    //mapController = controller;

    FirebaseFirestore.instance
        .collection('transaction')
        .where('transactionAccepted', isEqualTo: false)
        .where('jobStatus', isEqualTo: 0)
        .snapshots()
        .listen((snapshot) {
      //iterate each client
      snapshot.docs.forEach((transaction) {
        setState(() {
          //_controllerList.add(Completer());
          geoPointListMap.add(transaction.get('location'));
          locationNameMap.add(transaction.get('locationName'));
        });
      });
    });
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _markers.clear();
      for (int i = 0; i < geoPointListMap.length; i++) {
        final marker = Marker(
          markerId: MarkerId(locationNameMap[i]),
          position:
              LatLng(geoPointListMap[i].latitude, geoPointListMap[i].longitude),
          infoWindow: InfoWindow(title: locationNameMap[i]),
        );
        _markers[locationNameMap[i]] = marker;
      }
    });
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
                // ignore: prefer_const_constructors
                const Image(
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
                        zoom: 10.0,
                      ),
                      onMapCreated: _onMapCreated,
                      markers: _markers.values.toSet(),
                    ),
                  ),
                ],
              ),
            ),
            for (var i = 0; i < noOfJobs; ++i)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ListTile(
                      title: Text(jobName[i]),
                      subtitle: Text(
                          jobDesc[i] + "\n" + "\$" + jobPrice[i].toString()),
                      trailing: Text("DateTime: \n" +
                          DateFormat.yMd()
                              .add_jm()
                              .format(DateTime.fromMillisecondsSinceEpoch(
                                  jobDate[i]))
                              .toString()),
                    ),
                    TextButton(
                      onPressed: () {
                        AcceptTransaction(jobID[i]);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Success!"),
                                content:
                                    const Text("Job Accepted Successfully!"),
                                actions: [
                                  TextButton(
                                    child: const Text("Ok"),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .popUntil((route) => route.isFirst);

                                      Navigator.popAndPushNamed(
                                          context, '/home');
                                    },
                                  )
                                ],
                              );
                            });
                      },
                      child: const Text("Accept Job"),
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
              case 2:
                Navigator.pushReplacementNamed(
                  context,
                  '/rewards',
                );
                break;
              case 3:
                Navigator.pushReplacementNamed(
                  context,
                  '/profile',
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
