import 'dart:async';
import 'dart:convert';

import 'package:djec_app/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../firebaseAuth/userAuth.dart';
import '../pageModel/pagemodels.dart';

class PageProvider extends ChangeNotifier {
  final List<PageModel> _pages = [];

  List<PageModel> get pages => _pages;

  void addPage(PageModel pageModel) {
    final pageNumber = _pages.length + 1;
    final pageName = 'Panel $pageNumber';
    _pages.add(PageModel(pageName, [], "", ""));
    notifyListeners();
  }

  // Save pages to Firestore
  Future<void> savePagesToFirebase(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final pagesCollection =
        firestore.collection('users').doc(userId).collection('pages');

    final pagesData = pages.map((page) => page.toJson()).toList();

    for (var page in pagesData) {
      await pagesCollection.add(page);
    }
  }

  // Retrieve pages from Firestore
  Future<void> getPagesFromFirebase(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final pagesCollection =
        firestore.collection('users').doc(userId).collection('pages');

    final pagesSnapshot = await pagesCollection.orderBy('timestamp').get();

    if (pagesSnapshot.docs.isNotEmpty) {
      final pagesData = pagesSnapshot.docs.map((doc) => doc.data()).toList();

      final List<PageModel> fetchedPages =
          pagesData.map((json) => PageModel.fromJson(json)).toList();

      _pages.clear();
      _pages.addAll(fetchedPages);
      notifyListeners();
    }
  }

  // Method to delete a page by its name
  void deletePage(String pageName) {
    final page = _pages.firstWhere(
      (p) => p.name == pageName,
    );
    if (page != null) {
      _pages.remove(page);
      // You should also delete the page from Firestore here if needed.
      // This will depend on how your Firestore data is structured.
      notifyListeners();
    }
  }

  void addButton(String pageName, String buttonLabel1, String buttonLabel2,
      String buttonLabel3, String buttonLabel4) {
    final page =
        _pages.firstWhere((p) => p.name == pageName, orElse: () => null!);

    if (page != null) {
      if (page.buttons.length < 10) {
        // Convert the buttonLabel to Uint8List (you may use a proper conversion method here)
        final dataToSend1 = Uint8List.fromList(utf8.encode(buttonLabel1));
        final buttonModel1 = ButtonModel(buttonLabel1, dataToSend1);

        final dataToSend2 = Uint8List.fromList(utf8.encode(buttonLabel2));
        final buttonModel2 = ButtonModel(buttonLabel2, dataToSend2);

        final dataToSend3 = Uint8List.fromList(utf8.encode(buttonLabel3));
        final buttonModel3 = ButtonModel(buttonLabel3, dataToSend3);

        final dataToSend4 = Uint8List.fromList(utf8.encode(buttonLabel4));
        final buttonModel4 = ButtonModel(buttonLabel4, dataToSend4);

        page.buttons.add(buttonModel1);
        page.buttons.add(buttonModel2);

        page.buttons.add(buttonModel3);

        page.buttons.add(buttonModel4);

        notifyListeners();
      } else {
        // Handle the case where the maximum number of buttons is reached.
      }
    } else {
      // Handle the case where the specified page does not exist.
    }
  }
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

Widget _signOutButton(BuildContext context) {
  return ElevatedButton(
    onPressed: () async {
      await signOut();
      // ignore: use_build_context_synchronously
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeUi()),
      ); // Perform the sign-out action
      // Close the popup
    },
    child: const Text('Sign Out'),
  );
}

class PagesScreen extends StatelessWidget {
  final PageProvider pageProvider; // Add this line

  final Function(Uint8List) sendDataToESP32; // Add this line
  PagesScreen(
      {required this.pageProvider,
      required this.sendDataToESP32}); // Update the constructor

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final pageProvider = Provider.of<PageProvider>(context);

