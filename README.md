# 💰 Finanapp - Personal Finance Manager

A Flutter application for managing personal finances with transaction tracking, balance monitoring, and visual feedback.

## 📱 Features

### ✅ Core Functionality
- **Add Transactions** - Record income and expenses
- **Edit Transactions** - Modify existing transaction details  
- **Delete Transactions** - Remove unwanted transactions
- **Balance Tracking** - Real-time balance calculation
- **Visual Feedback** - Pig images reflect current financial state

### 🎨 User Experience
- **Responsive Design** - Works on phones and tablets
- **Pull-to-Refresh** - Easy data refreshing
- **Form Validation** - Input validation with helpful error messages
- **Loading States** - Clear feedback during operations
- **Success/Error Messages** - User-friendly notifications

### 🏗️ Technical Features
- **BLoC State Management** - Reactive, testable architecture
- **Local Database** - Hive for offline data persistence
- **Golden Tests** - Visual regression testing
- **Error Handling** - Comprehensive error management
- **Type Safety** - Full Dart null safety

## 🚀 Quick Start

### Prerequisites
- Flutter 3.8.1 or higher
- Dart 3.0.0 or higher

### Installation
```bash
# Clone the repository
git clone <your-repo-url>
cd finanapp

# Install dependencies
flutter pub get

# Generate code (for Hive models)
flutter packages pub run build_runner build

# Run the app
flutter run
```

## 📁 Project Structure

```
lib/
├── blocs/                  # BLoC state management
│   └── transaction/        
│       ├── transaction_bloc.dart
│       ├── transaction_event.dart
│       ├── transaction_state.dart
│       └── transaction_barrel.dart
├── models/                 # Data models
│   ├── transaction.dart
│   └── transaction.g.dart  # Generated Hive adapter
├── screens/               # Application screens
│   └── edit_transaction_screen.dart
├── services/              # Business logic services
│   ├── database_service.dart
│   ├── transaction_service.dart
│   └── error_handler.dart
├── utils/                 # Utilities and constants
│   └── constants.dart
├── widgets/               # Reusable UI components
│   ├── balance/
│   │   ├── balance_card.dart
│   │   ├── balance_display.dart
│   │   └── balance_image.dart
│   └── transaction/
│       ├── new_transaction_form.dart
│       ├── transaction_item.dart
│       └── transaction_list.dart
└── main.dart              # Application entry point

test/
├── golden/                # Golden tests
│   ├── goldens/          # Reference images
│   ├── failures/         # Failed test images
│   └── *.dart           # Golden test files
├── helpers/              # Test utilities
└── flutter_test_config.dart
```

## 🏛️ Architecture

### BLoC Pattern
The application uses the BLoC (Business Logic Component) pattern for state management:

- **Events** - User actions (AddTransaction, DeleteTransaction, etc.)
- **States** - UI states (Loading, Loaded, Error, etc.)
- **BLoC** - Business logic that transforms events into states

### Data Flow
```
UI Widget → Event → BLoC → Service → Database
    ↑                                     ↓
    State ← BLoC ← Service Response ←──────┘
```

### Database
- **Hive** - Fast, lightweight NoSQL database
- **Local Storage** - All data stored locally on device
- **Type Adapters** - Generated adapters for custom objects

## 🧪 Testing Strategy

### Golden Tests
Visual regression tests that capture UI screenshots:
- **Widget Tests** - Individual component testing
- **Screen Tests** - Full screen testing
- **State Tests** - Different application states

### Running Tests
```bash
# Run all tests
flutter test

# Run golden tests
flutter test test/golden/ --update-goldens

# Run specific test file
flutter test test/golden/balance_card_test.dart
```

## 📦 Dependencies

### Main Dependencies
```yaml
dependencies:
  flutter_bloc: ^8.1.6      # State management
  equatable: ^2.0.5         # Value equality
  hive: ^2.2.3             # Database
  hive_flutter: ^1.1.0     # Hive Flutter integration
  path_provider: ^2.1.3    # File system paths
  intl: ^0.20.2            # Internationalization
```

### Dev Dependencies
```yaml
dev_dependencies:
  bloc_test: ^9.1.6        # BLoC testing utilities
  mocktail: ^1.0.0         # Mocking framework
  golden_toolkit: ^0.15.0  # Golden testing
  hive_generator: ^2.0.1   # Code generation
  build_runner: ^2.4.6     # Build system
```

## 🎨 UI Components

### Balance Display
Shows current balance with visual feedback:
- **Positive Balance** - Happy pig image
- **Negative Balance** - Sad pig image
- **Zero Balance** - Neutral pig image

### Transaction Item
Individual transaction display:
- **Color Coding** - Red for expenses, green for income
- **Icons** - Plus/minus indicators
- **Actions** - Edit (long press), Delete button

### Transaction Form
Add/edit transaction interface:
- **Input Validation** - Title and value validation
- **Type Selection** - Expense vs Income toggle
- **Real-time Feedback** - Current balance display

## 🛠️ Development

### Code Generation
```bash
# Generate Hive adapters when models change
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch
```

### Golden Tests Workflow
1. **Create Test** - Write golden test for UI component
2. **Generate Baseline** - Run with `--update-goldens`
3. **Verify Changes** - Run normally to catch regressions
4. **Update When Needed** - Re-run with `--update-goldens` for intended changes

## 🚨 Error Handling

The app includes comprehensive error handling:
- **Validation Errors** - Form input validation
- **Database Errors** - Hive operation failures
- **Network Errors** - Future-proofing for sync features
- **Unknown Errors** - Graceful degradation

## 🎯 Performance

### Optimizations
- **BLoC Pattern** - Efficient state management
- **Local Database** - Fast Hive operations
- **Widget Optimization** - Proper use of keys and const constructors
- **Memory Management** - Proper disposal of resources

## 📱 Platform Support
- **Android** - Full support
- **iOS** - Full support  
- **Web** - Basic support (some limitations with Hive)
- **Desktop** - Basic support

## 🔮 Future Enhancements
- [ ] Data export/import
- [ ] Transaction categories
- [ ] Charts and analytics  
- [ ] Cloud sync
- [ ] Recurring transactions
- [ ] Multi-currency support
- [ ] Budget tracking
- [ ] Receipt photo attachment

## 🤝 Contributing
1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Run tests (`flutter test`)
4. Commit changes (`git commit -m 'Add amazing feature'`)
5. Push to branch (`git push origin feature/amazing-feature`)
6. Open Pull Request