# Finanapp - Personal Finance Tracker

[![Flutter](https://img.shields.io/badge/Framework-Flutter-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Language-Dart-0175C2?style=for-the-badge&logo=dart)](https://dart.dev)
[![BLoC](https://img.shields.io/badge/State%20Management-BLoC-4595D3?style=for-the-badge&logo=flutter)](https://bloclibrary.dev)
[![Hive](https://img.shields.io/badge/Database-Hive-FCA337?style=for-the-badge)](https://hive.dev)

A simple and elegant Flutter application for managing your personal finances. Track expenses and income with an intuitive interface, backed by robust architecture and offline-first storage.

---

## ✨ Key Features

### Core Functionality
- **Trade Management**: Add, edit, and delete income and expense trades with ease
- **Real-time Balance Tracking**: See your balance update instantly with every trade
- **Offline-First**: All data stored locally using Hive - works without internet
- **Visual Feedback**: Animated piggy bank mascot reflects your financial health

### User Experience
- **Smart Filtering**: Search by title, filter by date range or trade type
- **Pull-to-Refresh**: Quick data refresh with a simple swipe
- **Form Validation**: Comprehensive input validation prevents data errors
- **Error Handling**: User-friendly error messages with detailed logging

### Technical Excellence
- **Clean Architecture**: Separated concerns with BLoC pattern
- **Type Safety**: Leverages Dart's strong typing and null safety
- **Responsive Design**: Adapts to different screen sizes seamlessly
- **State Management**: Predictable state with flutter_bloc

---

## 🚀 Quick Start

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.8.1 or higher
- Dart 3.8.1 or higher
- A code editor (VS Code, Android Studio, or IntelliJ)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/finanapp.git
   cd finanapp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate required files**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

---

## 🏗️ Architecture Overview

Finanapp follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│    (Screens, Widgets, BLoC)             │
├─────────────────────────────────────────┤
│          Business Logic Layer           │
│         (Services, BLoC Logic)          │
├─────────────────────────────────────────┤
│            Data Layer                   │
│    (Database, Models, Repositories)     │
└─────────────────────────────────────────┘
```

### Tech Stack
- **Framework**: Flutter 3.8.1+
- **Language**: Dart 3.8.1+
- **State Management**: flutter_bloc, equatable
- **Local Database**: Hive with hive_flutter
- **Date Formatting**: intl
- **Animations**: animated_list_plus
- **Code Generation**: build_runner, hive_generator

---

## 📂 Project Structure

```
lib/
├── blocs/                  # State management
│   └── trade/              # Trade BLoC (events, states, logic)
├── models/                 # Data models
│   └── trade.dart          # Trade model with Hive annotations
├── screens/                # UI screens
│   ├── home_screen.dart    # Main dashboard
│   └── edit_trade_screen.dart
├── services/               # Business logic
│   ├── database_service.dart
│   ├── trade_service.dart
│   └── error_handler.dart
├── utils/                  # Constants and helpers
│   └── constants.dart
├── widgets/                # Reusable components
│   ├── balance/            # Balance display widgets
│   ├── trade/              # Trade-related widgets
│   ├── common/             # Shared widgets
│   └── error/              # Error display widgets
└── main.dart               # Application entry point
```

---

## 🎯 Usage Guide

### Adding a Trade
1. Tap the **+** floating action button
2. Fill in the title and value
3. Select trade type (Expense or Income)
4. Tap **Save**

### Editing a Trade
1. **Long-press** any trade in the list
2. Modify the details
3. Tap **Save Changes**

### Deleting a Trade
1. Tap the **trash icon** on any trade
2. Confirm deletion

### Filtering Trades
- Use the search bar to find trades by title
- Apply date range filters
- Filter by type (Expenses only or Income only)

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Development Guidelines
- Follow the existing code style (see `analysis_options.yaml`)
- Write meaningful commit messages
- Test your changes thoroughly
- Update documentation if needed
- For detailed technical specifications, see [SPECIFICATIONS.md](SPECIFICATIONS.md)

---

## 📋 Roadmap

- [ ] Comprehensive test coverage (unit, widget, integration)
- [ ] Export trades to CSV/PDF
- [ ] Budget tracking and alerts
- [ ] Category-based organization
- [ ] Charts and statistics
- [ ] Multi-currency support
- [ ] Cloud backup and sync

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- BLoC library maintainers
- Hive database creators
- The open-source community

---

## 📞 Support

If you encounter any issues or have questions:
- Open an issue on GitHub
- Review the troubleshooting section in the specifications

---

**Built with ❤️ using Flutter**