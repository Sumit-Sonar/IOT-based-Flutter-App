import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../pageModel/pagemodels.dart';
import 'package:djec_app/firebaseAuth/userAuth.dart';
import 'package:djec_app/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../admin pages/adminuserpageorbuttons.dart';

void main() {
  runApp(BluetoothUi(
    pageProvider: PageProvider(),
  ));
}

class BluetoothUi extends StatefulWidget {
  const BluetoothUi({super.key, required this.pageProvider});
  final PageProvider pageProvider; // Add this property
  @override
  State<BluetoothUi> createState() => _BluetoothUiState();
}

class _BluetoothUiState extends State<BluetoothUi> {
// Initialize a list to store loaded pages and buttons
  List<PageModel> savedPages = [];

  List<PageModel> get pages => savedPages;

  // Initializing the bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  // Initializing a global key, as it would help us in showing a snackBar later
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  // Get the instance of the Bluetooth
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  // Track the Bluetooth connection with the remote device(connect device)
  BluetoothConnection? connection;

  // ignore: unused_field
  int _deviceState = 0;

  bool isDisconnecting = false;

  Map<String, Color> colors = {
    'onBorderColor': Colors.green,
    'offBorderColor': Colors.red,
    'neutralBorderColor': Colors.transparent,
    'onTextColor': Colors.green,
    'offTextColor': Colors.red,
    'neutralTextColor': Colors.green,
  };

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection!.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;
  String connectedDeviceName = '';
  String panelStatus1 = '';
  String panelStatus2 = '';

  // Initialize with 'Unknown' status

  @override
  void initState() {
    super.initState();
    getPairedDevices();
    _checkBluetoothState();
    _getPagesFromFirebase();
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }
    super.dispose();
  }

  Future<void> _loadSavedPages() async {
    final User? currentUser = UserAuth().currentUser;

    if (currentUser != null) {
      final userId = currentUser.uid;
      final firestore = FirebaseFirestore.instance;
      final pagesCollection =
          firestore.collection('users').doc(userId).collection('pages');

      final pagesSnapshot = await pagesCollection.get();

      if (pagesSnapshot.docs.isNotEmpty) {
        final pagesData = pagesSnapshot.docs.map((doc) => doc.data()).toList();

        final List<PageModel> fetchedPages =
            pagesData.map((json) => PageModel.fromJson(json)).toList();

        setState(() {
          savedPages = fetchedPages;
        });
      }
    }
  }

