📸 BeAcademy

A simple, open-source "BeReal" clone built with SwiftUI and Firebase. No frills, just a public feed of dual-camera moments.

🤔 What is this?

BeAcademy is a fun project that copies the core idea of BeReal:

Dual-Camera Photos: Takes a photo with the back camera, then immediately with the front camera.

Public Feed: Everyone sees every post in one simple, scrolling feed.

No Sign-Up: It uses a public Firebase backend, so anyone can just open the app and post. No accounts, no profiles.

This was built as a learning exercise to mess with the iOS camera, SwiftUI, and a real-time backend.

🚀 Tech Stack

UI: 100% SwiftUI

Backend: Firebase

Firestore: For the real-time database (storing post info).

Firebase Storage: For uploading and storing the actual photo files.

Language: Swift

⚙️ How to Run It

Want to run this yourself? It's easy.

Clone the Repo:

git clone [https://github.com/your-username/BeAcademy.git](https://github.com/your-username/BeAcademy.git)


Create a Firebase Project:

Go to the Firebase Console and create a new project.

Add an iOS App to your project.

Follow the setup to get your Bundle ID from Xcode.

Download the GoogleService-Info.plist file.

Add Firebase to Xcode:

Drag the GoogleService-Info.plist file you just downloaded into the root of your Xcode project.

In Xcode, go to File > Add Packages... and add the firebase-ios-sdk.

Make sure to select FirebaseFirestore and FirebaseStorage when it asks.

Set Up Public Rules:
This app runs without logins, so you need to make your Firebase rules public. (Warning: Don't do this for a real app, it's not secure!)

Firestore Rules:

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /posts/{postId} {
      allow read, write: if true;
    }
  }
}


Storage Rules:

rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /images/{allPaths=**} {
      allow read, write: if true;
    }
  }
}


Add Camera Permission:

In Xcode, open your project settings (top-level blue icon).

Go to the Info tab.

Add a new row: Privacy - Camera Usage Description

For the value, add a message like: BeAcademy needs the camera to take your photo!

Run! 🚀
You should be good to go. Build and run the app on your device.

✨ Future Ideas

This is just a starting point. Feel free to fork it and add...

[ ] A proper "Time to BeReal" notification system.

[ ] A "friends" system (this would require sign-up).

[ ] Photo reactions.

[ ] Deleting your own posts.

🚀  Repo also includes keynote presentation 
