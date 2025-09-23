
# Finanapp - Personal Finance Tracker

[![Flutter](https://img.shields.io/badge/Framework-Flutter-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Language-Dart-0175C2?style=for-the-badge&logo=dart)](https://dart.dev)
[![BLoC](https://img.shields.io/badge/State%20Management-BLoC-4595D3?style=for-the-badge&logo=flutter)](https://bloclibrary.dev)
[![Hive](https://img.shields.io/badge/Database-Hive-FCA337?style=for-the-badge)](https://hive.dev)

A simple and elegant Flutter application for managing your personal finances, tracking expenses and income with ease. Built with a focus on clean architecture, robust state management, and a smooth user experience.

## ✨ Key Features

- **Transaction Management**: Easily add, edit, and delete income and expense transactions.
- **Real-time Balance**: View your current balance update instantly with every transaction.
- **Visual Feedback**: A friendly piggy bank mascot changes its expression based on your financial balance (happy, neutral, or sad).
- **Persistent Storage**: All data is stored locally on your device using **Hive**, ensuring offline access and fast performance.
- **Robust State Management**: Utilizes the **BLoC** pattern for predictable and scalable state management.
- **Pull-to-Refresh**: Quickly refresh your transaction list.
- **Filtering & Searching**: Efficiently find transactions by title, date range, or type (expense/income).
- **Responsive UI**: A clean and intuitive interface that adapts to different screen sizes.

## 📱 Screenshots

| Home Screen                                                                                             | Add Transaction Modal                                                                                         | Edit Transaction                                                                                           |
| ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
|  |  |  |
| *View your balance and transaction history.*                                                             | *Quickly add new expenses or incomes.*                                                                        | *Modify the details of an existing transaction.*                                                            |

## 🛠️ Tech Stack & Architecture

This project is built with a modern Flutter stack, emphasizing separation of concerns and testability.

- **Framework**: [Flutter](https://flutter.dev)
- **Language**: [Dart](https://dart.dev)
- **Architecture**: Clean Architecture principles with a BLoC pattern.
  - **UI Layer**: Widgets and Screens (`/lib/screens`, `/lib/widgets`)
  - **Business Logic Layer**: BLoC (`/lib/blocs`)
  - **Data Layer**: Services and Models (`/lib/services`, `/lib/models`)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) for predictable state handling.
- **Local Database**: [Hive](https://pub.dev/packages/hive) for fast, lightweight, and offline data persistence.
- **Testing**:
  - **Unit & BLoC Testing**: [bloc_test](https://pub.dev/packages/bloc_test) and [mocktail](https://pub.dev/packages/mocktail).
  - **UI Snapshot Testing**: [golden_toolkit](https://pub.dev/packages/golden_toolkit) to prevent unintended UI changes.
- **Code Generation**: [build_runner](https://pub.dev/packages/build_runner) and [hive_generator](https://pub.dev/packages/hive_generator) for model adapters.

## 📂 Project Structure

The codebase is organized into a scalable and maintainable structure:

```
lib/
├── blocs/              # BLoC classes for state management
│   └── transaction/
├── models/             # Data models (e.g., Transaction)
├── screens/            # UI screens for the application
├── services/           # Business logic and data access (database, error handling)
├── utils/              # Constants and utility functions
├── widgets/            # Reusable UI components
└── main.dart           # Main application entry point
test/
├── golden/             # Golden tests for UI components
├── helpers/            # Test helpers and mock data
└── ...                 # Other unit and widget tests
```

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.8.1 or higher)
- A code editor like VS Code or Android Studio

### Installation & Setup

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/your-username/finanapp.git
    cd finanapp
    ```
2.  **Install dependencies:**
    ```sh
    flutter pub get
    ```
3.  **Run the code generator for Hive:**
    This step is necessary to generate the `*.g.dart` files for your Hive data models.
    ```sh
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
4.  **Run the app:**
    ```sh
    flutter run
    ```

## ✅ Running Tests

This project includes a comprehensive suite of tests to ensure code quality and stability.

1.  **Run Unit & Widget Tests:**
    ```sh
    flutter test
    ```
2.  **Run Golden (Snapshot) Tests:**
    Golden tests compare your UI components against reference images.
    - To run the tests and compare with existing golden files:
      ```sh
      flutter test
      ```
    - To update or generate new golden files after making intentional UI changes:
      ```sh
      flutter test --update-goldens
      ```

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request
