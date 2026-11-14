# Lost & Found App

A Flutter mobile application for reporting and browsing lost and found items. Users can create an account, browse item listings, and submit reports to help connect people with missing belongings.

> **Project context:** Independently designed and developed by me as an academic project.

## Screenshots

> **Add your image:** Save a screenshot of the login or sign-up screen as `assets/screenshots/authentication.png`, then replace this placeholder with `![Login and sign-up screens](assets/screenshots/authentication.png)`.

> **Add your image:** Save a screenshot showing the Lost and Found listing tabs as `assets/screenshots/item-listings.png`, then replace this placeholder with `![Lost and Found item listings](assets/screenshots/item-listings.png)`.

> **Add your image:** Save a screenshot of the report form as `assets/screenshots/report-item.png`, then replace this placeholder with `![Report a lost or found item](assets/screenshots/report-item.png)`.

## Features

- **Account access:** Login and sign-up flows for application users.
- **Lost and Found listings:** Browse item reports in separate Lost and Found tabs.
- **Item reporting:** Submit a report for an item that has been lost or found.
- **Local and cloud technology integration:** Uses SQLite and Firebase as part of the application's data workflow.

## My Contribution

I developed the application independently, including its main user flows, item-listing experience, reporting workflow, and SQLite/Firebase integration.

## Technology Stack

- **Framework:** Flutter
- **Language:** Dart
- **Local database:** SQLite
- **Backend services:** Firebase

The exact division of responsibilities between SQLite and Firebase depends on the implementation in the source code. Keep credentials and private Firebase configuration out of the repository.

## Getting Started

### Prerequisites

- Flutter SDK installed and configured.
- Android Studio, VS Code, or another Flutter-compatible development environment.
- An Android emulator or physical device.
- Any Firebase configuration required by the application.

### Installation

The Flutter application is located in the `lost_and_founds_simple` directory:

```bash
cd lost_and_founds_simple
flutter pub get
```

### Run

```bash
flutter run
```

## Repository Layout

```text
.
├── lost_and_founds_simple/  # Flutter application
├── assets/
│   └── screenshots/         # Add application screenshots here
└── README.md
```

The repository may also contain supporting academic documents. The layout above highlights the application and the recommended screenshot location.

## Academic Context

This project was developed for the CSM3114 assessment. It is an independently developed project; the application scope and contribution statements above describe my work.

## License

Add a `LICENSE` file if you intend to grant others permission to use, modify, or distribute this code. Until a licence is specified, do not assume that public visibility grants reuse rights.
