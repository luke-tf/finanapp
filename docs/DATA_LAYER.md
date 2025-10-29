# Data Layer Documentation

**Models & Database**

---

## Overview

The data layer handles persistence and data structures using **Hive** as the local NoSQL database.

## Trade Model

**Location**: `lib/models/trade.dart`

### Structure

```dart
@HiveType(typeId: 0)
class Trade extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late double value;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  late bool isExpense;

  // Constructor
  Trade({
    this.title = '',
    this.value = 0.0,
    DateTime? date,
    this.isExpense = true,
  }) : date = date ?? DateTime.now();
}
```

### Key Annotations

**@HiveType(typeId: 0)**
- Registers class with Hive
- `typeId` must be unique across all models
- Never change typeId after deployment

**@HiveField(index)**
- Maps property to database field
- Index must be unique within the class
- Order doesn't matter, only the number
- Never reuse indices

**extends HiveObject**
- Provides automatic `key` property (int?)
- Key is auto-assigned by Hive on save
- Used for updates and deletes

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| title | String | Yes | '' | Trade description |
| value | double | Yes | 0.0 | Trade amount |
| date | DateTime | Yes | now() | When trade occurred |
| isExpense | bool | Yes | true | true=expense, false=income |
| key | int? | No | null | Unique ID (auto-assigned) |

### Validation

Model does **not** validate. Validation happens in:
- TradeService (business rules)
- UI forms (user input)

### Code Generation

The model requires code generation for the TypeAdapter:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Generates: `lib/models/trade.g.dart`

## DatabaseService

**Location**: `lib/services/database_service.dart`

### Purpose

Low-level Hive operations. No business logic.

### Initialization

```dart
// In main.dart
await DatabaseService().initialize();
```

**What it does**:
1. Calls `Hive.initFlutter()` with platform-specific path
2. Registers `TradeAdapter` if not already registered
3. Opens the 'trades' box
4. Sets initialization flag

**Platform Handling**:
- **Mobile/Desktop**: Uses `path_provider` for app documents directory
- **Web**: Uses IndexedDB (path is null)

### API Reference

#### getAllTrades()

```dart
Future<List<Trade>> getAllTrades()
```

**Returns**: All trades from database  
**Filters**: Removes trades with empty titles or negative values  
**Throws**: Never (returns empty list on error)

**Example**:
```dart
final trades = await DatabaseService().getAllTrades();
```

#### addTrade()

```dart
Future<void> addTrade(Trade trade)
```

**Parameters**:
- `trade`: Trade object to persist

**Validates**:
- Title not empty
- Value >= 0

**Throws**:
- Exception if validation fails
- Exception if Hive operation fails

**Example**:
```dart
final trade = Trade(
  title: 'Coffee',
  value: 5.50,
  isExpense: true,
);
await DatabaseService().addTrade(trade);
```

#### updateTrade()

```dart
Future<void> updateTrade(Trade trade)
```

**Parameters**:
- `trade`: Trade object with updated values

**Requirements**:
- Trade must have a non-null `key`
- Title not empty

**How it works**:
Uses `box.put(trade.key, trade)` to update existing entry

**Throws**:
- Exception if key is null
- Exception if validation fails

**Example**:
```dart
trade.title = 'Updated Title';
trade.value = 10.0;
await DatabaseService().updateTrade(trade);
```

#### deleteTrade()

```dart
Future<void> deleteTrade(int key)
```

**Parameters**:
- `key`: The trade's unique key

**Validates**:
- Key >= 0

**Throws**:
- Exception if key invalid

**Example**:
```dart
await DatabaseService().deleteTrade(tradeKey);
```

#### clearAllData()

```dart
Future<void> clearAllData()
```

**Warning**: Deletes ALL trades. No undo.

**Use case**: Debug, reset, testing

**Example**:
```dart
await DatabaseService().clearAllData();
```

### Singleton Pattern

