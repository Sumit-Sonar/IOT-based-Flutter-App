import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'admin pages/login_signup.dart';
import 'user pages/user_loginpage.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomeUi extends StatelessWidget {
  const WelcomeUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("BSmart App"),
          shadowColor: Colors.white,
          actions: <Widget>[
            PopupMenuButton<String>(
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'aboutUs',
                  child: const Text('About Us'),
                ),
              ],
              onSelected: (String choice) {
                if (choice == 'aboutUs') {
                  // Navigate to the About Us page or show a dialog with information.
                  // You can replace this with your own logic.
                  // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUsScreen()));
                  // Or show an About Us dialog.
                  showAboutUsDialog(context);
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.black, // Set the background color to black
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                              (states) => Colors.blue), // Change button color
                          minimumSize: MaterialStateProperty.all<Size>(
                              Size(200, 50)), // Width and height
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.admin_panel_settings, // Add the admin icon
                              color: Colors.white, // White icon color
                            ),
                            const SizedBox(width: 8), // Add some spacing
                            const Text(
                              "ADMIN",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // White text color
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 75,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserLoginPage(),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                              (states) => Colors.red), // Change button color
                          minimumSize: MaterialStateProperty.all<Size>(
                              Size(200, 50)), // Width and height
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person, // Add the user icon
                              color: Colors.white, // White icon color
                            ),
                            const SizedBox(width: 8), // Add some spacing
                            const Text(
                              "USER",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // White text color
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  void showAboutUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("About Us"),
          content: RichText(
            text: TextSpan(
              children: [
               const TextSpan(
                  text:
                      "Electrical panel manufacturers specializing in power control centers (PCC) and motor control centers (MCC).\n\n",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
               const TextSpan(
                  text: "Location: ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
               const TextSpan(
                  text: "Valiv, Vasai, India, Maharashtra.\n\n",
                  style: TextStyle(color: Colors.black),
                ),
               const TextSpan(
                  text: "Email: ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
               const TextSpan(
                  text: "info@djelectrocontrols.com\n\n",
                  style: TextStyle(color: Colors.black),
                ),
               const TextSpan(
                  text: "Website: ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                TextSpan(
                    text: "djelectrocontrols.com\n\n",
                    style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch("https://djelectrocontrols.com");
                      }),
                const TextSpan(
                  text: "Developer: ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                TextSpan(
                    text: "sonar02sumit@gmail.com",
                    style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch("mailto:sonar02sumit@gmail.com");
                      }),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
