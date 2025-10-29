# Development Guide

**Workflow & Code Conventions**

---

## Getting Started

### Initial Setup

1. **Clone repository**
```bash
git clone https://github.com/your-username/finanapp.git
cd finanapp
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate code**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Run app**
```bash
flutter run
```

---

## Code Conventions

### File Naming

**Pattern**: `lowercase_with_underscores.dart`

```
✅ home_screen.dart
✅ trade_item.dart
✅ balance_display.dart

❌ HomeScreen.dart
❌ TradeItem.dart
❌ balanceDisplay.dart
```

**Suffixes**:
- Screens: `*_screen.dart`
- Widgets: `*_widget.dart` or descriptive name
- Services: `*_service.dart`
- BLoC: `*_bloc.dart`, `*_event.dart`, `*_state.dart`
- Models: `model_name.dart`

### Class Naming

**Pattern**: `PascalCase`

```dart
✅ class HomeScreen
✅ class TradeItem
✅ class DatabaseService

❌ class homeScreen
❌ class tradeItem
❌ class database_service
```

### Variable & Function Naming

**Pattern**: `camelCase`

```dart
✅ final currentBalance = 100.0;
✅ void calculateTotal() {}

❌ final CurrentBalance = 100.0;
❌ void CalculateTotal() {}
```

**Private members**: `_leadingUnderscore`

```dart
✅ void _privateMethod() {}
✅ final _privateVariable = 'secret';
```

**Constants**:
```dart
// In classes
static const String appName = 'Finanapp';

// Enums
enum TradeType { EXPENSE, INCOME }
```

### Import Organization

**Order**:
1. Dart SDK imports
2. Flutter SDK imports
3. Package imports
4. Project imports (absolute paths)

```dart
// 1. Dart imports
import 'dart:async';
import 'dart:math';

// 2. Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

// 4. Project imports
import 'package:finanapp/models/trade.dart';
import 'package:finanapp/services/trade_service.dart';
import 'package:finanapp/blocs/trade/trade_barrel.dart';
```

### File Structure

```dart
// 1. Imports
import 'package:flutter/material.dart';

// 2. Main class
class MyWidget extends StatelessWidget {
  // 3. Constants (if any)
  static const double padding = 16.0;
  
  // 4. Final fields
  final String title;
  final VoidCallback onTap;
  
  // 5. Constructor
  const MyWidget({
    super.key,
    required this.title,
    required this.onTap,
  });
  
  // 6. Lifecycle methods (StatefulWidget)
  @override
  void initState() {
    super.initState();
  }
  
  // 7. Public methods
  void publicMethod() {
    // Implementation
  }
  
  // 8. Private methods
  void _privateMethod() {
    // Implementation
  }
  
  // 9. Build method (LAST)
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// 10. Helper widgets/classes (if small enough)
class _HelperWidget extends StatelessWidget {
  // ...
}
```

---

## Coding Standards

### Widget Best Practices

#### Use const constructors

```dart
✅ const Text('Hello')
✅ const SizedBox(height: 16)
✅ const Icon(Icons.add)

❌ Text('Hello')
❌ SizedBox(height: 16)
```

#### Key parameter first

```dart
✅ const MyWidget({
  super.key,
  required this.title,
})

❌ const MyWidget({
  required this.title,
  super.key,
})
```

#### Extract complex widgets

```dart
// ❌ Bad - huge build method
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Title'),
      actions: [
        IconButton(icon: Icon(Icons.settings), onPressed: () {}),
        IconButton(icon: Icon(Icons.logout), onPressed: () {}),
      ],
    ),
    body: Column(
      children: [
        Container(/* 50 lines */),
        Container(/* 50 lines */),
        Container(/* 50 lines */),
      ],
    ),
  );
}

// ✅ Good - extracted widgets
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: _buildAppBar(),
    body: _buildBody(),
  );
}

AppBar _buildAppBar() {
  return AppBar(
    title: Text('Title'),
    actions: [
      _buildSettingsButton(),
      _buildLogoutButton(),
    ],
  );
}
```

### State Management

#### BLoC access

```dart
// ✅ Reading (one-time access)
context.read<TradeBloc>().add(const LoadTrades());

// ✅ Watching (rebuilds on change)
final state = context.watch<TradeBloc>().state;

// ✅ Selecting specific data
final balance = context.select(
  (TradeBloc bloc) => bloc.state.currentBalance,
);

// ❌ Don't use Provider.of
Provider.of<TradeBloc>(context).add(...);
```

#### Check context.mounted

```dart
// ✅ Before async operations
Future<void> _loadData() async {
  await Future.delayed(Duration(seconds: 1));
  
  if (!mounted) return;  // Check before using context
  
  ScaffoldMessenger.of(context).showSnackBar(...);
}

// ❌ Using context after async without check
Future<void> _loadData() async {
  await Future.delayed(Duration(seconds: 1));
  ScaffoldMessenger.of(context).showSnackBar(...);  // May crash!
}
```

### Null Safety

#### Use late sparingly

```dart
// ✅ Good - guaranteed initialization
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();  // Guaranteed to run
  }
}

// ❌ Dangerous - might not be initialized
class MyClass {
  late String value;
  
  void someMethod() {
    print(value);  // Might crash if not set
  }
}
```

#### Prefer ?? and ?.

```dart
// ✅ Good
final name = user?.name ?? 'Guest';
final length = text?.length ?? 0;

// ❌ Verbose
String name;
if (user != null && user.name != null) {
  name = user.name!;
} else {
  name = 'Guest';
}
```

#### Avoid ! operator

```dart
// ❌ Dangerous - can crash
final name = user!.name!;