// Method to retrieve pages from Firebase
  void _getPagesFromFirebase() {
    final User? user = UserAuth().currentUser;
    final userId = user?.uid; // Assuming you have a way to get the user's ID

    if (userId != null) {
      // Call your PageProvider's getPagesFromFirebase method
      // Replace 'pageProvider' with an instance of your PageProvider class
      // Make sure you have an instance of PageProvider accessible in this class.
      widget.pageProvider.getPagesFromFirebase(userId);
    }
  }

  // Request Bluetooth permission from the user
  void _checkBluetoothState() async {
    final bluetoothState = await FlutterBluetoothSerial.instance.state;
    setState(() {
      _bluetoothState = bluetoothState;
    });

    if (_bluetoothState == BluetoothState.STATE_OFF) {
      // Bluetooth is off, show a Snackbar with a message
      final snackBar = SnackBar(
        content: Text(
          'Bluetooth is off. Please enable it to use this app.',
          style: TextStyle(color: Colors.red),
        ),
        duration: Duration(seconds: 6),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () async {
            await FlutterBluetoothSerial.instance.requestEnable();
            setState(() {
              // Update the device list after enabling Bluetooth
              getPairedDevices();
            });
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

// For retrieving and storing the paired devices in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    devices = await _bluetooth.getBondedDevices();

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  final User? user = UserAuth().currentUser;

  Future<void> signOut() async {
    await UserAuth().signOut();
  }

  Widget _title() {
    return const Text('BSmart app');
  }

  Widget _userid() {
    return Text(user?.email ?? 'User email');
  }

  Widget _username() {
    String userEmail = user?.email ?? 'User email';
    int atIndex = userEmail.indexOf('@'); // Find the "@" character index
    String userName =
        atIndex != -1 ? userEmail.substring(0, atIndex) : userEmail;

    return Text('Welcome, $userName',
        style: TextStyle(
            color: Colors.white, fontSize: 25, fontWeight: FontWeight.w400));
  }

  Widget _signOutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await signOut();
        // ignore: use_build_context_synchronously
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomeUi()),
        ); // Perform the sign-out action
        // Close the popup
      },
      child: const Text('Sign Out'),
    );
  }

  // Widget _buildPanelStatusText() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: savedPages.map((page) {
  //       Color dotColor1 = Colors.black; // Default color for status 1
  //       Color dotColor2 = Colors.black; // Default color for status 2

  //       // Use the status information from the current 'page' for status 1
  //       if (page.panelHeading1.contains('ON_1')) {
  //         dotColor1 = Colors.red;
  //       } else if (page.panelHeading1.contains('OFF_1')) {
  //         dotColor1 = Colors.green;
  //       } else if (page.panelHeading1.contains('TRIP_1')) {
  //         dotColor1 = Colors.orange;
  //       }

  //       // Use the status information from the current 'page' for status 2
  //       if (page.panelHeading2.contains('ON_2')) {
  //         dotColor2 = Colors.red;
  //       } else if (page.panelHeading2.contains('OFF_2')) {
  //         dotColor2 = Colors.green;
  //       } else if (page.panelHeading2.contains('TRIP_2')) {
  //         dotColor2 = Colors.orange;
  //       }

  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Status-1: ',
  //             style: TextStyle(
  //               fontSize: 15,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.white,
  //             ),
  //           ),
  //           Text(
  //             page.panelHeading1,
  //             style: TextStyle(
  //               fontSize: 15,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.white,
  //             ),
  //           ),
  //           SizedBox(
  //             width: 5,
  //           ),
  //           Text(
  //             "-",
  //             style: TextStyle(color: Colors.white),
  //           ),
  //           SizedBox(
  //             width: 5,
  //           ),
  //           Text(
  //             'Use the corresponding property for status 1', // You might want to replace this with the actual property from the 'page'
  //             style: TextStyle(
  //               fontSize: 15,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.white,
  //             ),
  //           ),
  //           Row(
  //             children: [
  //               Text(
  //                 ' • ', // Dot character
  //                 style: TextStyle(
  //                   fontSize: 50,
  //                   color: dotColor1,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           Row(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'Status-2: ',
  //                 style: TextStyle(
  //                   fontSize: 15,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //               Text(
  //                 page.panelHeading2,
  //                 style: TextStyle(
  //                   fontSize: 15,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //               SizedBox(
  //                 width: 5,
  //               ),
  //               Text(
  //                 "-",
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //               SizedBox(
  //                 width: 5,
  //               ),
  //               Text(
  //                 'Use the corresponding property for status 2', // You might want to replace this with the actual property from the 'page'
  //                 style: TextStyle(
  //                   fontSize: 15,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     ' • ', // Dot character
  //                     style: TextStyle(
  //                       fontSize: 50,
  //                       color: dotColor2,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ],
  //       );
  //     }).toList(),
  //   );
  // }

  // Now, its time to build the UI
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // This line removes the back button

          backgroundColor: Colors.black,
          shadowColor: Colors.white,
          title: _title(),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.bluetooth),
              onPressed: () {
                FlutterBluetoothSerial.instance.openSettings();
              },
            ),
            Builder(
              builder: (context) => PopupMenuButton<String>(
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'userid',
                    child: _userid(),
                  ),
                  PopupMenuItem<String>(
                    value: 'signout',
                    child: _signOutButton(context),
                  ),
                ],
                icon: const Icon(Icons.more_vert), // Vertical icon
              ),
            )
          ],
        ),
        key: _scaffoldkey,
        backgroundColor: Colors.black,
        body: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.01),
          child: Column(children: <Widget>[
            Visibility(
              visible: _isButtonUnavailable &&
                  _bluetoothState == BluetoothState.STATE_ON,
              child: const LinearProgressIndicator(
                backgroundColor: Colors.amber,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ),
            Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding:
                            EdgeInsets.only(top: screenHeight * 0.01, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _username(),
                          ],
                        )),
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Select Panel :',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.05,
                              color: Colors.white,
                            ),
                          ),
                          Flexible(
                            child: DropdownButton(
                              isExpanded: true,
                              items: _getDeviceItems(),
                              onChanged: (value) =>
                                  setState(() => _device = value!),
                              value: _devicesList.isNotEmpty ? _device : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _isButtonUnavailable
                              ? null
                              : (_connected ? _disconnect : _connect),
                          child: Text(
                            _connected ? 'Disconnect' : 'Connect',
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _connected
                                ? Colors.redAccent
                                : Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 8, top: 10),
                    //   child:
                    //       SizedBox(height: 82, child: _buildPanelStatusText()),
                    // )
                  ],
                ),
              ],
            ),

            // Display saved pages and buttons dynamically
            Expanded(
                child: SavedPagesScreen(
              sendDataToESP32: _sendDataToESP32,
            )),
            // display connected devices
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                "Connected Device: $connectedDeviceName",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ]),
        ));
  }

