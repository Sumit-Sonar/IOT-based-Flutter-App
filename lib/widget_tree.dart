import 'package:djec_app/admin%20pages/adminuserpageorbuttons.dart';
import 'package:djec_app/firebaseAuth/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'admin pages/login_signup.dart'; // Import the admin page
import 'package:djec_app/bluetooth/bluetooth.dart'; // Import the Bluetooth page
import 'package:djec_app/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'firebaseAuth/userAuth.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            // Check the user's role based on their email or other criteria
            final User? user = snapshot.data;
            if (user != null) {
              // Check the user's email to determine the role
              if (user.email == 'admin246@gmail.com') {
                // Admin is logged in, navigate to the admin page
                return LoginPage(); // Replace with your admin page widget
              } else {
                // Regular user is logged in, navigate to BluetoothUi
                return  BluetoothUi(pageProvider: PageProvider(),);
              }
            }
          }
          // User is not logged in, show WelcomeUi
          return WelcomeUi();
        } else {
          // Show a loading indicator while checking authentication state
          return CircularProgressIndicator();
        }
      },
    );
  }
}
