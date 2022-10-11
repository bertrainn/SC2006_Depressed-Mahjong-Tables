import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  //late Timer timer;
  int currentNavIndex = 0;

  int noOfJobsR = 0;
  int noOfJobsS = 0;

  List<String> locationNameR = [];
  List<String> jobNameR = [];
  List<String> jobDescR = [];
  List<double> jobPriceR = [];
  List<int> jobDateR = [];
  List<String> jobIDR = [];

  List<String> locationNameS = [];
  List<String> jobNameS = [];
  List<String> jobDescS = [];
  List<double> jobPriceS = [];
  List<int> jobDateS = [];
  List<String> jobIDS = [];

  @override
  void initState() {
    super.initState();
    RetrieveTransactionData();
  }

  void RetrieveTransactionData() {
    noOfJobsR = 0;
    FirebaseFirestore.instance
        .collection('transaction')
        .where('requestor', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots()
        .listen((snapshot) {
      //iterate each client
      snapshot.docs.forEach((transaction) {
        setState(() {
          //_controllerList.add(Completer());
          if (transaction.get('jobStatus') != 6) {
            locationNameR.add(transaction.get('locationName'));
            jobNameR.add(transaction.get('job'));
            jobDescR.add(transaction.get('jobDescription'));
            jobPriceR.add(transaction.get('transactionAmount').toDouble());
            jobDateR.add(transaction.get('jobTime'));
            jobIDR.add(transaction.id);

            ++noOfJobsR;
          }
        });
      });
    });

    noOfJobsS = 0;
    FirebaseFirestore.instance
        .collection('transaction')
        .where('jobStatus', isEqualTo: 1)
        .where('servicer', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots()
        .listen((snapshot) {
      //iterate each client
      snapshot.docs.forEach((transaction) {
        setState(() {
          //_controllerList.add(Completer());
          if (transaction.get('jobStatus') != 6) {
            locationNameS.add(transaction.get('locationName'));
            jobNameS.add(transaction.get('job'));
            jobDescS.add(transaction.get('jobDescription'));
            jobPriceS.add(transaction.get('transactionAmount'));
            jobDateS.add(transaction.get('jobTime'));
            jobIDS.add(transaction.id);

            ++noOfJobsS;
          }
        });
      });
    });
  }

  void AcceptTransaction(String transactionID) {}

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

            Text("Requestor"),
            for (var i = 0; i < noOfJobsR; ++i)
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/jobInfo',
                      arguments: {"jobID": jobIDR[i]});
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      ListTile(
                        title: Text(jobNameR[i]),
                        subtitle: Text(jobDescR[i] +
                            "\n" +
                            "\$" +
                            jobPriceR[i].toString()),
                        trailing: Text("DateTime: \n" +
                            DateFormat.yMd()
                                .add_jm()
                                .format(DateTime.fromMillisecondsSinceEpoch(
                                    jobDateR[i]))
                                .toString()),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(
              height: 20.0,
            ),
            Text("Servicer"),
            for (var i = 0; i < noOfJobsS; ++i)
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/jobInfo',
                      arguments: {"jobID": jobIDS[i]});
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      ListTile(
                        title: Text(jobNameS[i]),
                        subtitle: Text(jobDescS[i] +
                            "\n" +
                            "\$" +
                            jobPriceS[i].toString()),
                        trailing: Text("DateTime: \n" +
                            DateFormat.yMd()
                                .add_jm()
                                .format(DateTime.fromMillisecondsSinceEpoch(
                                    jobDateS[i]))
                                .toString()),
                      ),
                    ],
                  ),
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
