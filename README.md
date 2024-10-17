# DJ Electro Controls - IoT-Based Flutter App

This IoT-based Flutter application was developed for **DJ Electro Controls** to manage and interact with Bluetooth devices. The app integrates **Flutter Bluetooth Serial** for Bluetooth functionalities, **Firebase Authentication** for user sign-up and login, and **Firestore** for storing and managing user data.

## Features

- **Bluetooth Functionality**: Enables communication with IoT devices using the `flutter_bluetooth_serial` package.
- **User Authentication**: Secure user sign-up and login functionalities using Firebase Authentication.
- **Firestore Integration**: Stores user data such as profiles and preferences using Firestore.
- **Real-time Data Sync**: Updates user and device data in real-time through Firestore.
- **Responsive UI**: Optimized for a seamless experience on various screen sizes, including phones and tablets.

## Tech Stack

- **Flutter**: Framework used for building the app.
- **Flutter Bluetooth Serial**: Bluetooth communication package.
- **Firebase Authentication**: For user authentication (sign-up and login).
- **Firestore**: To store and retrieve user data.
  
## Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Firebase account with a project configured for Authentication and Firestore.
- A Bluetooth-enabled IoT device for testing.

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/dj_electro_controls_iot.git
    ```

2. Navigate to the project directory:
    ```bash
    cd dj_electro_controls_iot
    ```

3. Install dependencies:
    ```bash
    flutter pub get
    ```

4. Set up Firebase:
   - Add your `google-services.json` file for Android and `GoogleService-Info.plist` for iOS in their respective directories.
   - Enable **Firebase Authentication** and **Firestore** in your Firebase console.

5. Run the app:
    ```bash
    flutter run
    ```

## How to Use

1. **Sign Up/Login**: Users can sign up or log in via Firebase Authentication.
2. **Connect to IoT Devices**: Use the Bluetooth functionality to connect to supported devices.
3. **Real-time Data Sync**: User data is stored in Firestore and synced in real-time across devices.
4. **Manage Devices**: Control and monitor connected IoT devices via the app's Bluetooth interface.

## Packages Used

- [`flutter_bluetooth_serial`](https://pub.dev/packages/flutter_bluetooth_serial): For Bluetooth communication.
- [`firebase_auth`](https://pub.dev/packages/firebase_auth): For handling user authentication.
- [`cloud_firestore`](https://pub.dev/packages/cloud_firestore): For storing and managing user data in Firestore.

## Learning Outcomes

- Hands-on experience with **Bluetooth communication** in Flutter using `flutter_bluetooth_serial`.
- Implemented secure **user authentication** and data management using Firebase services.
- Gained insights into real-time data synchronization using **Firestore**.

## Screenshots

_Include some relevant screenshots of the app’s UI and Bluetooth functionalities._

## Contributing

Feel free to contribute by opening a pull request or issue.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
