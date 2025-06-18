# Voiced

Voiced is a mobile application that enables people who are partially sighted or have low vision to 'hear' text from images, converting their ears into their eyes.

## 🚀 Getting Started & Setup

This project uses Firebase for its backend services. The configuration files containing secret API keys are not committed to this repository for security reasons. To build and run the project, you must connect it to your own Firebase instance by following these steps.

### Prerequisites

* A Google account to access Firebase.
* Flutter installed on your machine.
* The FlutterFire CLI installed globally. If you don't have it, run this command:
    ```sh
    dart pub global activate flutterfire_cli
    ```

### Setup Instructions

1.  **Clone the Repository**
    ```sh
    git clone [https://github.com/Mellie45/Voiced.git](https://github.com/Mellie45/Voiced.git)
    cd Voiced
    ```

2.  **Create a Firebase Project**
    * Go to the [Firebase Console](https://console.firebase.google.com/).
    * Click **"Add project"** and give it any name you like (e.g., "Voiced-Test"). Continue through the setup steps.

3.  **Configure the Flutter App**
    * In your terminal, from the root of this project folder (`Voiced`), run the configuration command:
        ```sh
        flutterfire configure
        ```
    * The tool will ask you to log in to Google and then present a list of your Firebase projects. Use the arrow keys to select the project you just created.
    * When prompted to select platforms, choose **android** and **ios**.
    * The tool will automatically register the apps with your Firebase project and generate the necessary configuration files locally (`firebase_options.dart`, `GoogleService-Info.plist`, `google-services.json`).

4.  **Run the App**
    * You are now ready to run the app.
    * ```sh
        flutter pub get
        flutter run
        ```
The Android package name and the bundle ID for iOS is com.example.voiced.     

