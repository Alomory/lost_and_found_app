# Lost & Found App

A Flutter application for reporting lost and found belongings. Users can create an account, browse separate lost and found listings, and submit reports for items.

## Screenshots

<table>
  <tr>
    <td colspan="2" align="center">
      <img src="assets/screenshots/authentication.png" alt="Authentication" width="520" />
      <br />
      <sub><b>Authentication</b></sub>
      <div style="height: 30px;"></div>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="assets/screenshots/item-listings.png" alt="Item listings" width="260" />
      <br/>
      <sub><b>Item listings</b></sub>
      <div style="height: 30px;"></div>
    </td>
    <td align="center">
      <img src="assets/screenshots/report-item.png" alt="Report a lost or found item" width="260" />
      <br/>
      <sub><b>Report a lost or found item</b></sub>
      <div style="height: 30px;"></div>
    </td>
  </tr>
  <tr>
    <td colspan="2" align="center">
      <img src="assets/screenshots/detail-screen.png" alt="Lost or found item detail" width="520" />
      <br/>
      <sub><b>Lost or found item detail</b></sub>
      <div style="height: 30px;"></div>
    </td>
  </tr>
</table>

<!-- ![Login and sign-up screens](assets/screenshots/authentication.png)

![Lost and Found item listings|250x400](assets/screenshots/item-listings.png) ![Report a lost or found item|100](assets/screenshots/report-item.png)

![Lost or found item detail](assets/screenshots/detail-screen.png) -->

## Features

- Account registration and sign-in.
- Separate views for lost and found items.
- Item reporting for lost and found belongings.
- SQLite and Firebase integration for application data.

## Technology

- Flutter and Dart
- SQLite
- Firebase

## Run locally

**Requirements:** Flutter SDK, an Android or iOS development environment, and access to the Firebase project configuration used by the app.

From the project root:

```bash
flutter pub get
flutter run
```

To build a release APK:

```bash
flutter build apk --release
```

Firebase must be configured for the target platform before running the application. Keep private credentials and signing keys out of version control.

## Project structure

The application code and reusable UI are organised under `lib/`; static resources and app screenshots are kept under `assets/`.

```text
lib/
├── data/
├── model/
├── screens/
└── widgets/

assets/
├── images/
└── screenshots/
```

## License

Distributed under the MIT License. See [LICENSE](LICENSE).