    Future<void> savePagestofirebase() async {
      // Get the current user's ID
      final userId = UserAuth().currentUser?.uid;

      if (userId != null) {
        // Save pages to Firestore with the user's ID
        await pageProvider.savePagesToFirebase(userId);
        // Show a Snackbar to indicate that pages are saved
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pages saved successfully'),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pages and Buttons'),
        backgroundColor: Colors.black,
        shadowColor: Colors.white,
        actions: <Widget>[
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
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.01, top: 10, right: screenWidth * 0.01),
            child: Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Add this line when creating a page
                          pageProvider.addPage(PageModel(
                            'Panel ${pageProvider.pages.length + 1}',
                            [],
                            "",
                            "",
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text("Add Page"),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => _AddButtonDialog(
                              pageProvider: pageProvider,
                              pages: pageProvider.pages,
                              onSave: (List<PageModel> pages) {},
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text("Add Button"),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Show a CircularProgressIndicator while saving
                          showDialog(
                            context: context,
                            barrierDismissible:
                                false, // Prevent closing the dialog
                            builder: (BuildContext context) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );

                          try {
                            // Save the pages to Firestore
                            await savePagestofirebase();

                            // Close the dialog when the save operation is complete
                            Navigator.of(context, rootNavigator: true).pop();
                          } catch (e) {
                            // Handle errors if needed
                            print("Error saving pages: $e");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text("Save Pages"),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => _DeletePagesDialog(
                              pageProvider: pageProvider,
                              onDelete: (pagesToDelete) {
                                // Delete selected pages from the local list and Firestore
                                for (final pageToDelete in pagesToDelete) {
                                  pageProvider.deletePage(pageToDelete.name);
                                }
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text("Delete Pages"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // Vertical ScrollView for displaying pages
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: pageProvider.pages.map((page) {
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          page.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              page.panelHeading1, // Display the panel heading or an empty string
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: 150,
                            ),
                            Text(
                              page.panelHeading2, // Display the panel heading or an empty string
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: page.buttons.map((button) {
                            return ElevatedButton(
                              onPressed: () {
                                // Send the associated command to the ESP32 device
                                sendDataToESP32(Uint8List.fromList(
                                    utf8.encode(button.label)));
                              },
                              child: Text(button.label),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeletePagesDialog extends StatefulWidget {
  final PageProvider pageProvider;
  final Function(List<PageModel>) onDelete;

  _DeletePagesDialog({required this.pageProvider, required this.onDelete});

  @override
  _DeletePagesDialogState createState() => _DeletePagesDialogState();
}

class _DeletePagesDialogState extends State<_DeletePagesDialog> {
  List<PageModel> selectedPages = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete Pages"),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final page in widget.pageProvider.pages)
                ListTile(
                  title: Text(page.name),
                  leading: Checkbox(
                    value: selectedPages.contains(page),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected != null) {
                          if (selected) {
                            selectedPages.add(page);
                          } else {
                            selectedPages.remove(page);
                          }
                        }
                      });
                    },
                  ),
                ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            widget.onDelete(selectedPages);
            Navigator.of(context).pop();
          },
          child: const Text("Delete"),
        ),
      ],
    );
  }
}

class _AddButtonDialog extends StatefulWidget {
  final PageProvider pageProvider;
  final List<PageModel> pages;
  final Function(List<PageModel>) onSave;

  _AddButtonDialog(
      {required this.pageProvider, required this.pages, required this.onSave});

  @override
  _AddButtonDialogState createState() => _AddButtonDialogState();
}

class _AddButtonDialogState extends State<_AddButtonDialog> {
  final pageNameController = TextEditingController();
  String? selectedPage;

  final buttonLabelController1 = TextEditingController();
  final buttonLabelController2 = TextEditingController();
  final buttonLabelController3 = TextEditingController();
  final buttonLabelController4 = TextEditingController();

  String? panelName1;
  String? panelName2;

  @override
  void dispose() {
    buttonLabelController1.dispose();
    buttonLabelController2.dispose();
    buttonLabelController3.dispose();
    buttonLabelController4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      child: SingleChildScrollView(
        child: AlertDialog(
          title: const Text("Add Button"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedPage,
                items: widget.pages.map((page) {
                  return DropdownMenuItem<String>(
                    value: page.name,
                    child: Text(page.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPage = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Select Page'),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    panelName1 = value;
                  });
                },
                decoration:
                    const InputDecoration(labelText: 'Edit Panel Name 1'),
              ),
              TextField(
                controller: buttonLabelController1,
                decoration: const InputDecoration(labelText: 'Button Label 1'),
              ),
              TextField(
                controller: buttonLabelController2,
                decoration: const InputDecoration(labelText: 'Button Label 2'),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    panelName2 = value;
                  });
                },
                decoration:
                    const InputDecoration(labelText: 'Edit Panel Name 2'),
              ),
              TextField(
                controller: buttonLabelController3,
                decoration: const InputDecoration(labelText: 'Button Label 1'),
              ),
              TextField(
                controller: buttonLabelController4,
                decoration: const InputDecoration(labelText: 'Button Label 2'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final pageName = selectedPage;
                final buttonLabel1 = buttonLabelController1.text;
                final buttonLabel2 = buttonLabelController2.text;
                final buttonLabel3 = buttonLabelController3.text;
                final buttonLabel4 = buttonLabelController4.text;

                final existingPage = widget.pages.firstWhere(
                  (page) => page.name == pageName,
                  orElse: () => null as PageModel,
                );

                if (existingPage != null) {
                  // Update the panel headings if they are not already set
                  if (panelName1 != null) {
                    existingPage.panelHeading1 = panelName1!;
                  }
                  if (panelName2 != null) {
                    existingPage.panelHeading2 = panelName2!;
                  }

                  // Add buttons based on their values
                  if (buttonLabel1.isNotEmpty) {
                    existingPage.buttons
                        .add(ButtonModel(buttonLabel1, Uint8List.fromList([])));
                  }
                  if (buttonLabel2.isNotEmpty) {
                    existingPage.buttons
                        .add(ButtonModel(buttonLabel2, Uint8List.fromList([])));
                  }
                  if (buttonLabel3.isNotEmpty) {
                    existingPage.buttons
                        .add(ButtonModel(buttonLabel3, Uint8List.fromList([])));
                  }
                  if (buttonLabel4.isNotEmpty) {
                    existingPage.buttons
                        .add(ButtonModel(buttonLabel4, Uint8List.fromList([])));
                  }
                } else {
                  final page = PageModel.withSinglePanelHeading(
                    pageName!,
                    [
                      if (buttonLabel1.isNotEmpty)
                        ButtonModel(buttonLabel1, Uint8List.fromList([])),
                      if (buttonLabel2.isNotEmpty)
                        ButtonModel(buttonLabel2, Uint8List.fromList([])),
                      if (buttonLabel3.isNotEmpty)
                        ButtonModel(buttonLabel3, Uint8List.fromList([])),
                      if (buttonLabel4.isNotEmpty)
                        ButtonModel(buttonLabel4, Uint8List.fromList([])),
                    ],
                    panelName1 ?? '',
                    panelName2 ?? '',
                  );

                  widget.pageProvider.addPage(page);
                }

                widget.onSave(widget.pages);
                Navigator.of(context).pop();
              },
              child: Text("Add"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }
}

class SavedPagesScreen extends StatefulWidget {
  final Function(Uint8List) sendDataToESP32;

  SavedPagesScreen({required this.sendDataToESP32});

  @override
  _SavedPagesScreenState createState() => _SavedPagesScreenState();
}

class _SavedPagesScreenState extends State<SavedPagesScreen> {
  List<PageModel> savedPages = [];

  bool isDeviceConnected = false; // Track the connection state

  @override
  void initState() {
    super.initState();
    _loadSavedPages();
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

  String panelStatus1 = '';
  String panelStatus2 = '';
  BluetoothConnection? connection;

  void status() {
    StreamController<String> panelStatusController =
        StreamController<String>.broadcast();

    StreamSubscription<List<int>>? dataStreamSubscription;
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
    // If there's an existing data stream subscription, cancel it
    // dataStreamSubscription?.cancel();

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: const EdgeInsets.all(5.0),
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(50),
            topLeft: Radius.circular(50),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: savedPages.map((page) {
              return Container(
                width: 310,
                margin: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          page.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(children: [
                                Text(
                                  page.panelHeading1,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                ),
                                Text(
                                  "Status -", // You might want to replace this with the actual property from the 'page'
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  panelStatus1, // You might want to replace this with the actual property from the 'page'
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ]),
                            ),
                            GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 40,
                                crossAxisSpacing: 10,
                                childAspectRatio: 1,
                              ),
                              itemCount: 2, // Display the first 2 buttons
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final button = page.buttons[index];
                                return ElevatedButton(
                                  onPressed: () {
                                    final dataToSend = Uint8List.fromList(
                                        utf8.encode('${button.label}\n'));

                                    // Send the data to the ESP32 device
                                    print('Sending data: $dataToSend');

                                    setState(() {
                                      widget.sendDataToESP32(dataToSend);
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: button.label.startsWith("Open") ||
                                                button.label.startsWith("Close")
                                            ? Colors.white
                                            : Colors.black, backgroundColor: button.label
                                            .toLowerCase()
                                            .startsWith("on")
                                        ? Colors.red
                                        : button.label
                                                .toLowerCase()
                                                .startsWith("off")
                                            ? Colors.green
                                            : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    button.label,
                                    style: TextStyle(fontSize: 40),
                                  ),
                                );
                              },
                            ),
                            Visibility(
                              visible: page.panelHeading2 != null &&
                                  page.buttons.length >= 2,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(children: [
                                      Text(
                                        page.panelHeading1,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 120,
                                      ),
                                      Text(
                                        "Status -", // You might want to replace this with the actual property from the 'page'
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        panelStatus2, // You might want to replace this with the actual property from the 'page'
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ]),
                                  ),
                                  GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 40,
                                      crossAxisSpacing: 10,
                                      childAspectRatio: 1,
                                    ),
                                    itemCount: page.buttons.length -
                                        2, // Display the last 2 buttons if available
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final button = page.buttons[index + 2];

                                      return ElevatedButton(
                                        onPressed: () {
                                          final dataToSend = Uint8List.fromList(
                                              utf8.encode('${button.label}\n'));

                                          // Send the data to the ESP32 device
                                          widget.sendDataToESP32(dataToSend);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: button.label.startsWith("Open") ||
                                                      button.label
                                                          .startsWith("Close")
                                                  ? Colors.white
                                                  : Colors.black, backgroundColor: button.label
                                                  .toLowerCase()
                                                  .startsWith("on")
                                              ? Colors.red
                                              : button.label
                                                      .toLowerCase()
                                                      .startsWith("off")
                                                  ? Colors.green
                                                  : Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          button.label,
                                          style: TextStyle(fontSize: 40),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
