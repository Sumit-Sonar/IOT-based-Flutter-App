import 'package:flutter/material.dart';

void main() {
  runApp(const DeviceButtons());
}

class DeviceButtons extends StatelessWidget {
  const DeviceButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        height: double.infinity,
        // padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(children: [
              ElevatedButton(
                onPressed: () {
                  // Add your logic for "eb on" button here
                },
                child: Text('eb on'),
              ),
              SizedBox(width: 10), // Add some spacing between buttons
              ElevatedButton(
                onPressed: () {
                  // Add your logic for "eb off" button here
                },
                child: Text('eb off'),
              ),
            ]),

            SizedBox(width: 50), // Add some spacing between buttons
            Column(children: [
              ElevatedButton(
                onPressed: () {
                  // Add your logic for "eb on" button here
                },
                child: Text('eb on'),
              ),
              SizedBox(width: 10), // Add some spacing between buttons
              ElevatedButton(
                onPressed: () {
                  // Add your logic for "eb off" button here
                },
                child: Text('eb off'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
