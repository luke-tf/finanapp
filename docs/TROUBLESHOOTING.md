# Troubleshooting Guide

**Common Issues & Solutions**

---

## Table of Contents

1. [Setup & Installation](#setup--installation)
2. [Database Issues](#database-issues)
3. [State Management Issues](#state-management-issues)
4. [UI Issues](#ui-issues)
5. [Build Issues](#build-issues)
6. [Performance Issues](#performance-issues)
7. [Debugging Tips](#debugging-tips)

---

## Setup & Installation

### Flutter SDK Not Found

**Error**: `'flutter' is not recognized as an internal or external command`

**Solution**:
1. Download Flutter SDK from [flutter.dev](https://flutter.dev)
2. Add to PATH:
   - **Windows**: System Properties → Environment Variables → Path
   - **Mac/Linux**: Add to `.bashrc` or `.zshrc`:
     ```bash
     export PATH="$PATH:[PATH_TO_FLUTTER]/flutter/bin"
     ```
3. Verify: `flutter doctor`

### Dependencies Not Installing

**Error**: `pub get failed`

**Solutions**:

1. **Clear pub cache**:
```bash
flutter pub cache repair
flutter pub get
```

2. **Delete pubspec.lock**:
```bash
rm pubspec.lock
flutter pub get
```

3. **Check internet connection** and pub.dev access

### Code Generation Fails

**Error**: `Conflicting outputs were detected`

**Solution**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Error**: `No builders found`

**Solution**:
```bash
flutter pub get
flutter clean
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Database Issues

### MissingPluginException

**Error**: 
```
MissingPluginException(No implementation found for method 
getApplicationDocumentsDirectory on channel plugins.flutter.io/path_provider)
```

**Cause**: Hive initialized before Flutter binding

**Solution**:
```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Add this!
  await DatabaseService().initialize();
  runApp(MyApp());
}
```

### HiveError: Box Not Open

**Error**: `HiveError: Box has already been closed`

**Cause**: Accessing box after it's closed

**Solution**:
1. Check if `DatabaseService().initialize()` was called
2. Don't manually close boxes
3. Verify singleton pattern is working

```dart
// In DatabaseService
if (!_isInitialized || _tradeBox == null || !_tradeBox!.isOpen) {
  throw Exception('Database not initialized');
}
```

### TypeAdapter Not Found

**Error**: `Cannot read, unknown typeId: 0`

**Cause**: Forgot to register adapter or generate code

**Solution**:
```bash
# 1. Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# 2. Verify registration in database_service.dart
if (!Hive.isAdapterRegistered(0)) {
  Hive.registerAdapter(TradeAdapter());
}
```

### Data Not Persisting

**Symptoms**: Trades disappear after app restart

**Checklist**:
1. ✅ Is `initialize()` called in main()?
2. ✅ Is `WidgetsFlutterBinding.ensureInitialized()` called first?
3. ✅ Is build_runner code up to date?
4. ✅ Is correct box name used ('trades')?
5. ✅ Does Trade extend HiveObject?

**Debug**:
```dart
// Check box contents
final box = Hive.box<Trade>('trades');
print('Box length: ${box.length}');
print('Box keys: ${box.keys}');
print('Box path: ${box.path}');
```

### Corrupted Data

**Symptoms**: App crashes on startup, data unreadable

**Solution**: Reset database
```dart
// Delete and recreate
await Hive.deleteBoxFromDisk('trades');
await DatabaseService().initialize();
```

**Prevention**:
- Always use try-catch when accessing database
- Validate data before storing
- Keep backups during development

---

## State Management Issues

### State Not Updating

**Symptoms**: UI doesn't reflect BLoC state changes

**Checklist**:

1. ✅ **Is BlocBuilder wrapping the widget?**
```dart
BlocBuilder<TradeBloc, TradeState>(
  builder: (context, state) {
    // Your UI
  },
)
```

2. ✅ **Are you emitting new state instances?**
```dart
// ❌ Wrong - mutating
state.trades.add(newTrade);
emit(state);

// ✅ Correct - new instance
emit(state.copyWith(trades: [...state.trades, newTrade]));
```

3. ✅ **Is Equatable properly implemented?**
```dart
@override
List<Object?> get props => [trades, filteredTrades, ...];
```

4. ✅ **Is BLoC disposed too early?**
```dart
// Use BlocProvider.value for routes
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (ctx) => BlocProvider.value(
      value: context.read<TradeBloc>(),
      child: EditTradeScreen(),
    ),
  ),
);
```

### Events Not Triggering

**Symptoms**: Dispatching events but nothing happens

**Debug**:
```dart
// Add BLoC observer
class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('Event: $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('Change: $change');
  }
}

// In main()
Bloc.observer = SimpleBlocObserver();
```

**Common Causes**:
- Event handler not registered: `on<YourEvent>(_handleEvent)`
- Exception thrown in handler (check logs)
- Wrong event type dispatched

### Memory Leaks

**Symptoms**: App slows down over time, memory grows

**Causes**:
- Not disposing controllers
- Keeping references to old contexts
- Large lists in state

**Solutions**:
```dart
// 1. Dispose controllers
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// 2. Check context.mounted
Future<void> _asyncOperation() async {
  await Future.delayed(Duration(seconds: 1));
  if (!mounted) return;  // Important!
  setState(() {});
}

// 3. Limit state size
// Don't store huge lists - paginate or filter
```

---

## UI Issues

### Overflow Errors

**Error**: `RenderFlex overflowed by XX pixels`

**Solutions**:

1. **Wrap in SingleChildScrollView**:
```dart
SingleChildScrollView(
  child: Column(
    children: [/* content */],
  ),
)
```

2. **Use Expanded/Flexible**:
```dart
Row(
  children: [
    Expanded(child: Text('Long text...')),
    Icon(Icons.delete),
  ],
)
```

3. **Set maxLines**:
```dart
Text(
  'Long text...',
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

### Keyboard Overlaps Content

**Symptoms**: Bottom sheet content hidden by keyboard

**Solution**:
```dart
Padding(
  padding: EdgeInsets.only(
    bottom: MediaQuery.of(context).viewInsets.bottom,
  ),
  child: YourForm(),
)
```

### Context After Async

**Error**: `Looking up a deactivated widget's ancestor is unsafe`

**Cause**: Using context after async operation when widget is disposed

**Solution**:
```dart
Future<void> _loadData() async {
  await someAsyncOperation();
  
  // Check if widget still mounted
  if (!mounted) return;
  
  // Now safe to use context
  ScaffoldMessenger.of(context).showSnackBar(...);
}
```

### InkWell Not Working

**Symptoms**: Tap not registering

**Cause**: Missing Material ancestor

**Solution**:
```dart
Material(
  child: InkWell(
    onTap: () {},
    child: Container(...),
  ),
)
```

---

## Build Issues

### Gradle Build Failed (Android)

**Error**: Various Gradle errors

**Solutions**:

1. **Clean build**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

2. **Check android/build.gradle**:
```gradle
dependencies {
    classpath 'com.android.tools.build:gradle:7.3.0'
}
```

3. **Check android/gradle/wrapper/gradle-wrapper.properties**:
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip
```

### CocoaPods Issues (iOS)

**Error**: Pod install failed

**Solutions**:
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
flutter clean
flutter run
```

### Hot Reload Not Working

**Symptoms**: Changes not appearing

**Solutions**:
1. Try hot restart (Shift+R) instead of hot reload (R)
2. Stop app and `flutter run` again
3. Check for syntax errors
4. Restart VS Code/Android Studio
5. `flutter clean && flutter pub get`

---

## Performance Issues

### Slow List Scrolling

**Cause**: Not using ListView.builder or missing keys

**Solution**:
```dart
ListView.builder(
  itemCount: trades.length,
  itemBuilder: (context, index) {
    final trade = trades[index];
    return TradeItem(
      key: ValueKey(trade.key),  // Important!
      ...
    );
  },
)
```

### Frequent Rebuilds

**Symptoms**: UI rebuilding too often

**Debug**:
```dart
BlocBuilder<TradeBloc, TradeState>(
  buildWhen: (previous, current) {
    print('Previous: $previous');
    print('Current: $current');
    return previous != current;
  },
  builder: (context, state) { ... },
)
```

**Solutions**:
1. Use `const` constructors
2. Implement Equatable properly
3. Use `buildWhen` to limit rebuilds
4. Extract widgets to separate classes

### Large File Size

**Cause**: Including debug symbols or not optimizing

**Solution**:
```bash
# Build release APK
flutter build apk --release --split-per-abi

# Analyze size
flutter build apk --analyze-size
```

---

## Debugging Tips

### Enable Logging

```dart
// BLoC logging
Bloc.observer = SimpleBlocObserver();

// Database logging
print('Box length: ${box.length}');
print('All trades: ${box.values}');

// State logging
BlocBuilder<TradeBloc, TradeState>(
  builder: (context, state) {
    print('Building with state: ${state.runtimeType}');
    return ...;
  },
)
```

### Flutter DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Features:
- Widget inspector
- Memory profiler
- Performance overlay
- Network monitoring
- Logging

### VS Code Debugging

1. Add breakpoints (click line number)
2. Press F5 to start debugging
3. Use Debug Console for commands

### Print Debugging

```dart
// In BLoC
print('Event: $event');
print('State: ${state.runtimeType}');

// In Services
print('Adding trade: ${trade.title}');
print('Validation result: $valid');

// In Widgets
print('Building ${widget.runtimeType}');
print('Trades count: ${trades.length}');
```

### Common Debug Commands

```dart
// Check BLoC state
print(context.read<TradeBloc>().state);

// Check if widget mounted
print('Mounted: $mounted');

// Check MediaQuery
print('Screen size: ${MediaQuery.of(context).size}');

// Check theme
print('Primary color: ${Theme.of(context).primaryColor}');
```

---

## Getting Help

### Before Asking for Help

1. ✅ Check this troubleshooting guide
2. ✅ Read error message carefully
3. ✅ Search error on Google/Stack Overflow
4. ✅ Check Flutter documentation
5. ✅ Try `flutter clean && flutter pub get`
6. ✅ Check for typos in code

### When Asking for Help

Include:
- Flutter version: `flutter --version`
- Full error message
- Relevant code snippet
- What you've already tried
- Expected vs actual behavior

### Useful Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [BLoC Documentation](https://bloclibrary.dev)
- [Hive Documentation](https://docs.hivedb.dev)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Flutter GitHub Issues](https://github.com/flutter/flutter/issues)

---

## Quick Fixes Checklist

When something goes wrong, try these in order:

```bash
# 1. Hot restart
Press Shift+R in terminal

# 2. Stop and restart
Stop app → flutter run

# 3. Clean build
flutter clean
flutter pub get
flutter run

# 4. Regenerate code
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs

# 5. Reset everything
flutter clean
rm -rf .dart_tool
rm pubspec.lock
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# 6. Nuclear option (careful!)
flutter clean
rm -rf ios/Pods
rm -rf android/.gradle
rm -rf .dart_tool
flutter pub get
flutter run
```

---

**End of Documentation**

For more information, see:
- [README.md](../README.md) - Project overview
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture details
- [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) - Development workflow