import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewBookingPage extends StatefulWidget {
  const NewBookingPage({Key? key}) : super(key: key);

  @override
  State<NewBookingPage> createState() => _NewBookingPageState();
}

class _NewBookingPageState extends State<NewBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _jobNameController = TextEditingController();
  final _jobDesController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();

  late UserCredential userCredential;

  Future<String> getPlaceId(String input) async {
    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=AIzaSyBgJNR8v3RGPfTRbnBNrK8t5XrSfJW01Xs'));
    var json = jsonDecode(response.body);
    var placeId = json['candidates'][0]['place_id'].toString();
    return placeId;
  }

  Future<Map<String, dynamic>> getPlace(String input) async {
    final placeId = await getPlaceId(input + ' singapore');
    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=AIzaSyBgJNR8v3RGPfTRbnBNrK8t5XrSfJW01Xs'));
    var json = jsonDecode(response.body);
    var results = json['result'] as Map<String, dynamic>;
    return results;
  }

  void createTransaction(String jobName, String jobDes, String price,
      String location, String payment) async {
    var place = await getPlace(location + " Singapore");
    GeoPoint locationGeo = GeoPoint(place['geometry']['location']['lat'],
        place['geometry']['location']['lng']);
    Map<String, dynamic> transaction = {
      'job': jobName,
      'jobDescription': jobDes,
      'location': locationGeo,
      'locationName': location,
      'payment': payment,
      'transactionAccepted': false,
      'transactionAcceptedDateTime': '',
      'transactionAmount': double.parse(price),
      'transactionCreatedDateTime':
          DateTime.now().millisecondsSinceEpoch.toString(),
      'requestor': FirebaseAuth.instance.currentUser?.uid,
      'servicer': ''
    };
    print(transaction);

    final newTransaction = FirebaseFirestore.instance.collection('transaction');

    await newTransaction.add(transaction);
  }

  AlertDialog accountCreationSuccessDialog(
      BuildContext context, String message) {
    return AlertDialog(
      title: const Text("Notice"),
      content: Text(message),
      actions: [
        TextButton(
          child: const Text("OK"),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);

            Navigator.popAndPushNamed(
              context,
              '/login',
            );
          },
        )
      ],
    );
  }

  AlertDialog accountCreationFailedDialog(
      BuildContext context, String message) {
    return AlertDialog(
      title: const Text("Notice"),
      content: Text(message),
      actions: [
        TextButton(
          child: const Text("OK"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  final List<String> _selectableModeOfPayment = [
    'Cash',
    'Paylah!',
    'PayNow',
  ];

  String _modeOfPayment = "Cash";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: AppBar(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            )),
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 33, 126, 50),
            title: const Text(
              "New Job",
              style: TextStyle(color: Colors.white),
            ),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          )),
      body: Form(
        key: _formKey,
        //autovalidateMode: AutovalidateMode.always,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(
                height: 24.0,
              ),
              TextFormField(
                controller: _jobNameController,
                validator: (value) =>
                    value!.isEmpty ? 'Job Name is Required!' : null,
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  //Do something with the user input.
                  //email = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Job Name',
                  hintText: 'Enter your job name',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white54,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextFormField(
                controller: _jobDesController,
                validator: (value) =>
                    value!.isEmpty ? 'Job Description is Required!' : null,
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  //Do something with the user input.
                  //email = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Job Description',
                  hintText: 'Enter your job description',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white54,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextFormField(
                controller: _priceController,
                validator: (value) =>
                    value!.isEmpty ? 'Price is required' : null,
                style: const TextStyle(color: Colors.black),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  //Do something with the user input.
                  //password = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Price',
                  hintText: 'Enter your item price',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextFormField(
                controller: _locationController,
                validator: (value) =>
                    value!.isEmpty ? 'Location is required' : null,
                style: const TextStyle(color: Colors.black),
                autocorrect: false,
                enableSuggestions: false,
                onChanged: (value) {
                  //Do something with the user input.
                  //password = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter your Location',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              DropdownButtonFormField<String>(
                value: _selectableModeOfPayment[0],
                hint: const Text(
                  'Select Number Of Students',
                ),
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
                onChanged: (newValue) {
                  _modeOfPayment = newValue!;
                },
                validator: (value) => value == null ? 'field required' : null,
                items: _selectableModeOfPayment.map((clientSize) {
                  return DropdownMenuItem(
                    value: clientSize,
                    child: Text(clientSize),
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Material(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                  elevation: 5.0,
                  child: MaterialButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() == true) {
                        //form is valid, proceed further
                        //TODO: remove for production

                        createTransaction(
                            _jobNameController.text,
                            _jobDesController.text,
                            _priceController.text,
                            _locationController.text,
                            _modeOfPayment);
                        print('valid');
                      }
                    },
                    minWidth: 200.0,
                    height: 42.0,
                    child: const Text(
                      'Create Job',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
