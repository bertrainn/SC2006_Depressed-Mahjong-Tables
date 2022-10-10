import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'signup.dart';
import 'forgotPassword.dart';
import 'home.dart';
import 'admin.dart';
import 'newBooking.dart';
import 'jobInfo.dart';
import 'profile.dart';
import 'task.dart';
import 'chat.dart';
import 'rewards.dart';
import 'report.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mahjong Movers',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/forgotPassword': (context) => const ForgotPassPage(),
        '/home': (context) => const HomePage(),
        '/newBooking': (context) => const NewBookingPage(),
        '/jobInfo': (context) => const JobInfoPage(),
        '/profile': (context) => const ProfilePage(),
        '/task': (context) => const TaskPage(),
        '/chat': (context) => const ChatPage(),
        '/rewards': (context) => const RewardsPage(),
        '/report': (context) => const ReportPage(),
      },
    );
  }
}