// Create the list of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text(
          'NONE',
          style: TextStyle(color: Colors.white),
        ),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          value: device,
          child: Text(
            device.name ?? '',
            style: TextStyle(
                color: Colors.black,
                backgroundColor: Colors.white,
                fontSize: 20),
          ),
        ));
      });
    }
    return items;
  }

  //Method to connect to Bluetooth
  void _connect() async {
    if (_device == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('No Device Selected. Please select a device from the list.'),
        ),
      );
      return; // Return early if no device is selected
    }

    setState(() {
      _isButtonUnavailable = true;
    });

    if (!isConnected) {
      // Attempt to connect to the device
      final newConnection =
          await BluetoothConnection.toAddress(_device?.address);
      if (newConnection.isConnected) {
        connection = newConnection;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to ${_device?.name}'),
            duration:
                Duration(seconds: 2), // Set the connected device's name here
          ),
        );
        connectedDeviceName = _device?.name ?? '';
        connection = connection;
        setState(() {
          _connected = true;
        });

        // ignore: unused_local_variable
        StreamSubscription<List<int>> streamSubscription;

// Initialize the stream subscription in your widget, possibly in the initState method.
        streamSubscription = connection!.input!.listen(
          (data) {
            // Handle incoming data
            final receivedData = String.fromCharCodes(data);
            if (receivedData == "ON" ||
                receivedData == "OFF" ||
                receivedData == "TRIP") {
              // Store ON status data for panel 1
              setState(() {
                panelStatus1 = receivedData;
              });
            } else if (receivedData == "ON_1" ||
                receivedData == "OFF_1" ||
                receivedData == "TRIP_1") {
              // Map the received data to the corresponding display text
              String displayText;
              if (receivedData == "ON_1") {
                displayText = "ON";
              } else if (receivedData == "OFF_1") {
                displayText = "OFF";
              } else if (receivedData == "TRIP_1") {
                displayText = "TRIP";
              } else {
                // Handle other cases if needed
                displayText = "Unknown";
              }

              // Store the mapped display text for panel 2
              setState(() {
                panelStatus2 = displayText;
              });
            } else {
              // Handle other data as needed
            }
            panelStatusController.add(receivedData);
          },
        );
      }
      setState(() => _isButtonUnavailable = false);
    }
  }

  //Method to Dissconnect Bluetooth
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await connection!.close();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Device Disconnected'),
        duration: Duration(seconds: 2),
      ),
    );
    if (!connection!.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  //Method to send Message,
  //for turning BL device on

  StreamController<String> panelStatusController =
      StreamController<String>.broadcast();

  StreamSubscription<List<int>>? dataStreamSubscription;

  void _sendDataToESP32(Uint8List dataToSend) {
    if (connection != null && isConnected) {
      connection!.output.add(dataToSend);
      connection!.output.allSent.then((_) {
        print("Data sent!");
      });

      // If there's an existing data stream subscription, cancel it
      dataStreamSubscription?.cancel();

      // Initialize the stream subscription for data
      dataStreamSubscription = connection!.input!.listen(
        (data) {
          final receivedData = String.fromCharCodes(data);

          // Handle the received data as needed for both panels
          if (receivedData == "ON" ||
              receivedData == "OFF" ||
              receivedData == "TRIP") {
            // Store ON status data for panel 1
            setState(() {
              panelStatus1 = receivedData;
            });
          } else if (receivedData == "ON_1" ||
              receivedData == "OFF_1" ||
              receivedData == "TRIP_1") {
            // Store OFF status data for panel 2
            setState(() {
              panelStatus2 = receivedData;
            });
          } else {
            // Handle other data as needed
          }

          // Add received data to panelStatusController
          panelStatusController.add(receivedData);
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not connected to the device'),
        ),
      );
    }
  }
}
