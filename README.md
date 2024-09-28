# IITH Community App

## Demonstration
1. **Home Page**
    1. Upload posts with images and text.
    2. View posts and upvote and downvote them.
    3. Add comments to others post
    4. ***Get instant summary using AI button!***

![Home Page](https://i.ibb.co/QJc6D1x/collage1.jpg)

2. **Chat Page**
    1. Group chats get auto created if logged in using IITH email.
    2. Chat realtime with other users.
    3. ***Convert tone of your message instantly using AI!***

![Chat Page](https://i.ibb.co/b7HC9Np/collage1-1.jpg)

3. **Shop Page**
    1. Create, buy and sell products.

![Shop Page](https://i.ibb.co/Jdg8qL8/collage1-2.jpg)

4. **Profile/Map Page**
    1. View your profile and log out and sign in from different accounts.
    2. Logging in with your IITH email will auto add the branch and year and will add you to 3 unique groups to chat your branchmates, yearmates.
    3. Shows all building name inside IITH campus.

![Profile/Map Page](https://i.ibb.co/s1dR1Xc/collage1-3.jpg)

## Download App
Download [iith_community_app_armx64.apk](https://github.com/ytgs5148/milan_hackathon/releases/tag/v1.0.0)

## How to Install from the Source Code and Run the App

### Prerequisites
- Install [Flutter](https://flutter.dev/docs/get-started/install) on your machine.
- Install [Android Studio](https://developer.android.com/studio) or [Visual Studio Code](https://code.visualstudio.com/) with Flutter and Dart plugins.
- Ensure you have a Firebase project set up.

### Step-by-Step Instructions

1. **Clone the Repository**
```sh
git clone https://github.com/ytgs5148/milan_hackathon
cd milan_hackathon
```

2. **Install Flutter Dependencies**
```sh
flutter pub get
```

3. **Initialize Firebase Files**

Generate the SHA-1 and SHA-256 keys to Firebase. Console.
    2. Add an Android app to your Firebase project.
    3. Download the google-services.json file and place it in the android/app directory.
    4. Add the Firebase configuration to your Flutter project by creating a lib/firebase_options.dart file. You can use the FlutterFire CLI to generate this file:

```sh
flutterfire configure
```

4. **Add SHA Keys to Firebase**

Generate the SHA-1 and SHA-256 keys to Firebase. If keytool is not installed, you can install it by installing the Java Development Kit (JDK). Follow the instructions [here](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html).
Firebase Configuration:

***IMPORTANT:*** **Change the _~/.android/debug.keystore_ to point to the debug.keystore file located in your pc. In windows, it is generally _C:\Users\ {username}\ .android\debug.keystore_**
```sh
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
```

Copy the SHA-1 and SHA-256 keys and add them to your Firebase project settings under the Android app configuration.

5. **Build the APK**
```sh
flutter build apk
```

6. **Run the App**
```sh
flutter run
```