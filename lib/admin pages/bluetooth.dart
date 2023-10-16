import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'pagemodels.dart';
import 'package:djec_app/user%20pages/userAuth.dart';
import 'package:djec_app/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'userpageorbuttons.dart';

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
  String panelStatus = ''; // Initialize with 'Unknown' status

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

// Method to check the Bluetooth state
  void _checkBluetoothState() async {
    final bluetoothState = await FlutterBluetoothSerial.instance.state;
    setState(() {
      _bluetoothState = bluetoothState;
    });

    if (_bluetoothState == BluetoothState.STATE_OFF) {
      // Bluetooth is off, show a Snackbar with a message
      final snackBar = SnackBar(
        duration: Duration(seconds: 8),
        content: Text(
          'Bluetooth is off. Please click ok to enable it.',
          style: TextStyle(color: Colors.red),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            // Open Bluetooth settings
            FlutterBluetoothSerial.instance.requestEnable();
            _requestBluetoothPermissions();
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      // Bluetooth is not enabled, handle it accordingly (show a message, etc.).
      SnackBar(content: Text("Bluetooth is required to use this app"));
      _requestBluetoothPermissions();
    }
  }

// Request Bluetooth permissions
  Future<void> _requestBluetoothPermissions() async {
    final bluetoothStatus = await Permission.bluetooth.request();
    if (bluetoothStatus.isGranted) {
      // Bluetooth permission is granted; proceed with enabling Bluetooth.
      // You can also check the Bluetooth state and proceed with your app logic.
      getPairedDevices();
    } else {
      // Handle the case where the user denies Bluetooth permissions.
      // You can show a message or take appropriate action.
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

  Widget _buildPanelStatusText() {
    Color dotColor = Colors.black; // Default color

    if (panelStatus.contains('ON_1')) {
      dotColor = Colors.red;
    } else if (panelStatus.contains('OFF_1')) {
      dotColor = Colors.green;
    } else if (panelStatus.contains('TRIP_1')) {
      dotColor = Colors.orange;
    } else if (panelStatus.contains('ON_2')) {
      dotColor = Colors.red;
    } else if (panelStatus.contains('OFF_2')) {
      dotColor = Colors.green;
    } else if (panelStatus.contains('TRIP_2')) {
      dotColor = Colors.orange;
    }

    return Row(
      // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Status: ',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          connectedDeviceName,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          "-",
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          panelStatus,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              ' • ', // Dot character
              style: TextStyle(
                fontSize: 40,
                color: dotColor, // Set the dot's color
              ), // or TextBaseline.ideographic
            ),
          ],
        ),
      ],
    );
  }

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
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Device:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.05,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              child: DropdownButton(
                                items: _getDeviceItems(),
                                onChanged: (value) =>
                                    setState(() => _device = value!),
                                value: _devicesList.isNotEmpty ? _device : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                        primary: _connected ? Colors.redAccent : Colors.greenAccent,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 10),
                      child: SizedBox(
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [_buildPanelStatusText()],
                        ),
                      ),
                    )
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
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No Device Selected'),
        ),
      );
    } else {
      if (!isConnected) {
        // Attempt to connect to the device
        final newConnection =
            await BluetoothConnection.toAddress(_device?.address);
        if (newConnection.isConnected) {
          connection = newConnection;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Connected to ${_device?.name}'), // Set the connected device's name here
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
              setState(() {
                panelStatus = receivedData;
              });
            },
            onDone: () {
              if (isDisconnecting) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Disconnecting locally'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Disconnected Remotely'),
                  ),
                );
              }
              if (mounted) {
                setState(() {});
              }
            },
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Device connected'),
          ),
        );
        setState(() => _isButtonUnavailable = false);
      }
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
  void _sendDataToESP32(Uint8List dataToSend) {
    if (connection != null && isConnected) {
      try {
        connection!.output.add(dataToSend);
        connection!.output.allSent.then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Device Turned On'),
            ),
          );
        });

        StreamController<String> panelStatusController =
            StreamController<String>.broadcast();

// Initialize the stream subscription
        StreamSubscription<List<int>> streamSubscription;

// Listen for incoming data
        streamSubscription = connection!.input!.listen(
          (data) {
            final receivedData = String.fromCharCodes(data);
            panelStatusController.add(receivedData);
          },
        );

        // Listen for incoming status data
        streamSubscription = connection!.input!.listen(
          (data) {
            final receivedData = String.fromCharCodes(data);
            panelStatusController.add(receivedData);
            setState(() {
              panelStatus = receivedData;
            });
          },
        );
      } catch (e) {
        print('Error sending data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending data: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not connected to the device'),
        ),
      );
    }
  }

// Method to show a SnackBar,
// taking message as the text
  void showSnackBar(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
    showSnackBar(context, 'Device connected');
  }
}
