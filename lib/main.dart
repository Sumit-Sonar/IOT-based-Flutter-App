import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'admin pages/adminuserpageorbuttons.dart';
import 'splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PageProvider()),
      ],
      child: MyApp(),
    ),
  );
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/splash',
      routes: {
        '/splash': (context) =>  SplashScreen(),
        // ignore: non_constant_identifier_names
        '/useraddpages': (context) => PagesScreen(pageProvider: PageProvider(), sendDataToESP32: (Uint8List ) {  },),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red, // You can change this to your preferred primary color
        scaffoldBackgroundColor: Colors.black, // Set the background color to black
      ),
      home:  SplashScreen(),
    );
  }
}
