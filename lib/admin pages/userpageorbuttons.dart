import 'dart:convert';

import 'package:djec_app/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../user pages/userAuth.dart';
import 'pagemodels.dart';

class PageProvider extends ChangeNotifier {
  final List<PageModel> _pages = [];

  List<PageModel> get pages => _pages;

  void addPage(PageModel pageModel) {
    final pageNumber = _pages.length + 1;
    final pageName = 'Panel $pageNumber';
    _pages.add(PageModel(pageName, [], Timestamp.now()));
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

  void addButton(String pageName, String buttonLabel) {
    final page =
        _pages.firstWhere((p) => p.name == pageName, orElse: () => null!);

    if (page != null) {
      if (page.buttons.length < 10) {
        // Convert the buttonLabel to Uint8List (you may use a proper conversion method here)
        final dataToSend = Uint8List.fromList(utf8.encode(buttonLabel));
        final buttonModel = ButtonModel(buttonLabel, dataToSend);

        page.buttons.add(buttonModel);
        notifyListeners();
      } else {
        // Handle the case where the maximum number of buttons is reached.
      }
    } else {
      // Handle the case where the specified page does not exist.
    }
  }

  // Update buttons in Firestore for a specific page
  Future<void> _updateButtonsInFirestore(
      PageModel page, String pageName) async {
    final firestore = FirebaseFirestore.instance;
    final pagesCollection = firestore.collection('pages');
    final pageDocument =
        await pagesCollection.where('name', isEqualTo: pageName).limit(1).get();

    if (pageDocument.docs.isNotEmpty) {
      final documentId = pageDocument.docs.first.id;
      await pagesCollection.doc(documentId).update({
        'buttons': page.buttons.map((button) => button.toJson()).toList(),
      });
    }
  }
}

// Rest of your code remains unchanged.

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
                          final timestamp = Timestamp
                              .now(); // Add this line when creating a page
                          pageProvider.addPage(PageModel(
                              'Panel ${pageProvider.pages.length + 1}',
                              [],
                              timestamp));
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          onPrimary: Colors.white,
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
                              onSave: () {
                                SnackBar(content: Text("Button added to page"));
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          onPrimary: Colors.white,
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
                          primary: Colors.orange,
                          onPrimary: Colors.white,
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
                          primary: Colors.red, // Set the button color to red
                          onPrimary: Colors.white,
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

          // Horizontal ScrollView for displaying pages
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
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
  final VoidCallback onSave;

  _AddButtonDialog({required this.pageProvider, required this.onSave});

  @override
  _AddButtonDialogState createState() => _AddButtonDialogState();
}

class _AddButtonDialogState extends State<_AddButtonDialog> {
  final buttonLabelController = TextEditingController();
  String? selectedPage;

  @override
  void dispose() {
    buttonLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      child: AlertDialog(
        title: const Text("Add Button"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedPage,
              items: widget.pageProvider.pages.map((page) {
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
              decoration: const InputDecoration(labelText: 'Select Page'),
            ),
            TextField(
              controller: buttonLabelController,
              decoration: const InputDecoration(labelText: 'Button Label'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final pageName = selectedPage;
              final buttonLabel = buttonLabelController.text;
              if (pageName != null && buttonLabel.isNotEmpty) {
                // Add the button to the selected page
                widget.pageProvider.addButton(pageName, buttonLabel);
                // Call the onSave callback to save the pages
                widget.onSave();
                Navigator.of(context).pop();
              }
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

  ElevatedButton buildElevatedButton(ButtonModel button) {
  Color buttonColor;

  // Determine the color based on the button label
  if (button.label.startsWith('O')) {
    buttonColor = Colors.red;
  } else if (button.label.startsWith('C')) {
    buttonColor = Colors.green;
  } else {
    // You can provide a default color here if needed
    buttonColor = Colors.blue; // Default color
  }

  return ElevatedButton(
    onPressed: () {
      final dataToSend = Uint8List.fromList(utf8.encode(button.label));
      // Send the data to the ESP32 device
      widget.sendDataToESP32(dataToSend);
    },
    style: ElevatedButton.styleFrom(
      primary: buttonColor, // Set the background color based on label
      onPrimary: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    child: Text(button.label),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: const EdgeInsets.all(10.0),
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
                width: 300,
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
                        GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 40,
    crossAxisSpacing: 10,
    childAspectRatio: 1,
  ),
  itemCount: page.buttons.length,
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  itemBuilder: (context, index) {
    final button = page.buttons[index];
    return buildElevatedButton(button);
  },
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
