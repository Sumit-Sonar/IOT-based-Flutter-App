import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:djec_app/widget_tree.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
       Future.delayed(Duration(seconds: 4), () {
      // Use pushReplacement to replace the current route
      Navigator.of(context).popUntil(
          (route) => route.isFirst); // Clear all routes except the first one
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                WidgetTree()), // Replace with your main screen
      );
    });
    return AnimatedSplashScreen(
      centered: true,
      // duration: 4,
      splashIconSize: 160,
      // splashTransition: SplashTransition.scaleTransition,
      backgroundColor: Colors.black,
      splash: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset('assets/images/DJEClogo.png'),
          ),
          const Text(
            "djelectrocontrols.com",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
        ],
      ),
      nextScreen: Container(), // You can keep this as Container or set to null
      // Specify the next screen to navigate to using the pushAndRemoveUntil method
    );
  }
}