```dart
static final DatabaseService _instance = DatabaseService._internal();

factory DatabaseService() {
  return _instance;
}

DatabaseService._internal();
```

**Why**: Ensures only one database connection exists

**Usage**: Always use `DatabaseService()` (not `new`)

### Error Handling

**Philosophy**: Let errors bubble up to service layer

```dart
try {
  await _databaseService.addTrade(trade);
} catch (e) {
  // TradeService converts to AppError
  throw ErrorHandler.handleException(e);
}
```

## Hive Box

### Box Properties

**Name**: `'trades'`  
**Type**: `Box<Trade>`  
**Location**: Application documents directory

### Box Methods (via Hive)

```dart
final box = Hive.box<Trade>('trades');

// Read
box.values.toList()           // All trades
box.get(key)                  // Single trade
box.length                    // Count
box.keys                      // All keys

// Write
box.add(trade)                // Returns key
box.put(key, trade)           // Update
box.delete(key)               // Delete
box.clear()                   // Delete all

// Query
box.values.where((t) => ...)  // Filter
```

### Box Access

❌ **Never** access box directly from widgets  
✅ **Always** use DatabaseService

## Data Migration

### Adding New Fields

1. **Add to model**:
```dart
@HiveField(4)
late String? category;
```

2. **Update constructor**:
```dart
Trade({
  ...
  this.category,
})
```

3. **Regenerate**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Migration**: Hive automatically handles null for existing trades

### Removing Fields

**Don't** remove `@HiveField` annotations. Set to null instead:

```dart
@HiveField(4)
late String? deprecatedField;  // Keep but don't use
```

### Changing TypeId

❌ **Never** change typeId of deployed models  
✅ Create new model with new typeId if structure changes drastically

## Best Practices

### ✅ Do

- Always extend `HiveObject` for models
- Use late initialization for Hive fields
- Generate code after model changes
- Validate in services, not models
- Handle null keys gracefully
- Log database operations
- Use unique, meaningful field indices

### ❌ Don't

- Access Hive box directly from UI
- Change typeId after deployment
- Reuse HiveField indices
- Store logic in models
- Forget to call initialize()
- Catch exceptions silently

## Testing

### Unit Tests

```dart
test('Trade stores and retrieves correctly', () async {
  await Hive.initFlutter(memoryFileSystem.path);
  Hive.registerAdapter(TradeAdapter());
  final box = await Hive.openBox<Trade>('test_trades');

  final trade = Trade(
    title: 'Test',
    value: 10.0,
    isExpense: true,
  );

  await box.add(trade);
  
  expect(box.length, 1);
  expect(box.values.first.title, 'Test');
  
  await box.close();
});
```

### Integration Tests

```dart
testWidgets('Database persists across app restarts', (tester) async {
  // 1. Add trade
  await DatabaseService().initialize();
  await DatabaseService().addTrade(testTrade);
  
  // 2. Close box
  await Hive.close();
  
  // 3. Reinitialize
  await DatabaseService().initialize();
  
  // 4. Verify trade exists
  final trades = await DatabaseService().getAllTrades();
  expect(trades.length, 1);
});
```

## Troubleshooting

### "MissingPluginException"

**Cause**: Hive initialized before Flutter binding

**Solution**:
```dart
WidgetsFlutterBinding.ensureInitialized();
await DatabaseService().initialize();
```

### "TypeAdapter not found"

**Cause**: Forgot to register adapter or generate code

**Solution**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Data Not Persisting

**Checklist**:
1. Is initialize() called?
2. Is trade being added to correct box?
3. Is app closing properly? (not force-killed during write)
4. Check path_provider permissions

### Corrupted Data

**Recovery**:
```dart
// Delete and recreate box
await Hive.deleteBoxFromDisk('trades');
await DatabaseService().initialize();
```

---

**Next**: [SERVICES.md](SERVICES.md) - Business logic layer