// ✅ Better - safe
final name = user?.name ?? 'Unknown';

// ✅ Only when absolutely certain
final key = trade.key!;  // Trade from database always has key
```

---

## Development Workflow

### Adding a New Feature

#### 1. Create feature branch

```bash
git checkout -b feature/category-filtering
```

#### 2. Update data model (if needed)

```dart
// lib/models/trade.dart
@HiveType(typeId: 0)
class Trade extends HiveObject {
  // Existing fields...
  
  @HiveField(4)
  late String? category;  // New field
}
```

Regenerate:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 3. Update database service

```dart
// lib/services/database_service.dart
// Usually no changes needed - Hive handles new fields automatically
```

#### 4. Update trade service

```dart
// lib/services/trade_service.dart
List<Trade> getTradesByCategory(
  List<Trade> trades,
  String category,
) {
  return trades.where((t) => t.category == category).toList();
}
```

#### 5. Add BLoC events/states

```dart
// lib/blocs/trade/trade_event.dart
class FilterByCategory extends TradeEvent {
  final String? category;
  const FilterByCategory({required this.category});
  
  @override
  List<Object?> get props => [category];
}

// lib/blocs/trade/trade_state.dart
// Add to TradeLoaded:
final String? filterCategory;

// lib/blocs/trade/trade_bloc.dart
on<FilterByCategory>(_onFilterByCategory);

void _onFilterByCategory(
  FilterByCategory event,
  Emitter<TradeState> emit,
) {
  if (state is! TradeLoaded) return;
  
  final currentState = state as TradeLoaded;
  final filtered = _applyFilters(
    currentState.trades,
    category: event.category,
  );
  
  emit(currentState.copyWith(
    filteredTrades: filtered,
    filterCategory: event.category,
  ));
}
```

#### 6. Create UI widgets

```dart
// lib/widgets/trade/category_filter_widget.dart
class CategoryFilterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      items: ['Food', 'Transport', 'Shopping']
        .map((cat) => DropdownMenuItem(
          value: cat,
          child: Text(cat),
        ))
        .toList(),
      onChanged: (category) {
        context.read<TradeBloc>().add(
          FilterByCategory(category: category),
        );
      },
    );
  }
}
```

#### 7. Update screens

```dart
// lib/screens/home_screen.dart
// Add CategoryFilterWidget to UI
```

#### 8. Test manually

- Run on different screen sizes
- Test with empty data
- Test with many trades
- Test error cases
- Test state persistence

#### 9. Commit & push

```bash
git add .
git commit -m "feat: Add category filtering for trades"
git push origin feature/category-filtering
```

### Modifying Existing Code

#### When changing models

1. Add new @HiveField with NEW index
2. Don't remove old fields (set to deprecated if needed)
3. Run build_runner
4. Update constructors
5. Test migration from old data

#### When changing BLoC

1. Add new events/states
2. Update event handlers
3. Update copyWith in states
4. Update UI to handle new states
5. Test state transitions

### Code Generation

**When to run**:
- After modifying Hive models
- After adding/removing @HiveField
- After changing typeId
- First time setup

**Commands**:

```bash
# One-time generation
flutter pub run build_runner build

# Delete conflicting files
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on changes)
flutter pub run build_runner watch

# Clean and regenerate
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Git Workflow

### Branch Naming

```
feature/feature-name      # New features
bugfix/bug-description    # Bug fixes
refactor/what-refactored  # Code improvements
docs/what-documented      # Documentation
```

### Commit Messages

**Format**: `type: description`

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `docs`: Documentation
- `style`: Code formatting
- `test`: Adding tests
- `chore`: Maintenance

**Examples**:
```bash
git commit -m "feat: Add category filtering"
git commit -m "fix: Prevent duplicate trades"
git commit -m "refactor: Extract balance calculation to service"
git commit -m "docs: Update API documentation"
```

### Pull Request Process

1. Create feature branch
2. Make changes
3. Test thoroughly
4. Commit with clear messages
5. Push to origin
6. Create PR with description
7. Wait for review
8. Address feedback
9. Merge after approval

---

## Debugging

### Enable BLoC Logging

```dart
// main.dart
void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp());
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }
  
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}
```

### Inspect Database

```dart
// Temporary debug code
final box = Hive.box<Trade>('trades');
print('Total trades: ${box.length}');
print('All keys: ${box.keys}');
print('All values: ${box.values}');
```

### Common Debug Points

```dart
// In BLoC
print('Event received: $event');
print('Current state: $state');
print('New state: $newState');

// In Services
print('Adding trade: ${trade.title}');
print('Validation result: $isValid');

// In UI
print('Building with state: ${state.runtimeType}');
print('Trades count: ${trades.length}');
```

---

## Performance Tips

### Use const constructors

```dart
// 10x faster builds
const Text('Hello')
const Icon(Icons.add)
const Padding(padding: EdgeInsets.all(8))
```

### Avoid anonymous functions in build

```dart
// ❌ Bad - creates new function every build
ElevatedButton(
  onPressed: () {
    context.read<TradeBloc>().add(LoadTrades());
  },
  child: Text('Load'),
)

// ✅ Good - reuses same function
ElevatedButton(
  onPressed: _onLoadPressed,
  child: Text('Load'),
)

void _onLoadPressed() {
  context.read<TradeBloc>().add(LoadTrades());
}
```

### Use keys for list items

```dart
// ✅ Optimal performance
ListView.builder(
  itemBuilder: (context, index) {
    final trade = trades[index];
    return TradeItem(
      key: ValueKey(trade.key),  // Important!
      ...
    );
  },
)
```

---

**Next**: [TESTING_GUIDE.md](TESTING_GUIDE.md) - Testing strategies