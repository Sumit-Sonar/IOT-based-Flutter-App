IoT-Based Flutter App for DJ Electro Controls
This project is an IoT-based mobile application developed using Flutter for DJ Electro Controls. The app allows users to control and monitor IoT devices over Bluetooth, with functionalities such as user authentication and data storage powered by Firebase.

Features
1. Bluetooth Functionality
The app utilizes the flutter_bluetooth_serial package to establish and manage Bluetooth connections with IoT devices.
Users can:
Discover nearby Bluetooth devices.
Pair with devices.
Send commands and receive responses from the IoT hardware via Bluetooth.
2. User Authentication
Firebase Authentication is integrated into the app, allowing users to:
Sign up and log in using email and password.
Securely store user credentials with Firebase's backend services.
3. Firestore Database
The app stores user-related data using Firestore, including:
Device preferences.
Bluetooth connection history.
User-specific IoT settings.

Screenshots
Folder is created on repository.

Getting Started
Prerequisites
Before running the project, ensure you have:

Flutter SDK installed. You can download it from Flutter's official website.
Firebase account set up with Authentication and Firestore enabled. Follow the instructions here.
Installation
Clone the repository:


git clone https://github.com/yourusername/yourrepo.git
cd yourrepo
Install dependencies:


flutter pub get
Set up Firebase:

Add your google-services.json file for Android in the /android/app directory.
Follow Firebase's setup instructions for iOS (if applicable).

Run the app:
flutter run

Packages Used
flutter_bluetooth_serial: For Bluetooth communication with IoT devices.
firebase_auth: For Firebase Authentication.
cloud_firestore: For storing user data in Firestore.
Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

License
This project is licensed under the MIT License. See the LICENSE file for details.
