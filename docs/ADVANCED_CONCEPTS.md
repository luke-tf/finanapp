### Code Review Guidelines

#### 📋 Comprehensive Review Checklist

```markdown
# Code Review Checklist for Finanapp

## Architecture & Design
- [ ] Changes follow BLoC pattern correctly
- [ ] Events are properly named (verb-noun pattern)
- [ ] States are immutable and use Equatable
- [ ] Business logic is in services, not BLoC
- [ ] Error handling follows established patterns
- [ ] No hardcoded strings (use AppConstants)

## Performance
- [ ] No expensive operations in build() methods
- [ ] Proper use of const constructors
- [ ] ListView.builder used for lists
- [ ] Keys provided for dynamic lists
- [ ] No memory leaks (streams/subscriptions closed)
- [ ] buildWhen used appropriately in BlocBuilder

## Testing
- [ ] New features have unit tests
- [ ] BLoC tests cover all event-state combinations
- [ ] Golden tests updated if UI changed
- [ ] Edge cases are tested
- [ ] Tests are readable and maintainable

## Security
- [ ] Input validation in place
- [ ] No sensitive data in logs
- [ ] Proper error messages (no stack traces to users)
- [ ] Database operations are safe

## Code Quality
- [ ] Code follows Dart/Flutter style guide
- [ ] Public APIs have documentation
- [ ] No commented-out code
- [ ] No debugging print statements
- [ ] Imports are organized and minimal

## UI/UX
- [ ] Accessibility labels provided
- [ ] Loading states implemented
- [ ] Error states handled gracefully
- [ ] Responsive design considerations
- [ ] Consistent with design system

## Database
- [ ] Migrations handled properly (if schema changes)
- [ ] Data validation before storage
- [ ] Proper error handling for DB operations
- [ ] No data corruption risks

## Specific Questions for Reviewer
- Does this change maintain backward compatibility?
- Are there any potential side effects?
- Is the solution scalable for future features?
- Are there any security concerns?
```

#### 🎯 Automated Code Quality Gates

```dart
// pre_commit_hooks.dart - Custom pre-commit validation
class PreCommitValidator {
  static Future<bool> runAllChecks() async {
    print('🔍 Running pre-commit validation...\n');
    
    final checks = [
      _checkFormatterting(),
      _checkLinting(),
      _checkTests(),
      _checkCoverage(),
      _checkGoldenTests(),
      _checkTodoComments(),
      _checkHardcodedStrings(),
    ];
    
    final results = await Future.wait(checks);
    final allPassed = results.every((result) => result);
    
    if (allPassed) {
      print('✅ All pre-commit checks passed!');
    } else {
      print('❌ Some checks failed. Please fix before committing.');
    }
    
    return allPassed;
  }
  
  static Future<bool> _checkFormatterting() async {
    print('📝 Checking code formatting...');
    
    final result = await Process.run('dart', ['format', '--output=none', '--set-exit-if-changed', '.']);
    
    if (result.exitCode == 0) {
      print('   ✅ Code formatting is correct');
      return true;
    } else {
      print('   ❌ Code formatting issues found. Run: dart format .');
      return false;
    }
  }
  
  static Future<bool> _checkLinting() async {
    print('🔍 Running linter...');
    
    final result = await Process.run('flutter', ['analyze']);
    
    if (result.exitCode == 0) {
      print('   ✅ No linting issues found');
      return true;
    } else {
      print('   ❌ Linting issues found:');
      print(result.stdout);
      return false;
    }
  }
  
  static Future<bool> _checkTests() async {
    print('🧪 Running unit tests...');
    
    final result = await Process.run('flutter', ['test', '--no-coverage']);
    
    if (result.exitCode == 0) {
      print('   ✅ All tests passed');
      return true;
    } else {
      print('   ❌ Some tests failed:');
      print(result.stdout);
      return false;
    }
  }
  
  static Future<bool> _checkCoverage() async {
    print('📊 Checking test coverage...');
    
    final result = await Process.run('flutter', ['test', '--coverage']);
    
    if (result.exitCode != 0) {
      print('   ❌ Failed to generate coverage');
      return false;
    }
    
    // Parse coverage percentage
    final lcovResult = await Process.run('lcov', ['--summary', 'coverage/lcov.info']);
    final output = lcovResult.stdout.toString();
    
    final coverageMatch = RegExp(r'lines\.+: (\d+\.\d+)%').firstMatch(output);
    
    if (coverageMatch != null) {
      final coverage = double.parse(coverageMatch.group(1)!);
      
      if (coverage >= 80.0) {
        print('   ✅ Coverage: $coverage% (threshold: 80%)');
        return true;
      } else {
        print('   ❌ Coverage: $coverage% is below threshold of 80%');
        return false;
      }
    }
    
    print('   ⚠️  Could not parse coverage information');
    return false;
  }
  
  static Future<bool> _checkGoldenTests() async {
    print('🖼️  Checking golden tests...');
    
    final result = await Process.run('flutter', ['test', 'test/golden/']);
    
    if (result.exitCode == 0) {
      print('   ✅ All golden tests passed');
      return true;
    } else {
      print('   ❌ Golden tests failed. Run with --update-goldens if UI changes are intentional');
      return false;
    }
  }
  
  static Future<bool> _checkTodoComments() async {
    print('📝 Checking for TODO comments...');
    
    final dartFiles = await _findDartFiles();
    final todos = <String>[];
    
    for (final file in dartFiles) {
      final content = await File(file).readAsString();
      final lines = content.split('\n');
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.contains('TODO') || line.contains('FIXME') || line.contains('HACK')) {
          todos.add('$file:${i + 1}: ${line.trim()}');
        }
      }
    }
    
    if (todos.isEmpty) {
      print('   ✅ No TODO comments found');
      return true;
    } else {
      print('   ⚠️  Found ${todos.length} TODO comments:');
      todos.take(5).forEach((todo) => print('     $todo'));
      if (todos.length > 5) {
        print('     ... and ${todos.length - 5} more');
      }
      print('   Consider addressing these before committing');
      return true; // TODOs are warnings, not blockers
    }
  }
  
  static Future<bool> _checkHardcodedStrings() async {
    print('🔤 Checking for hardcoded strings...');
    
    final dartFiles = await _findDartFiles();
    final hardcodedStrings = <String>[];
    
    // Regex to find string literals that might be user-facing
    final stringRegex = RegExp(r"'([^']{10,})'|\"([^\"]{10,})\"");
    
    for (final file in dartFiles) {
      // Skip test files and generated files
      if (file.contains('/test/') || file.endsWith('.g.dart')) continue;
      
      final content = await File(file).readAsString();
      final lines = content.split('\n');
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        
        // Skip comments and imports
        if (line.trim().startsWith('//') || line.trim().startsWith('import')) continue;
        
        final matches = stringRegex.allMatches(line);
        for (final match in matches) {
          final stringValue = match.group(1) ?? match.group(2) ?? '';
          
          // Skip technical strings (URLs, paths, etc.)
          if (_isProbablyUserFacingString(stringValue)) {
            hardcodedStrings.add('$file:${i + 1}: "$stringValue"');
          }
        }
      }
    }
    
    if (hardcodedStrings.isEmpty) {
      print('   ✅ No hardcoded user-facing strings found');
      return true;
    } else {
      print('   ⚠️  Found ${hardcodedStrings.length} potential hardcoded strings:');
      hardcodedStrings.take(3).forEach((str) => print('     $str'));
      if (hardcodedStrings.length > 3) {
        print('     ... and ${hardcodedStrings.length - 3} more');
      }
      print('   Consider moving these to AppConstants');
      return true; // Warning, not blocker
    }
  }
  
  static Future<List<String>> _findDartFiles() async {
    final result = await Process.run('find', ['.', '-name', '*.dart', '-not', '-path', './.*']);
    return result.stdout.toString().trim().split('\n').where((line) => line.isNotEmpty).toList();
  }
  
  static bool _isProbablyUserFacingString(String str) {
    // Skip technical strings
    if (str.contains('/') || str.contains('http') || str.contains('.')) return false;
    if (str.contains('_') && str.length > 20) return false; // Probably a key
    
    // Check if it contains common user-facing words (Portuguese)
    final userFacingWords = [
      'erro', 'sucesso', 'carregando', 'salvar', 'cancelar', 'excluir',
      'adicionar', 'editar', 'confirmar', 'título', 'valor', 'transação',
      'receita', 'despesa', 'saldo', 'atual'
    ];
    
    final lowerStr = str.toLowerCase();
    return userFacingWords.any((word) => lowerStr.contains(word));
  }
}

// Usage in git hook or IDE
void main() async {
  final success = await PreCommitValidator.runAllChecks();
  exit(success ? 0 : 1);
}
```

### Monitoring and Analytics

#### 📈 Production Monitoring Setup

```dart
// production_monitor.dart
class ProductionMonitor {
  static late FirebaseCrashlytics _crashlytics;
  static late FirebaseAnalytics _analytics;
  static late PerformanceMonitoring _performance;
  
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    _crashlytics = FirebaseCrashlytics.instance;
    _analytics = FirebaseAnalytics.instance;
    _performance = PerformanceMonitoring();
    
    // Set up crash reporting
    FlutterError.onError = _crashlytics.recordFlutterError;
    
    // Set up performance monitoring
    await _performance.initialize();
    
    print('📊 Production monitoring initialized');
  }
  
  // Crash and Error Reporting
  static void reportError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    _crashlytics.recordError(
      error,
      stackTrace,
      reason: context,
      information: additionalData?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
    );
  }
  
  static void setUserInfo({
    required String userId,
    String? email,
    Map<String, String>? customKeys,
  }) {
    _crashlytics.setUserIdentifier(userId);
    
    if (email != null) {
      _crashlytics.setCustomKey('user_email', email);
    }
    
    customKeys?.forEach((key, value) {
      _crashlytics.setCustomKey(key, value);
    });
  }
  
  // Analytics Events
  static void logTransactionAdded({
    required double value,
    required bool isExpense,
    String? category,
  }) {
    _analytics.logEvent(
      name: 'transaction_added',
      parameters: {
        'value': value,
        'is_expense': isExpense,
        'category': category ?? 'uncategorized',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  static void logTransactionEdited({
    required double oldValue,
    required double newValue,
    required bool isExpense,
  }) {
    _analytics.logEvent(
      name: 'transaction_edited',
      parameters: {
        'old_value': oldValue,
        'new_value': newValue,
        'is_expense': isExpense,
        'value_change': newValue - oldValue,
      },
    );
  }
  
  static void logTransactionDeleted({
    required double value,
    required bool isExpense,
  }) {
    _analytics.logEvent(
      name: 'transaction_deleted',
      parameters: {
        'value': value,
        'is_expense': isExpense,
      },
    );
  }
  
  static void logScreenView(String screenName) {
    _analytics.logScreenView(screenName: screenName);
  }
  
  static void logAppOpen() {
    _analytics.logAppOpen();
  }
  
  // Performance Monitoring
  static Future<T> trackOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final trace = _performance.newTrace(operationName);
    trace.start();
    
    try {
      final result = await operation();
      trace.setMetric('success', 1);
      return result;
    } catch (e) {
      trace.setMetric('error', 1);
      trace.putAttribute('error_type', e.runtimeType.toString());
      rethrow;
    } finally {
      trace.stop();
    }
  }
  
  // User Journey Tracking
  static void startUserJourney(String journeyName) {
    _analytics.logEvent(
      name: 'journey_start',
      parameters: {
        'journey_name': journeyName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  static void completeUserJourney(
    String journeyName, {
    Duration? duration,
    bool success = true,
  }) {
    _analytics.logEvent(
      name: 'journey_complete',
      parameters: {
        'journey_name': journeyName,
        'success': success,
        'duration_ms': duration?.inMilliseconds,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
}

class PerformanceMonitoring {
  final Map<String, Trace> _traces = {};
  
  Future<void> initialize() async {
    // Set up performance monitoring
  }
  
  Trace newTrace(String name) {
    final trace = Trace(name);
    _traces[name] = trace;
    return trace;
  }
  
  void clearTrace(String name) {
    _traces.remove(name);
  }
}

class Trace {
  final String name;
  final Stopwatch _stopwatch = Stopwatch();
  final Map<String, int> _metrics = {};
  final Map<String, String> _attributes = {};
  
  Trace(this.name);
  
  void start() {
    _stopwatch.start();
    debugPrint('🏁 Started trace: $name');
  }
  
  void stop() {
    _stopwatch.stop();
    debugPrint('🏁 Stopped trace: $name (${_stopwatch.elapsedMilliseconds}ms)');
  }
  
  void setMetric(String metricName, int value) {
    _metrics[metricName] = value;
  }
  
  void putAttribute(String attributeName, String value) {
    _attributes[attributeName] = value;
  }
  
  int get elapsedMilliseconds => _stopwatch.elapsedMilliseconds;
}
```

## 🌍 Real-World Scenarios

### Handling Production Issues

#### 🚨 Emergency Response Playbook

```dart
// emergency_response.dart
class EmergencyResponseKit {
  // 1. Critical Error Detection
  static void setupCriticalErrorDetection() {
    // Monitor for critical errors that affect core functionality
    BlocObserver.instance = CriticalErrorBlocObserver();
  }
  
  // 2. Automatic Error Recovery
  static Widget buildWithErrorRecovery({
    required Widget child,
    required String componentName,
  }) {
    return ErrorBoundary(
      componentName: componentName,
      child: child,
      onError: (error, stackTrace) {
        // Log error
        ProductionMonitor.reportError(
          error,
          stackTrace,
          context: 'ErrorBoundary: $componentName',
        );
        
        // Attempt automatic recovery
        _attemptRecovery(componentName, error);
      },
    );
  }
  
  static void _attemptRecovery(String componentName, dynamic error) {
    switch (componentName) {
      case 'TransactionList':
        // Clear potentially corrupted data and reload
        _clearTransactionCache();
        break;
      case 'DatabaseService':
        // Reinitialize database connection
        _reinitializeDatabase();
        break;
      default:
        // Generic recovery - restart the component
        _restartComponent(componentName);
    }
  }
  
  // 3. Feature Flags for Emergency Rollback
  static Future<bool> isFeatureEnabled(String featureName) async {
    // In production, this would check remote config
    final remoteConfig = await RemoteConfig.instance;
    return remoteConfig.getBool(featureName);
  }
  
  static Widget featureFlag({
    required String featureName,
    required Widget enabledChild,
    required Widget disabledChild,
  }) {
    return FutureBuilder<bool>(
      future: isFeatureEnabled(featureName),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return enabledChild;
        } else {
          return disabledChild;
        }
      },
    );
  }
  
  // 4. Gradual Rollout System
  static bool shouldShowNewFeature(String userId) {
    // Use user ID to determine rollout percentage
    final hash = userId.hashCode.abs();
    final percentage = hash % 100;
    
    // Get rollout percentage from remote config (default 10%)
    const rolloutPercentage = 10;
    
    return percentage < rolloutPercentage;
  }
  
  static void _clearTransactionCache() {
    // Implementation to clear cache
    debugPrint('🔄 Emergency: Clearing transaction cache');
  }
  
  static void _reinitializeDatabase() {
    // Implementation to reinitialize database
    debugPrint('🔄 Emergency: Reinitializing database');
  }
  
  static void _restartComponent(String componentName) {
    // Implementation to restart component
    debugPrint('🔄 Emergency: Restarting $componentName');
  }
}

class CriticalErrorBlocObserver extends BlocObserver {
  static const criticalErrors = [
    'DatabaseException',
    'StateError',
    'ArgumentError',
  ];
  
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    
    final errorType = error.runtimeType.toString();
    
    if (criticalErrors.contains(errorType)) {
      // This is a critical error
      _handleCriticalError(bloc, error, stackTrace);
    }
  }
  
  void _handleCriticalError(BlocBase bloc, Object error, StackTrace stackTrace) {
    // 1. Log immediately
    ProductionMonitor.reportError(
      error,
      stackTrace,
      context: 'CriticalError in ${bloc.runtimeType}',
      additionalData: {
        'bloc_type': bloc.runtimeType.toString(),
        'bloc_state': bloc.state.toString(),
        'error_type': error.runtimeType.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    
    // 2. Notify development team
    _notifyDevelopmentTeam(bloc, error);
    
    // 3. Attempt automatic recovery
    _attemptAutomaticRecovery(bloc, error);
  }
  
  void _notifyDevelopmentTeam(BlocBase bloc, Object error) {
    // In production, this might send alerts to Slack, PagerDuty, etc.
    debugPrint('🚨 CRITICAL ERROR ALERT: ${error.runtimeType} in ${bloc.runtimeType}');
  }
  
  void _attemptAutomaticRecovery(BlocBase bloc, Object error) {
    // Attempt to reset BLoC to a safe state
    if (bloc is TransactionBloc) {
      // Force reload of transactions
      bloc.add(const LoadTransactions());
    }
  }
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final String componentName;
  final void Function(Object error, StackTrace stackTrace)? onError;
  
  const ErrorBoundary({
    super.key,
    required this.child,
    required this.componentName,
    this.onError,
  });
  
  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;
  
  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorWidget();
    }
    
    return widget.child;
  }
  
  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re working to fix this issue.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _retry,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
  
  void _retry() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }
  
  @override
  void initState() {
    super.initState();
    
    // Set up error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        setState(() {
          _error = details.exception;
          _stackTrace = details.stack;
        });
        
        widget.onError?.call(details.exception, details.stack ?? StackTrace.empty);
      }
    };
  }
}
```

### Performance Optimization Case Studies

#### 🚀 Real Performance Issues and Solutions

```dart
// performance_case_studies.dart

// Case Study 1: Expensive Widget Rebuilds
class PerformanceCaseStudy1 {
  // PROBLEM: Transaction list rebuilding all items when one item changes
  static Widget problematicTransactionList(List<Transaction> transactions) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoaded) {
          // ❌ This rebuilds ALL items when ANY transaction changes
          return ListView.builder(
            itemCount: state.transactions.length,
            itemBuilder: (context, index) {
              return ExpensiveTransactionItem(
                transaction: state.transactions[index],
                // No key provided - Flutter can't optimize
              );
            },
          );
        }
        return LoadingWidget();
      },
    );
  }
  
  // SOLUTION: Proper keys and optimized rebuilds
  static Widget optimizedTransactionList(List<Transaction> transactions) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      buildWhen: (previous, current) {
        // Only rebuild when transactions actually change
        if (previous is TransactionLoaded && current is TransactionLoaded) {
          return !listEquals(previous.transactions, current.transactions);
        }
        return true;
      },
      builder: (context, state) {
        if (state is TransactionLoaded) {
          return ListView.builder(
            itemCount: state.transactions.length,
            itemBuilder: (context, index) {
              final transaction = state.transactions[index];
              return OptimizedTransactionItem(
                // ✅ Stable key helps Flutter optimize
                key: ValueKey(transaction.key),
                transaction: transaction,
              );
            },
          );
        }
        return LoadingWidget();
      },
    );
  }
}

// Case Study 2: Memory Leaks in Stream Subscriptions
class PerformanceCaseStudy2 {
  // PROBLEM: Stream subscription not cancelled
  static class ProblematicWidget extends StatefulWidget {
    @override
    State<ProblematicWidget> createState() => _ProblematicWidgetState();
  }
  
  static class _ProblematicWidgetState extends State<ProblematicWidget> {
    @override
    void initState() {
      super.initState();
      
      // ❌ This subscription will never be cancelled!
      context.read<TransactionBloc>().stream.listen((state) {
        if (state is TransactionOperationSuccess) {
          // Handle success
        }
      });
    }
    
    @override
    Widget build(BuildContext context) {
      return Container();
    }
    
    // ❌ Missing dispose method - memory leak!
  }
  
  // SOLUTION: Proper subscription management
  static class OptimizedWidget extends StatefulWidget {
    @override
    State<OptimizedWidget> createState() => _OptimizedWidgetState();
  }
  
  static class _OptimizedWidgetState extends State<OptimizedWidget> {
    StreamSubscription<TransactionState>? _subscription;
    
    @override
    void initState() {
      super.initState();
      
      // ✅ Store subscription reference
      _subscription = context.read<TransactionBloc>().stream.listen((state) {
        if (state is TransactionOperationSuccess) {
          // Handle success
        }
      });
    }
    
    @override
    Widget build(BuildContext context) {
      return Container();
    }
    
    @override
    void dispose() {
      // ✅ Cancel subscription to prevent memory leak
      _subscription?.cancel();
      super.dispose();
    }
  }
}

// Case Study 3: Inefficient Database Queries
class PerformanceCaseStudy3 {
  // PROBLEM: Loading all data for simple operations
  static class IneffficientTransactionService {
    Future<double> getCurrentBalance() async {
      // ❌ Loads ALL transactions just to calculate balance
      final allTransactions = await getAllTransactions();
      
      return allTransactions.fold<double>(0.0, (sum, transaction) {
        return transaction.isExpense ? sum - transaction.value : sum + transaction.value;
      });
    }
    
    Future<List<Transaction>> getRecentTransactions() async {
      // ❌ Loads ALL transactions, then filters in memory
      final allTransactions = await getAllTransactions();
      final cutoffDate = DateTime.now().subtract(Duration(days: 30));
      
      return allTransactions.where((tx) => tx.date.isAfter(cutoffDate)).toList();
    }
  }
  
  // SOLUTION: Smart caching and lazy loading
  static class EfficientTransactionService {
    List<Transaction>? _cachedTransactions;
    DateTime? _cacheTimestamp;
    double? _cachedBalance;
    static const cacheValidDuration = Duration(minutes: 5);
    
    Future<List<Transaction>> getAllTransactions() async {
      // Check if cache is still valid
      if (_cachedTransactions != null && _cacheTimestamp != null) {
        final cacheAge = DateTime.now().difference(_cacheTimestamp!);
        if (cacheAge < cacheValidDuration) {
          return _cachedTransactions!;
        }
      }
      
      // Load from database and update cache
      final transactions = await _loadFromDatabase();
      _cachedTransactions = transactions;
      _cacheTimestamp = DateTime.now();
      _cachedBalance = null; // Invalidate balance cache
      
      return transactions;
    }
    
    Future<double> getCurrentBalance() async {
      // Use cached balance if available
      if (_cachedBalance != null && _isCacheValid()) {
        return _cachedBalance!;
      }
      
      // Calculate and cache balance
      final transactions = await getAllTransactions();
      _cachedBalance = transactions.fold<double>(0.0, (sum, transaction) {
        return transaction.isExpense ? sum - transaction.value : sum + transaction.value;
      });
      
      return _cachedBalance!;
    }
    
    Future<List<Transaction>> getRecentTransactions({int days = 30}) async {
      final allTransactions = await getAllTransactions();
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      // ✅ Filter efficiently with indexed access
      return allTransactions.where((tx) => tx.date.isAfter(cutoffDate)).toList();
    }
    
    bool _isCacheValid() {
      return _cacheTimestamp != null &&
             DateTime.now().difference(_cacheTimestamp!) < cacheValidDuration;
    }
    
    Future<List<Transaction>> _loadFromDatabase() async {
      // Actual database loading logic
      return [];
    }
    
    void invalidateCache() {
      _cachedTransactions = null;
      _cachedBalance = null;
      _cacheTimestamp = null;
    }
  }
}
```

---

## 🎓 Mastery Checklist

After reading this advanced guide, you should be able to:

### 🏗️ **Architecture Mastery**
- [ ] Design complex BLoC compositions with multiple communicating BLoCs
- [ ] Implement advanced state management patterns (optimistic updates, undo/redo)
- [ ] Create proper error recovery strategies with circuit breakers
- [ ] Build comprehensive error classification systems

### 🧪 **Testing Excellence**
- [ ] Write property-based tests that discover edge cases
- [ ] Implement mutation testing to validate test quality
- [ ] Create end-to-end integration tests for complete user journeys
- [ ] Build automated quality gates and pre-commit hooks

### ⚡ **Performance Optimization**
- [ ] Profile and optimize widget rebuilding patterns
- [ ] Implement memory leak detection and prevention
- [ ] Design efficient caching strategies for data operations
- [ ] Monitor and optimize app startup time and runtime performance

### 🐛 **Advanced Debugging**
- [ ] Build custom debugging tools and observers
- [ ] Implement comprehensive logging and monitoring systems
- [ ] Create database inspection and validation tools
- [ ] Set up production error tracking and analytics

### 🏭 **Professional Practices**
- [ ] Design CI/CD pipelines with quality gates
- [ ] Implement comprehensive code review processes
- [ ] Build emergency response systems for production issues
- [ ] Create monitoring dashboards and alerting systems

### 🌍 **Real-World Application**
- [ ] Handle production emergencies with systematic approaches
- [ ] Implement feature flags and gradual rollout systems
- [ ] Design scalable architectures that grow with requirements
- [ ] Mentor other developers using established patterns

---

## 📚 Next Steps in Your Journey

### **Immediate Actions (This Week)**
1. **Pick one advanced pattern** from this guide and implement it in your current project
2. **Set up basic monitoring** - Add error tracking and performance monitoring
3. **Improve your testing** - Add property-based tests or improve golden test coverage
4. **Review your error handling** - Implement comprehensive error classification

### **Short Term Goals (This Month)**
1. **Implement CI/CD pipeline** with automated quality gates
2. **Add performance monitoring** to identify bottlenecks
3. **Create debugging tools** for your specific application needs
4. **Document your architecture decisions** for team knowledge sharing

### **Long Term Mastery (This Quarter)**
1. **Design a complex feature** using all the patterns learned
2. **Mentor another developer** - Teaching reinforces your own understanding
3. **Contribute to open source** - Apply your knowledge in different contexts
4. **Optimize for scale** - Prepare your app for 10x more users/data

---

## 🎯 Advanced Practice Exercises

### **Exercise 1: Complex State Management**
Build a transaction categorization system that:
- Allows users to create custom categories
- Auto-suggests categories based on transaction titles
- Supports hierarchical categories (Food → Restaurants → Italian)
- Implements undo/redo for category changes
- Provides bulk categorization operations

**Learning Goals:** Advanced BLoC composition, complex state transitions, optimistic updates

### **Exercise 2: Performance Optimization Challenge**
Optimize your app to handle:
- 10,000+ transactions without UI lag
- Complex filtering and search operations
- Real-time balance calculations
- Smooth animations during data operations
- Memory usage under 100MB

**Learning Goals:** Profiling, caching strategies, efficient algorithms, memory management

### **Exercise 3: Production Readiness**
Prepare your app for production with:
- Comprehensive error monitoring and recovery
- A/B testing framework for new features
- Performance monitoring and alerting
- Automated deployment pipeline
- User analytics and behavior tracking

**Learning Goals:** Production systems, monitoring, DevOps practices, user experience optimization

### **Exercise 4: Advanced Testing Suite**
Build a comprehensive testing system that:
- Achieves 95%+ code coverage with meaningful tests
- Includes property-based testing for business logic
- Implements visual regression testing for all screens
- Provides automated performance regression detection
- Includes load testing for database operations

**Learning Goals:** Testing strategies, quality assurance, automation, reliability engineering

---

## 🌟 Expert-Level Concepts

### **Micro-Architecture Patterns**

#### **Repository Pattern with Data Sources**
```dart
// Advanced data layer architecture
abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions();
  Future<void> addTransaction(Transaction transaction);
  Stream<List<Transaction>> watchTransactions();
}

class TransactionRepositoryImpl implements TransactionRepository {
  final LocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;
  final CacheDataSource _cacheDataSource;
  final SyncService _syncService;
  
  TransactionRepositoryImpl({
    required LocalDataSource localDataSource,
    required RemoteDataSource remoteDataSource,
    required CacheDataSource cacheDataSource,
    required SyncService syncService,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _cacheDataSource = cacheDataSource,
       _syncService = syncService;

  @override
  Future<List<Transaction>> getTransactions() async {
    // Try cache first
    final cachedData = await _cacheDataSource.getTransactions();
    if (cachedData.isNotEmpty && !_cacheDataSource.isExpired()) {
      return cachedData;
    }
    
    // Try remote data
    try {
      final remoteData = await _remoteDataSource.getTransactions();
      await _cacheDataSource.cacheTransactions(remoteData);
      await _syncService.syncToLocal(remoteData);
      return remoteData;
    } catch (e) {
      // Fallback to local data
      return _localDataSource.getTransactions();
    }
  }

  @override
  Stream<List<Transaction>> watchTransactions() {
    return StreamGroup.merge([
      _localDataSource.watchTransactions(),
      _remoteDataSource.watchTransactions(),
    ]).distinct();
  }
}
```

#### **Use Case Pattern for Complex Business Logic**
```dart
// Clean architecture use cases
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class AddTransactionUseCase implements UseCase<Transaction, AddTransactionParams> {
  final TransactionRepository repository;
  final ValidationService validationService;
  final NotificationService notificationService;
  final AnalyticsService analyticsService;
  
  AddTransactionUseCase({
    required this.repository,
    required this.validationService,
    required this.notificationService,
    required this.analyticsService,
  });
  
  @override
  Future<Either<Failure, Transaction>> call(AddTransactionParams params) async {
    // Step 1: Validate input
    final validationResult = await validationService.validateTransaction(params);
    if (validationResult.isLeft()) {
      return Left(validationResult.leftValue);
    }
    
    // Step 2: Check business rules
    final businessRulesResult = await _checkBusinessRules(params);
    if (businessRulesResult.isLeft()) {
      return Left(businessRulesResult.leftValue);
    }
    
    // Step 3: Execute transaction
    try {
      final transaction = Transaction.fromParams(params);
      await repository.addTransaction(transaction);
      
      // Step 4: Side effects
      await Future.wait([
        notificationService.notifyTransactionAdded(transaction),
        analyticsService.trackTransactionAdded(transaction),
      ]);
      
      return Right(transaction);
      
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  Future<Either<Failure, void>> _checkBusinessRules(AddTransactionParams params) async {
    // Implement complex business rules here
    if (params.isExpense && params.value > 10000) {
      return Left(BusinessRuleFailure(message: 'Expense too large'));
    }
    
    return Right(null);
  }
}

class AddTransactionParams {
  final String title;
  final double value;
  final bool isExpense;
  final DateTime date;
  final String? category;
  
  const AddTransactionParams({
    required this.title,
    required this.value,
    required this.isExpense,
    required this.date,
    this.category,
  });
}

// Either type for functional error handling
abstract class Either<L, R> {
  bool isLeft();
  bool isRight();
  L get leftValue;
  R get rightValue;
}

class Left<L, R> extends Either<L, R> {
  final L value;
  Left(this.value);
  
  @override
  bool isLeft() => true;
  
  @override
  bool isRight() => false;
  
  @override
  L get leftValue => value;
  
  @override
  R get rightValue => throw StateError('Called rightValue on Left');
}

class Right<L, R> extends Either<L, R> {
  final R value;
  Right(this.value);
  
  @override
  bool isLeft() => false;
  
  @override
  bool isRight() => true;
  
  @override
  L get leftValue => throw StateError('Called leftValue on Right');
  
  @override
  R get rightValue => value;
}

abstract class Failure {
  final String message;
  const Failure({required this.message});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

class BusinessRuleFailure extends Failure {
  const BusinessRuleFailure({required super.message});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}
```

#### **Event Sourcing Pattern**
```dart
// Advanced: Event sourcing for complete transaction history
abstract class DomainEvent {
  final String eventId;
  final DateTime timestamp;
  final String aggregateId;
  final int version;
  
  const DomainEvent({
    required this.eventId,
    required this.timestamp,
    required this.aggregateId,
    required this.version,
  });
  
  Map<String, dynamic> toJson();
  static DomainEvent fromJson(Map<String, dynamic> json);
}

class TransactionAddedEvent extends DomainEvent {
  final String title;
  final double value;
  final bool isExpense;
  
  const TransactionAddedEvent({
    required super.eventId,
    required super.timestamp,
    required super.aggregateId,
    required super.version,
    required this.title,
    required this.value,
    required this.isExpense,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'eventType': 'TransactionAdded',
    'eventId': eventId,
    'timestamp': timestamp.toIso8601String(),
    'aggregateId': aggregateId,
    'version': version,
    'data': {
      'title': title,
      'value': value,
      'isExpense': isExpense,
    },
  };
}

class TransactionAggregate {
  final String id;
  final List<DomainEvent> _events = [];
  int _version = 0;
  
  // Current state derived from events
  List<Transaction> _transactions = [];
  
  TransactionAggregate(this.id);
  
  // Command methods that generate events
  void addTransaction(String title, double value, bool isExpense) {
    final event = TransactionAddedEvent(
      eventId: _generateEventId(),
      timestamp: DateTime.now(),
      aggregateId: id,
      version: _version + 1,
      title: title,
      value: value,
      isExpense: isExpense,
    );
    
    _applyEvent(event);
    _events.add(event);
  }
  
  // Apply events to rebuild state
  void _applyEvent(DomainEvent event) {
    switch (event.runtimeType) {
      case TransactionAddedEvent:
        final addedEvent = event as TransactionAddedEvent;
        _transactions.add(Transaction(
          title: addedEvent.title,
          value: addedEvent.value,
          isExpense: addedEvent.isExpense,
          date: addedEvent.timestamp,
        ));
        break;
      // Handle other event types...
    }
    
    _version = event.version;
  }
  
  // Getters for current state
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<DomainEvent> get uncommittedEvents => List.unmodifiable(_events);
  int get version => _version;
  
  // Rebuild aggregate from event history
  static TransactionAggregate fromHistory(String id, List<DomainEvent> history) {
    final aggregate = TransactionAggregate(id);
    
    for (final event in history) {
      aggregate._applyEvent(event);
    }
    
    return aggregate;
  }
  
  void markEventsAsCommitted() {
    _events.clear();
  }
  
  String _generateEventId() => Uuid().v4();
}

class EventStore {
  final Map<String, List<DomainEvent>> _eventStreams = {};
  
  Future<void> saveEvents(String aggregateId, List<DomainEvent> events) async {
    final currentEvents = _eventStreams[aggregateId] ?? [];
    _eventStreams[aggregateId] = [...currentEvents, ...events];
    
    // In production, this would save to a database
    for (final event in events) {
      await _persistEvent(event);
    }
  }
  
  Future<List<DomainEvent>> getEvents(String aggregateId) async {
    return _eventStreams[aggregateId] ?? [];
  }
  
  Future<void> _persistEvent(DomainEvent event) async {
    // Save to database, message queue, etc.
  }
}
```

### **Advanced Testing Patterns**

#### **Contract Testing**
```dart
// Contract testing for API interactions
abstract class TransactionApiContract {
  Future<List<Transaction>> getTransactions();
  Future<Transaction> addTransaction(CreateTransactionRequest request);
  Future<void> deleteTransaction(String id);
}

class ContractTestSuite {
  static void runContractTests(TransactionApiContract implementation) {
    group('Transaction API Contract Tests', () {
      test('getTransactions returns list of transactions', () async {
        final transactions = await implementation.getTransactions();
        
        expect(transactions, isA<List<Transaction>>());
        
        if (transactions.isNotEmpty) {
          final transaction = transactions.first;
          expect(transaction.title, isA<String>());
          expect(transaction.value, isA<double>());
          expect(transaction.isExpense, isA<bool>());
          expect(transaction.date, isA<DateTime>());
        }
      });
      
      test('addTransaction creates and returns transaction', () async {
        final request = CreateTransactionRequest(
          title: 'Test Transaction',
          value: 100.0,
          isExpense: true,
        );
        
        final transaction = await implementation.addTransaction(request);
        
        expect(transaction.title, equals(request.title));
        expect(transaction.value, equals(request.value));
        expect(transaction.isExpense, equals(request.isExpense));
        expect(transaction.date, isA<DateTime>());
      });
      
      test('deleteTransaction removes transaction', () async {
        // First create a transaction
        final createRequest = CreateTransactionRequest(
          title: 'To be deleted',
          value: 50.0,
          isExpense: true,
        );
        
        final created = await implementation.addTransaction(createRequest);
        
        // Then delete it
        await implementation.deleteTransaction(created.id);
        
        // Verify it's gone
        final transactions = await implementation.getTransactions();
        final deletedTransaction = transactions.where((t) => t.id == created.id);
        expect(deletedTransaction, isEmpty);
      });
    });
  }
}

// Usage for both real API and mock implementations
void main() {
  group('Real API Contract', () {
    ContractTestSuite.runContractTests(RealTransactionApi());
  });
  
  group('Mock API Contract', () {
    ContractTestSuite.runContractTests(MockTransactionApi());
  });
}
```

#### **Behavior-Driven Development (BDD) with Gherkin**
```dart
// BDD tests in Gherkin style
class BDDTransactionTests {
  static void runBDDTests() {
    group('Transaction Management BDD Tests', () {
      testWidgets('User can add a new expense transaction', (tester) async {
        // Given: User is on the home screen with no transactions
        await _givenUserIsOnEmptyHomeScreen(tester);
        
        // When: User adds a new expense transaction
        await _whenUserAddsExpenseTransaction(tester, 'Coffee', 4.50);
        
        // Then: The transaction appears in the list
        await _thenTransactionAppearsInList(tester, 'Coffee', 4.50, true);
        
        // And: The balance is updated correctly
        await _andBalanceIsUpdated(tester, -4.50);
      });
      
      testWidgets('User cannot add transaction with empty title', (tester) async {
        // Given: User is on the transaction form
        await _givenUserIsOnTransactionForm(tester);
        
        // When: User tries to save with empty title
        await _whenUserTriesToSaveWithEmptyTitle(tester);
        
        // Then: Validation error is shown
        await _thenValidationErrorIsShown(tester, 'Por favor, insira um título');
        
        // And: Transaction is not saved
        await _andTransactionIsNotSaved(tester);
      });
    });
  }
  
  static Future<void> _givenUserIsOnEmptyHomeScreen(WidgetTester tester) async {
    await tester.pumpWidget(TestApp(
      child: BlocProvider(
        create: (_) => TransactionBloc(),
        child: MyHomePage(),
      ),
    ));
    await tester.pumpAndSettle();
    
    expect(find.text('Nenhuma transação ainda'), findsOneWidget);
  }
  
  static Future<void> _whenUserAddsExpenseTransaction(
    WidgetTester tester,
    String title,
    double value,
  ) async {
    // Tap add button
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    
    // Fill form
    await tester.enterText(find.byType(TextFormField).first, title);
    await tester.enterText(find.byType(TextFormField).last, value.toString());
    
    // Expense is default, so don't change type
    
    // Save
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
  }
  
  static Future<void> _thenTransactionAppearsInList(
    WidgetTester tester,
    String title,
    double value,
    bool isExpense,
  ) async {
    expect(find.text(title), findsOneWidget);
    expect(find.text('R\$ ${value.toStringAsFixed(2)}'), findsOneWidget);
    
    final expectedIcon = isExpense ? Icons.remove : Icons.add;
    expect(find.byIcon(expectedIcon), findsOneWidget);
  }
  
  static Future<void> _andBalanceIsUpdated(WidgetTester tester, double expectedBalance) async {
    expect(
      find.text('R\$ ${expectedBalance.toStringAsFixed(2)}'),
      findsOneWidget,
    );
  }
  
  // Additional helper methods...
  static Future<void> _givenUserIsOnTransactionForm(WidgetTester tester) async {
    await _givenUserIsOnEmptyHomeScreen(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
  }
  
  static Future<void> _whenUserTriesToSaveWithEmptyTitle(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField).last, '100.0');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
  }
  
  static Future<void> _thenValidationErrorIsShown(WidgetTester tester, String expectedError) async {
    expect(find.text(expectedError), findsOneWidget);
  }
  
  static Future<void> _andTransactionIsNotSaved(WidgetTester tester) async {
    // Form should still be visible
    expect(find.text('Nova Transação'), findsOneWidget);
  }
}
```

---

## 🌟 Master-Level Achievements

When you've mastered these advanced concepts, you'll be able to:

### **🏗️ Architect Enterprise Applications**
- Design systems that handle millions of transactions
- Build fault-tolerant applications with automatic recovery
- Create modular architectures that multiple teams can work on
- Implement sophisticated caching and data synchronization strategies

### **🧪 Lead Testing Initiatives**
- Design comprehensive testing strategies for entire organizations
- Implement automated quality gates that prevent regressions
- Create testing frameworks that other developers can easily use
- Build confidence in deployments through thorough testing

### **🚀 Optimize at Scale**
- Profile and optimize applications for peak performance
- Design efficient algorithms that scale with data size
- Implement monitoring systems that prevent issues before they occur
- Create tools that help entire teams write performant code

### **🎯 Drive Technical Excellence**
- Mentor other developers in advanced patterns and practices
- Make architectural decisions that benefit entire projects
- Create development processes that ensure consistent quality
- Build systems that adapt and evolve with changing requirements

---

## 🎓 Final Words

You've now journeyed through a comprehensive exploration of advanced Flutter development, from basic BLoC patterns to enterprise-level architecture decisions. This knowledge represents years of industry best practices distilled into actionable guidance.

**Remember:**
- **Start small** - Don't try to implement everything at once
- **Practice consistently** - Mastery comes through repetition and refinement
- **Share knowledge** - Teaching others reinforces your own understanding
- **Stay curious** - Technology evolves, and continuous learning is essential

The patterns and principles in this guide will serve you well beyond just Flutter development. They represent fundamental software engineering concepts that apply across technologies and domains.

**Your journey to mastery continues with each project you build, each problem you solve, and each developer you help along the way.**

---

*Happy coding, and remember: great software is not just about the code you write, but about the problems you solve and the value you create for users.* 🚀✨    # Style rules
    always_declare_return_types: true
    prefer_single_quotes: true
    sort_constructors_first: true
    sort_unnamed_constructors_first: true
    
    # Documentation rules
    public_member_api_docs: true
    package_api_docs: true
    
    # Security rules
    avoid_web_libraries_in_flutter: true
```

#### 🔧 Custom Lint Rules

```dart
// custom_lints.yaml - Project-specific rules
custom_lint:
  rules:
    - no_hardcoded_strings
    - consistent_naming_convention
    - bloc_event_naming
    - state_immutability_check

# Example custom lint rule implementation
// lib/lints/bloc_event_naming.dart
class BlocEventNamingRule extends DartLintRule {
  const BlocEventNamingRule() : super(code: _code);

  static const _code = LintCode(
    name: 'bloc_event_naming',
    problemMessage: 'BLoC events should be named with verb-noun pattern',
    correctionMessage: 'Consider renaming to follow LoadTransactions, AddTransaction pattern',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      if (_extendsTransactionEvent(node)) {
        final className = node.name.lexeme;
        if (!_followsVerbNounPattern(className)) {
          reporter.reportErrorForNode(code, node.name);
        }
      }
    });
  }

  bool _extendsTransactionEvent(ClassDeclaration node) {
    // Check if class extends TransactionEvent
    return node.extendsClause?.superclass.name2.lexeme == 'TransactionEvent';
  }

  bool _followsVerbNounPattern(String className) {
    // Check patterns like: LoadTransactions, AddTransaction, DeleteTransaction
    final validPatterns = [
      RegExp(r'^Load[A-Z]'),
      RegExp(r'^Add[A-Z]'),
      RegExp(r'^Update[A-Z]'),
      RegExp(r'^Delete[A-Z]'),
      RegExp(r'^Clear[A-Z]'),
      RegExp(r'^Search[A-Z]'),
      RegExp(r'^Filter[A-Z]'),
    ];
    
    return validPatterns.any((pattern) => pattern.hasMatch(className));
  }
}
```

### Code Documentation Standards

#### 📚 Comprehensive Documentation Patterns

```dart
/// Service responsible for managing transaction data operations.
/// 
/// This service acts as a bridge between the BLoC layer and the database layer,
/// providing high-level operations for transaction management with proper
/// error handling and data validation.
/// 
/// Example usage:
/// ```dart
/// final service = TransactionService();
/// await service.addTransaction(
///   title: 'Groceries',
///   value: 150.50,
///   isExpense: true,
/// );
/// ```
/// 
/// See also:
/// * [TransactionBloc] for state management
/// * [DatabaseService] for low-level database operations
class TransactionService {
  /// Creates a new transaction service with the provided database service.
  /// 
  /// If [databaseService] is null, a default instance will be created.
  TransactionService({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService();

  final DatabaseService _databaseService;

  /// Adds a new transaction to the database.
  /// 
  /// Validates the input parameters and creates a new [Transaction] object
  /// with the current timestamp. The transaction is then saved to the database.
  /// 
  /// Parameters:
  /// * [title] - The transaction description (required, non-empty)
  /// * [value] - The transaction amount (required, > 0)
  /// * [isExpense] - Whether this is an expense (true) or income (false)
  /// 
  /// Throws:
  /// * [ValidationException] if input parameters are invalid
  /// * [DatabaseException] if database operation fails
  /// 
  /// Example:
  /// ```dart
  /// await service.addTransaction(
  ///   title: 'Coffee',
  ///   value: 4.50,
  ///   isExpense: true,
  /// );
  /// ```
  Future<void> addTransaction({
    required String title,
    required double value,
    required bool isExpense,
  }) async {
    // Input validation with detailed error messages
    if (title.trim().isEmpty) {
      throw ValidationException(
        message: 'Transaction title cannot be empty',
        field: 'title',
        invalidValue: title,
      );
    }

    if (value <= 0) {
      throw ValidationException(
        message: 'Transaction value must be greater than zero',
        field: 'value',
        invalidValue: value,
      );
    }

    if (value > AppConstants.maxTransactionValue) {
      throw ValidationException(
        message: 'Transaction value exceeds maximum allowed amount',
        field: 'value',
        invalidValue: value,
      );
    }

    try {
      final transaction = Transaction(
        title: title.trim(),
        value: value,
        date: DateTime.now(),
        isExpense: isExpense,
      );

      await _databaseService.addTransaction(transaction);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to save transaction to database',
        operation: 'addTransaction',
        originalError: e,
        stackTrace: StackTrace.current,
      );
    }
  }

  /// Calculates the current balance from a list of transactions.
  /// 
  /// This is a pure function that doesn't modify any state or make external calls.
  /// Income transactions add to the balance, expense transactions subtract from it.
  /// 
  /// Parameters:
  /// * [transactions] - List of transactions to calculate balance from
  /// 
  /// Returns:
  /// The calculated balance as a [double]. Positive values indicate net income,
  /// negative values indicate net expenses.
  /// 
  /// Example:
  /// ```dart
  /// final transactions = [
  ///   Transaction(value: 1000, isExpense: false), // +1000
  ///   Transaction(value: 300, isExpense: true),   // -300
  /// ];
  /// final balance = service.calculateBalance(transactions); // 700.0
  /// ```
  double calculateBalance(List<Transaction> transactions) {
    return transactions.fold<double>(0.0, (sum, transaction) {
      return transaction.isExpense 
          ? sum - transaction.value 
          : sum + transaction.value;
    });
  }

  /// Gets the appropriate pig image path based on the balance.
  /// 
  /// This provides visual feedback to users about their financial state:
  /// * Positive balance: Happy pig (success)
  /// * Zero balance: Neutral pig (neutral)  
  /// * Negative balance: Sad pig (warning)
  /// 
  /// Parameters:
  /// * [balance] - The current balance amount
  /// 
  /// Returns:
  /// Asset path string for the appropriate pig image
  /// 
  /// Example:
  /// ```dart
  /// final imagePath = service.getBalanceImagePath(150.0);
  /// // Returns: 'assets/images/porquinho_feliz.png'
  /// ```
  String getBalanceImagePath(double balance) {
    if (balance > 0) {
      return AppConstants.happyPigImage;
    } else if (balance < 0) {
      return AppConstants.sadPigImage;
    } else {
      return AppConstants.neutralPigImage;
    }
  }
}
```

### Refactoring Strategies

#### 🔄 Safe Refactoring Patterns

```dart
// Example: Refactoring to extract business logic

// BEFORE: Business logic mixed in BLoC
class TransactionBlocBefore extends Bloc<TransactionEvent, TransactionState> {
  Future<void> _onAddTransaction(AddTransaction event, Emitter emit) async {
    // ❌ Validation logic in BLoC
    if (event.title.trim().isEmpty) {
      emit(TransactionError(error: AppError(message: 'Title required')));
      return;
    }
    
    if (event.value <= 0) {
      emit(TransactionError(error: AppError(message: 'Value must be positive')));
      return;
    }

    // ❌ Business rules in BLoC
    final monthlyLimit = 5000.0;
    final currentMonth = DateTime.now().month;
    final monthlyExpenses = await _getMonthlyExpenses(currentMonth);
    
    if (event.isExpense && (monthlyExpenses + event.value) > monthlyLimit) {
      emit(TransactionError(error: AppError(message: 'Monthly limit exceeded')));
      return;
    }

    // Database operation
    await _databaseService.addTransaction(Transaction(/*...*/));
    emit(TransactionOperationSuccess(/*...*/));
  }
}

// AFTER: Clean separation of concerns
class TransactionBlocAfter extends Bloc<TransactionEvent, TransactionState> {
  final TransactionService _transactionService;
  final ValidationService _validationService;
  final BusinessRuleService _businessRuleService;

  Future<void> _onAddTransaction(AddTransaction event, Emitter emit) async {
    try {
      // ✅ Delegate validation to service
      _validationService.validateTransactionInput(
        title: event.title,
        value: event.value,
      );

      // ✅ Delegate business rules to service
      await _businessRuleService.checkTransactionRules(
        value: event.value,
        isExpense: event.isExpense,
      );

      // ✅ Delegate transaction creation to service
      await _transactionService.addTransaction(
        title: event.title,
        value: event.value,
        isExpense: event.isExpense,
      );

      emit(TransactionOperationSuccess(/*...*/));
      
    } catch (e) {
      // ✅ Simple error handling - services provide structured errors
      final appError = e is AppException ? e : ErrorHandler.handleException(e);
      emit(TransactionError(error: appError));
    }
  }
}

// New services extracted from BLoC
class ValidationService {
  void validateTransactionInput({
    required String title,
    required double value,
  }) {
    if (title.trim().isEmpty) {
      throw ValidationException(
        message: 'Transaction title cannot be empty',
        field: 'title',
        invalidValue: title,
      );
    }

    if (value <= 0) {
      throw ValidationException(
        message: 'Transaction value must be positive',
        field: 'value',
        invalidValue: value,
      );
    }

    if (value > AppConstants.maxTransactionValue) {
      throw ValidationException(
        message: 'Transaction value too large',
        field: 'value',
        invalidValue: value,
      );
    }
  }
}

class BusinessRuleService {
  final TransactionService _transactionService;

  BusinessRuleService({required TransactionService transactionService})
      : _transactionService = transactionService;

  Future<void> checkTransactionRules({
    required double value,
    required bool isExpense,
  }) async {
    if (isExpense) {
      await _checkMonthlySpendingLimit(value);
      await _checkDailyTransactionLimit(value);
    }
  }

  Future<void> _checkMonthlySpendingLimit(double value) async {
    const monthlyLimit = 5000.0;
    final currentMonth = DateTime.now().month;
    final monthlyExpenses = await _transactionService.getMonthlyExpenses(currentMonth);

    if ((monthlyExpenses + value) > monthlyLimit) {
      throw BusinessLogicException(
        message: 'Adding this expense would exceed monthly limit of R\$ $monthlyLimit',
        businessRule: 'monthly_spending_limit',
      );
    }
  }

  Future<void> _checkDailyTransactionLimit(double value) async {
    const maxDailyTransactions = 10;
    final today = DateTime.now();
    final todayTransactions = await _transactionService.getTransactionsForDate(today);

    if (todayTransactions.length >= maxDailyTransactions) {
      throw BusinessLogicException(
        message: 'Maximum daily transactions limit reached',
        businessRule: 'daily_transaction_limit',
      );
    }
  }
}
```

## 🐛 Debugging Techniques

### Advanced Debugging Strategies

#### 🔍 BLoC State Debugging

```dart
// Custom BLoC observer for debugging
class DebugBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    debugPrint('🟢 BLoC Created: ${bloc.runtimeType}');
  }

  @override
  void onEvent(BlocBase bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('🔵 Event: ${bloc.runtimeType} -> $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('🟡 State Change: ${bloc.runtimeType}');
    debugPrint('   From: ${change.currentState}');
    debugPrint('   To: ${change.nextState}');
  }

  @override
  void onTransition(BlocBase bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint('🔄 Transition: ${bloc.runtimeType}');
    debugPrint('   Event: ${transition.event}');
    debugPrint('   Current: ${transition.currentState}');
    debugPrint('   Next: ${transition.nextState}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('🔴 BLoC Error: ${bloc.runtimeType}');
    debugPrint('   Error: $error');
    debugPrint('   Stack: $stackTrace');
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    debugPrint('🔴 BLoC Closed: ${bloc.runtimeType}');
  }
}

// Usage in main.dart
void main() {
  // Set up BLoC observer in debug mode
  if (kDebugMode) {
    Bloc.observer = DebugBlocObserver();
  }
  
  runApp(FinanappApplication());
}
```

#### 📊 Performance Debugging

```dart
// Widget rebuild tracker
class RebuildTracker extends StatefulWidget {
  final Widget child;
  final String name;
  final bool enabled;

  const RebuildTracker({
    super.key,
    required this.child,
    required this.name,
    this.enabled = kDebugMode,
  });

  @override
  State<RebuildTracker> createState() => _RebuildTrackerState();
}

class _RebuildTrackerState extends State<RebuildTracker> {
  static final Map<String, RebuildStats> _stats = {};
  late final Stopwatch _stopwatch;
  
  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    _stopwatch.start();
    
    final buildStartTime = DateTime.now();
    final result = widget.child;
    final buildTime = DateTime.now().difference(buildStartTime);
    
    _stopwatch.stop();
    
    // Update stats
    final currentStats = _stats[widget.name] ?? RebuildStats(widget.name);
    _stats[widget.name] = currentStats.addRebuild(buildTime);
    
    // Log expensive rebuilds
    if (buildTime.inMilliseconds > 50) {
      debugPrint('🐌 Slow rebuild: ${widget.name} took ${buildTime.inMilliseconds}ms');
    }
    
    _stopwatch.reset();
    return result;
  }

  // Static method to get rebuild statistics
  static Map<String, RebuildStats> getStats() => Map.from(_stats);
  
  static void clearStats() => _stats.clear();
  
  static void printStats() {
    debugPrint('\n📊 Widget Rebuild Statistics:');
    final sortedStats = _stats.values.toList()
      ..sort((a, b) => b.totalTime.compareTo(a.totalTime));
    
    for (final stat in sortedStats) {
      debugPrint('  ${stat.name}:');
      debugPrint('    Rebuilds: ${stat.rebuildCount}');
      debugPrint('    Total time: ${stat.totalTime.inMilliseconds}ms');
      debugPrint('    Avg time: ${stat.averageTime.inMilliseconds}ms');
      debugPrint('    Max time: ${stat.maxTime.inMilliseconds}ms');
    }
  }
}

class RebuildStats {
  final String name;
  final int rebuildCount;
  final Duration totalTime;
  final Duration maxTime;
  final List<Duration> _buildTimes;

  RebuildStats(
    this.name, {
    this.rebuildCount = 0,
    this.totalTime = Duration.zero,
    this.maxTime = Duration.zero,
    List<Duration>? buildTimes,
  }) : _buildTimes = buildTimes ?? [];

  Duration get averageTime {
    if (rebuildCount == 0) return Duration.zero;
    return Duration(microseconds: totalTime.inMicroseconds ~/ rebuildCount);
  }

  RebuildStats addRebuild(Duration buildTime) {
    final newBuildTimes = [..._buildTimes, buildTime];
    
    // Keep only last 100 build times for memory efficiency
    if (newBuildTimes.length > 100) {
      newBuildTimes.removeAt(0);
    }

    return RebuildStats(
      name,
      rebuildCount: rebuildCount + 1,
      totalTime: totalTime + buildTime,
      maxTime: buildTime > maxTime ? buildTime : maxTime,
      buildTimes: newBuildTimes,
    );
  }
}

// Usage in widgets
class DebuggedTransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RebuildTracker(
      name: 'TransactionList',
      child: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          return RebuildTracker(
            name: 'TransactionList_Builder',
            child: _buildList(state),
          );
        },
      ),
    );
  }
  
  Widget _buildList(TransactionState state) {
    if (state is TransactionLoaded) {
      return ListView.builder(
        itemCount: state.transactions.length,
        itemBuilder: (context, index) {
          return RebuildTracker(
            name: 'TransactionItem_$index',
            child: TransactionItem(
              key: ValueKey(state.transactions[index].key),
              transaction: state.transactions[index],
            ),
          );
        },
      );
    }
    return const LoadingWidget();
  }
}
```

#### 🔬 Memory Leak Detection

```dart
// Memory leak detector for BLoCs
class BlocMemoryTracker {
  static final Map<String, int> _activeBlocCounts = {};
  static final Map<String, List<DateTime>> _createTimes = {};

  static void trackBlocCreation(String blocType) {
    _activeBlocCounts[blocType] = (_activeBlocCounts[blocType] ?? 0) + 1;
    
    final createTimes = _createTimes[blocType] ?? <DateTime>[];
    createTimes.add(DateTime.now());
    _createTimes[blocType] = createTimes;
    
    debugPrint('🟢 BLoC Created: $blocType (Active: ${_activeBlocCounts[blocType]})');
  }

  static void trackBlocDisposal(String blocType) {
    if (_activeBlocCounts[blocType] != null && _activeBlocCounts[blocType]! > 0) {
      _activeBlocCounts[blocType] = _activeBlocCounts[blocType]! - 1;
      debugPrint('🔴 BLoC Disposed: $blocType (Active: ${_activeBlocCounts[blocType]})');
    } else {
      debugPrint('⚠️  BLoC disposal without creation: $blocType');
    }
  }

  static void checkForLeaks() {
    debugPrint('\n🔍 Memory Leak Check:');
    
    bool hasLeaks = false;
    _activeBlocCounts.forEach((blocType, count) {
      if (count > 0) {
        hasLeaks = true;
        final createTimes = _createTimes[blocType] ?? [];
        final oldestCreation = createTimes.isNotEmpty ? createTimes.first : null;
        
        debugPrint('🚨 Potential leak: $blocType has $count active instances');
        if (oldestCreation != null) {
          final age = DateTime.now().difference(oldestCreation);
          debugPrint('   Oldest instance age: ${age.inMinutes} minutes');
        }
      }
    });
    
    if (!hasLeaks) {
      debugPrint('✅ No memory leaks detected');
    }
  }

  static Map<String, int> getActiveBlocCounts() => Map.from(_activeBlocCounts);
}

// Enhanced BLoC observer with memory tracking
class MemoryTrackingBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    BlocMemoryTracker.trackBlocCreation(bloc.runtimeType.toString());
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    BlocMemoryTracker.trackBlocDisposal(bloc.runtimeType.toString());
  }
}
```

### Database Debugging

#### 💾 Hive Database Inspector

```dart
// Database debugging utilities
class HiveDatabaseInspector {
  static void inspectTransactionBox() {
    final box = Hive.box<Transaction>('transactions');
    
    debugPrint('\n💾 Hive Database Inspection:');
    debugPrint('Box name: ${box.name}');
    debugPrint('Is open: ${box.isOpen}');
    debugPrint('Length: ${box.length}');
    debugPrint('Keys: ${box.keys.toList()}');
    
    if (box.isNotEmpty) {
      debugPrint('\n📋 All Transactions:');
      for (int i = 0; i < box.length; i++) {
        final key = box.keyAt(i);
        final transaction = box.getAt(i);
        debugPrint('  [$key]: ${transaction?.title} - R\$ ${transaction?.value} (${transaction?.isExpense ? 'Expense' : 'Income'})');
      }
      
      _analyzeData(box);
    } else {
      debugPrint('📭 Database is empty');
    }
  }
  
  static void _analyzeData(Box<Transaction> box) {
    final transactions = box.values.toList();
    
    final totalTransactions = transactions.length;
    final expenses = transactions.where((t) => t.isExpense).toList();
    final incomes = transactions.where((t) => !t.isExpense).toList();
    
    final totalExpenses = expenses.fold<double>(0.0, (sum, t) => sum + t.value);
    final totalIncome = incomes.fold<double>(0.0, (sum, t) => sum + t.value);
    final balance = totalIncome - totalExpenses;
    
    debugPrint('\n📊 Data Analysis:');
    debugPrint('  Total transactions: $totalTransactions');
    debugPrint('  Expenses: ${expenses.length} (R\$ ${totalExpenses.toStringAsFixed(2)})');
    debugPrint('  Incomes: ${incomes.length} (R\$ ${totalIncome.toStringAsFixed(2)})');
    debugPrint('  Current balance: R\$ ${balance.toStringAsFixed(2)}');
    
    if (transactions.isNotEmpty) {
      final oldestTransaction = transactions.reduce((a, b) => a.date.isBefore(b.date) ? a : b);
      final newestTransaction = transactions.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
      
      debugPrint('  Date range: ${DateFormat('dd/MM/yyyy').format(oldestTransaction.date)} to ${DateFormat('dd/MM/yyyy').format(newestTransaction.date)}');
    }
  }
  
  static Future<void> exportToJson() async {
    final box = Hive.box<Transaction>('transactions');
    final transactions = box.values.toList();
    
    final jsonData = transactions.map((t) => {
      'key': t.key,
      'title': t.title,
      'value': t.value,
      'date': t.date.toIso8601String(),
      'isExpense': t.isExpense,
    }).toList();
    
    final jsonString = JsonEncoder.withIndent('  ').convert({
      'exported_at': DateTime.now().toIso8601String(),
      'total_transactions': transactions.length,
      'transactions': jsonData,
    });
    
    debugPrint('\n📤 Database Export (JSON):');
    debugPrint(jsonString);
    
    // In a real app, you might save this to a file or share it
    // await File('transactions_export.json').writeAsString(jsonString);
  }
  
  static void validateDataIntegrity() {
    final box = Hive.box<Transaction>('transactions');
    
    debugPrint('\n🔍 Data Integrity Check:');
    
    int issues = 0;
    
    for (int i = 0; i < box.length; i++) {
      final transaction = box.getAt(i);
      final key = box.keyAt(i);
      
      if (transaction == null) {
        debugPrint('❌ Issue: Null transaction at index $i');
        issues++;
        continue;
      }
      
      if (transaction.title.isEmpty) {
        debugPrint('❌ Issue: Empty title at key $key');
        issues++;
      }
      
      if (transaction.value < 0) {
        debugPrint('❌ Issue: Negative value at key $key: ${transaction.value}');
        issues++;
      }
      
      if (transaction.date.isAfter(DateTime.now())) {
        debugPrint('❌ Issue: Future date at key $key: ${transaction.date}');
        issues++;
      }
    }
    
    if (issues == 0) {
      debugPrint('✅ Data integrity check passed');
    } else {
      debugPrint('⚠️  Found $issues data integrity issues');
    }
  }
}

// Usage in debug builds
class DebugDatabaseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Debug')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: HiveDatabaseInspector.inspectTransactionBox,
            child: const Text('Inspect Database'),
          ),
          ElevatedButton(
            onPressed: HiveDatabaseInspector.validateDataIntegrity,
            child: const Text('Check Integrity'),
          ),
          ElevatedButton(
            onPressed: HiveDatabaseInspector.exportToJson,
            child: const Text('Export to JSON'),
          ),
          ElevatedButton(
            onPressed: BlocMemoryTracker.checkForLeaks,
            child: const Text('Check Memory Leaks'),
          ),
          ElevatedButton(
            onPressed: RebuildTracker.printStats,
            child: const Text('Print Rebuild Stats'),
          ),
        ],
      ),
    );
  }
}
```

## 🏭 Professional Development Practices

### CI/CD Pipeline Configuration

#### 🚀 GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
      
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.x'
        channel: 'stable'
        
    - name: Get dependencies
      run: flutter pub get
      
    - name: Generate code
      run: flutter packages pub run build_runner build --delete-conflicting-outputs
      
    - name: Analyze code
      run: flutter analyze
      
    - name: Check formatting
      run: dart format --output=none --set-exit-if-changed .
      
    - name: Run unit tests
      run: flutter test --coverage
      
    - name: Run golden tests
      run: flutter test test/golden/
      
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info
        
    - name: Check coverage threshold
      run: |
        COVERAGE=$(lcov --summary coverage/lcov.info | grep 'lines......:' | cut -d' ' -f4 | cut -d'%' -f1)
        if (( $(echo "$COVERAGE < 80" | bc -l) )); then
          echo "Coverage $COVERAGE% is below threshold of 80%"
          exit 1
        fi
        echo "Coverage: $COVERAGE%"

  build:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
      
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.x'
        channel: 'stable'
        
    - name: Get dependencies
      run: flutter pub get
      
    - name: Generate code
      run: flutter packages pub run build_runner build --delete-conflicting-outputs
      
    - name: Build Android APK
      run: flutter build apk --release
      
    - name: Build iOS (if on macOS runner)
      if: runner.os == 'macOS'
      run: flutter build ios --release --no-codesign
      
    - name: Upload APK artifact
      uses: actions/upload-artifact@v3
      with:
        name: release-apk
        path: build/app/outputs/flutter-apk/app-release.apk

  security-scan:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
      
    - name: Run security scan
      uses: securecodewarrior/github-action-add-sarif@v1
      with:
        sarif-file: 'security-scan-results.sarif'
```

### Code# 🚀 Advanced Concepts & Patterns Guide

This guide explores advanced development patterns, debugging techniques, and professional practices used in Finanapp.

## 📖 Table of Contents
- [Advanced BLoC Patterns](#advanced-bloc-patterns)
- [Error Handling Mastery](#error-handling-mastery)
- [Testing Strategies](#testing-strategies)
- [Performance Deep Dive](#performance-deep-dive)
- [Code Quality & Maintenance](#code-quality--maintenance)
- [Debugging Techniques](#debugging-techniques)
- [Professional Development Practices](#professional-development-practices)
- [Real-World Scenarios](#real-world-scenarios)

## 🏗️ Advanced BLoC Patterns

### Understanding BLoC Composition

#### 🧩 Multiple BLoCs Working Together

In real applications, you often need multiple BLoCs to communicate:

```dart
// Example: Authentication affects what transactions user can see
class AppBlocComposition extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Authentication BLoC - manages user state
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(CheckAuthStatus()),
        ),
        
        // Transaction BLoC - depends on auth state
        BlocProvider<TransactionBloc>(
          create: (context) => TransactionBloc(),
        ),
        
        // Settings BLoC - manages app preferences
        BlocProvider<SettingsBloc>(
          create: (context) => SettingsBloc()..add(LoadSettings()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          // When auth state changes, update transaction BLoC
          if (authState is AuthAuthenticated) {
            context.read<TransactionBloc>().add(LoadUserTransactions(authState.userId));
          } else if (authState is AuthUnauthenticated) {
            context.read<TransactionBloc>().add(ClearTransactions());
          }
        },
        child: AppRouter(),
      ),
    );
  }
}
```

**Why This Pattern Works:**
- **Separation of Concerns** - Each BLoC handles one domain
- **Loose Coupling** - BLoCs communicate through events, not direct calls
- **Testability** - You can test each BLoC independently
- **Scalability** - Easy to add new BLoCs without changing existing ones

#### 🔄 BLoC-to-BLoC Communication Patterns

**Pattern 1: Event Cascading**
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required TransactionBloc transactionBloc}) : super(AuthInitial()) {
    on<LoginSuccess>((event, emit) async {
      emit(AuthAuthenticated(user: event.user));
      
      // Trigger other BLoCs to respond
      transactionBloc.add(LoadUserTransactions(event.user.id));
    });
  }
}
```

**Pattern 2: Stream Subscription**
```dart
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  late StreamSubscription _authSubscription;
  
  TransactionBloc({required AuthBloc authBloc}) : super(TransactionInitial()) {
    // Listen to auth changes
    _authSubscription = authBloc.stream.listen((authState) {
      if (authState is AuthAuthenticated) {
        add(LoadUserTransactions(authState.user.id));
      } else if (authState is AuthUnauthenticated) {
        add(ClearTransactions());
      }
    });
    
    // Register event handlers
    on<LoadUserTransactions>(_onLoadUserTransactions);
  }
  
  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
```

**Pattern 3: Repository Sharing**
```dart
// Shared repository pattern
class AppRepositories {
  static final UserRepository userRepository = UserRepository();
  static final TransactionRepository transactionRepository = TransactionRepository();
  static final AnalyticsRepository analyticsRepository = AnalyticsRepository();
}

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(TransactionInitial()) {
    on<AddTransaction>((event, emit) async {
      // Add transaction
      await AppRepositories.transactionRepository.addTransaction(event.transaction);
      
      // Update analytics (side effect)
      AppRepositories.analyticsRepository.trackTransactionAdded(event.transaction);
      
      // Emit success
      emit(TransactionOperationSuccess(/* ... */));
    });
  }
}
```

### Advanced State Management Patterns

#### 🎭 State Transformation Patterns

**Pattern: State History for Undo/Redo**
```dart
class TransactionBlocWithHistory extends Bloc<TransactionEvent, TransactionState> {
  final List<TransactionState> _history = [];
  final List<TransactionState> _future = [];
  int _currentIndex = -1;
  
  @override
  void emit(TransactionState state) {
    // Don't save undo/redo states to history
    if (state is! UndoRedoState) {
      _saveToHistory(this.state);
      _future.clear(); // Clear redo history when new action occurs
    }
    
    super.emit(state);
  }
  
  void _saveToHistory(TransactionState state) {
    if (state is TransactionLoaded) {
      _history.add(state);
      _currentIndex++;
      
      // Limit history size
      if (_history.length > 50) {
        _history.removeAt(0);
        _currentIndex--;
      }
    }
  }
  
  void _onUndo(UndoAction event, Emitter emit) {
    if (_currentIndex > 0) {
      _future.insert(0, state);
      _currentIndex--;
      emit(UndoRedoState(previousState: _history[_currentIndex]));
    }
  }
  
  void _onRedo(RedoAction event, Emitter emit) {
    if (_future.isNotEmpty) {
      _currentIndex++;
      final redoState = _future.removeAt(0);
      emit(UndoRedoState(previousState: redoState));
    }
  }
}

// Special state for undo/redo
class UndoRedoState extends TransactionState {
  final TransactionState previousState;
  
  const UndoRedoState({required this.previousState});
}
```

**Pattern: Optimistic Updates**
```dart
class OptimisticTransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  void _onAddTransactionOptimistic(AddTransaction event, Emitter emit) async {
    if (state is! TransactionLoaded) return;
    final currentState = state as TransactionLoaded;
    
    // Step 1: Immediately update UI (optimistic)
    final optimisticTransaction = Transaction(
      key: DateTime.now().millisecondsSinceEpoch, // Temporary key
      title: event.title,
      value: event.value,
      isExpense: event.isExpense,
      date: DateTime.now(),
    );
    
    final optimisticTransactions = [...currentState.transactions, optimisticTransaction];
    emit(currentState.copyWith(
      transactions: optimisticTransactions,
      isAddingTransaction: true,
    ));
    
    try {
      // Step 2: Actually save to database
      await _transactionService.addTransaction(
        title: event.title,
        value: event.value,
        isExpense: event.isExpense,
      );
      
      // Step 3: Replace with real data
      final realTransactions = await _transactionService.getAllTransactions();
      emit(TransactionLoaded(transactions: realTransactions));
      
    } catch (e) {
      // Step 4: Revert optimistic update on error
      emit(currentState.copyWith(isAddingTransaction: false));
      emit(TransactionError(
        error: ErrorHandler.handleException(e),
        previousTransactions: currentState.transactions, // Original transactions
      ));
    }
  }
}
```

## 🚨 Error Handling Mastery

### Comprehensive Error Architecture

#### 🎯 Error Classification System

```dart
// Hierarchical error system
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  
  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });
  
  @override
  String toString() => 'AppException: $message';
}

// Domain-specific errors
class ValidationException extends AppException {
  final String field;
  final dynamic invalidValue;
  
  const ValidationException({
    required super.message,
    required this.field,
    this.invalidValue,
    super.code,
  });
}

class DatabaseException extends AppException {
  final String operation;
  final String? tableName;
  
  const DatabaseException({
    required super.message,
    required this.operation,
    this.tableName,
    super.originalError,
    super.stackTrace,
  });
}

class NetworkException extends AppException {
  final int? statusCode;
  final String? endpoint;
  
  const NetworkException({
    required super.message,
    this.statusCode,
    this.endpoint,
    super.originalError,
  });
}

class BusinessLogicException extends AppException {
  final String businessRule;
  
  const BusinessLogicException({
    required super.message,
    required this.businessRule,
  });
}
```

#### 🛡️ Error Recovery Strategies

```dart
class ErrorRecoveryService {
  // Strategy 1: Automatic retry with exponential backoff
  static Future<T> retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    Duration delay = initialDelay;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        
        if (attempts >= maxRetries) {
          throw RetryExhaustedException(
            message: 'Operation failed after $maxRetries attempts',
            originalError: e,
          );
        }
        
        // Wait before retry, with exponential backoff
        await Future.delayed(delay);
        delay *= 2; // Double delay each time
      }
    }
    
    throw StateError('Should never reach here');
  }
  
  // Strategy 2: Circuit breaker pattern
  static class CircuitBreaker {
    final int failureThreshold;
    final Duration timeout;
    
    int _failureCount = 0;
    DateTime? _lastFailureTime;
    CircuitBreakerState _state = CircuitBreakerState.closed;
    
    CircuitBreaker({
      this.failureThreshold = 5,
      this.timeout = const Duration(minutes: 1),
    });
    
    Future<T> execute<T>(Future<T> Function() operation) async {
      if (_state == CircuitBreakerState.open) {
        if (_shouldAttemptReset()) {
          _state = CircuitBreakerState.halfOpen;
        } else {
          throw CircuitBreakerOpenException('Circuit breaker is open');
        }
      }
      
      try {
        final result = await operation();
        _onSuccess();
        return result;
      } catch (e) {
        _onFailure();
        rethrow;
      }
    }
    
    bool _shouldAttemptReset() {
      return _lastFailureTime != null &&
             DateTime.now().difference(_lastFailureTime!) > timeout;
    }
    
    void _onSuccess() {
      _failureCount = 0;
      _state = CircuitBreakerState.closed;
    }
    
    void _onFailure() {
      _failureCount++;
      _lastFailureTime = DateTime.now();
      
      if (_failureCount >= failureThreshold) {
        _state = CircuitBreakerState.open;
      }
    }
  }
}

enum CircuitBreakerState { closed, open, halfOpen }
```

#### 📊 Error Analytics and Monitoring

```dart
class ErrorAnalyticsService {
  static final Map<String, ErrorMetrics> _errorMetrics = {};
  
  static void reportError(AppException error, {
    String? userId,
    String? screenName,
    Map<String, dynamic>? context,
  }) {
    // Track error frequency
    final errorKey = '${error.runtimeType}_${error.code ?? 'unknown'}';
    _errorMetrics[errorKey] = (_errorMetrics[errorKey] ?? ErrorMetrics())
        .incrementCount();
    
    // Log error details
    _logError(ErrorReport(
      error: error,
      userId: userId,
      screenName: screenName,
      context: context,
      timestamp: DateTime.now(),
      deviceInfo: _getDeviceInfo(),
    ));
    
    // Send to analytics service (Firebase Crashlytics, Sentry, etc.)
    _sendToAnalytics(error, context);
  }
  
  static ErrorMetrics? getErrorMetrics(String errorType) {
    return _errorMetrics[errorType];
  }
  
  static List<String> getMostFrequentErrors() {
    final sorted = _errorMetrics.entries.toList()
      ..sort((a, b) => b.value.count.compareTo(a.value.count));
    
    return sorted.take(10).map((e) => e.key).toList();
  }
  
  static void _logError(ErrorReport report) {
    print('ERROR REPORT:');
    print('  Type: ${report.error.runtimeType}');
    print('  Message: ${report.error.message}');
    print('  User: ${report.userId ?? 'anonymous'}');
    print('  Screen: ${report.screenName ?? 'unknown'}');
    print('  Time: ${report.timestamp}');
    if (report.context != null) {
      print('  Context: ${report.context}');
    }
  }
  
  static Future<void> _sendToAnalytics(AppException error, Map<String, dynamic>? context) async {
    // Implementation would depend on your analytics service
    // Example: Firebase Crashlytics
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, context);
  }
  
  static Map<String, dynamic> _getDeviceInfo() {
    // Implementation would get device info
    return {
      'platform': 'flutter',
      'version': '1.0.0',
      // Add more device info as needed
    };
  }
}

class ErrorMetrics {
  final int count;
  final DateTime firstSeen;
  final DateTime lastSeen;
  
  const ErrorMetrics({
    this.count = 1,
    DateTime? firstSeen,
    DateTime? lastSeen,
  }) : firstSeen = firstSeen ?? lastSeen ?? DateTime.now(),
       lastSeen = lastSeen ?? DateTime.now();
  
  ErrorMetrics incrementCount() {
    return ErrorMetrics(
      count: count + 1,
      firstSeen: firstSeen,
      lastSeen: DateTime.now(),
    );
  }
}

class ErrorReport {
  final AppException error;
  final String? userId;
  final String? screenName;
  final Map<String, dynamic>? context;
  final DateTime timestamp;
  final Map<String, dynamic> deviceInfo;
  
  const ErrorReport({
    required this.error,
    this.userId,
    this.screenName,
    this.context,
    required this.timestamp,
    required this.deviceInfo,
  });
}
```

## 🧪 Advanced Testing Strategies

### Property-Based Testing

#### 🎲 Testing with Random Data

Instead of testing with fixed examples, property-based testing uses random data to find edge cases:

```dart
// Traditional testing - limited scenarios
test('calculateBalance with fixed data', () {
  final transactions = [
    Transaction(value: 100, isExpense: false),
    Transaction(value: 50, isExpense: true),
  ];
  
  expect(calculateBalance(transactions), equals(50.0));
});

// Property-based testing - thousands of scenarios
import 'package:test/test.dart';
import 'package:faker/faker.dart';

test('calculateBalance properties', () {
  final faker = Faker();
  
  // Test 1000 random scenarios
  for (int i = 0; i < 1000; i++) {
    final transactions = List.generate(
      faker.randomGenerator.integer(20, min: 1), // 1-20 transactions
      (_) => Transaction(
        title: faker.lorem.word(),
        value: faker.randomGenerator.decimal(scale: 10000), // 0-10000
        isExpense: faker.randomGenerator.boolean(),
        date: faker.date.dateTime(),
      ),
    );
    
    final balance = calculateBalance(transactions);
    
    // Property 1: Balance should equal sum of incomes minus expenses
    final expectedBalance = transactions.fold<double>(0.0, (sum, tx) {
      return tx.isExpense ? sum - tx.value : sum + tx.value;
    });
    expect(balance, equals(expectedBalance), 
           reason: 'Failed with transactions: $transactions');
    
    // Property 2: Balance should be finite number
    expect(balance.isFinite, isTrue,
           reason: 'Balance should be finite, got: $balance');
    
    // Property 3: Empty list should have zero balance
    expect(calculateBalance([]), equals(0.0));
    
    // Property 4: Single income should equal balance
    final singleIncome = Transaction(value: 100, isExpense: false);
    expect(calculateBalance([singleIncome]), equals(100.0));
  }
});
```

### Mutation Testing

#### 🧬 Testing Your Tests

Mutation testing changes your code slightly to see if tests catch the changes:

```dart
// Original function
double calculateBalance(List<Transaction> transactions) {
  return transactions.fold<double>(0.0, (sum, transaction) {
    return transaction.isExpense 
        ? sum - transaction.value    // Mutation: change - to +
        : sum + transaction.value;   // Mutation: change + to -
  });
}

// Mutation testing tool would create variations like:
// Mutant 1: return transaction.isExpense ? sum + transaction.value : sum + transaction.value;
// Mutant 2: return transaction.isExpense ? sum - transaction.value : sum - transaction.value;
// Mutant 3: return transactions.fold<double>(1.0, ...); // Change initial value

// Your tests should catch these mutations:
test('mutation testing - expense decreases balance', () {
  final transactions = [Transaction(value: 100, isExpense: true)];
  expect(calculateBalance(transactions), equals(-100.0)); // Would catch mutant 1
});

test('mutation testing - income increases balance', () {
  final transactions = [Transaction(value: 100, isExpense: false)];
  expect(calculateBalance(transactions), equals(100.0)); // Would catch mutant 2
});

test('mutation testing - empty list gives zero', () {
  expect(calculateBalance([]), equals(0.0)); // Would catch mutant 3
});
```

### Integration Testing Patterns

#### 🔄 End-to-End User Journeys

```dart
// Test complete user workflows
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Complete User Journey Tests', () {
    testWidgets('User can complete full transaction lifecycle', (tester) async {
      // Step 1: Launch app
      await tester.pumpWidget(FinanappApplication());
      await tester.pumpAndSettle();
      
      // Step 2: Verify empty state
      expect(find.text('Nenhuma transação ainda'), findsOneWidget);
      
      // Step 3: Add first transaction
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).first, 'Salary');
      await tester.enterText(find.byType(TextFormField).last, '3000.00');
      
      // Select income
      await tester.tap(find.text('Receita'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      
      // Step 4: Verify transaction appears
      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('+'), findsOneWidget);
      expect(find.text('R\$ 3000.00'), findsOneWidget);
      
      // Step 5: Verify balance updated
      expect(find.text('R\$ 3000.00'), findsAtLeastNWidgets(2)); // In list and balance
      
      // Step 6: Add expense
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).first, 'Groceries');
      await tester.enterText(find.byType(TextFormField).last, '150.50');
      
      // Expense is default, so don't change type
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      
      // Step 7: Verify both transactions and updated balance
      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('R\$ 2849.50'), findsOneWidget); // 3000 - 150.50
      
      // Step 8: Test edit functionality
      await tester.longPress(find.text('Groceries'));
      await tester.pumpAndSettle();
      
      // Should navigate to edit screen
      expect(find.text('Editar Transação'), findsOneWidget);
      
      // Change value
      await tester.enterText(find.byType(TextFormField).last, '200.00');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      
      // Step 9: Verify edit reflected in balance
      expect(find.text('R\$ 2800.00'), findsOneWidget); // 3000 - 200
      
      // Step 10: Test delete functionality
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();
      
      // Step 11: Verify transaction deleted and balance updated
      expect(find.text('Groceries'), findsNothing);
      expect(find.text('R\$ 3000.00'), findsOneWidget); // Back to just salary
    });
    
    testWidgets('App handles errors gracefully', (tester) async {
      // Simulate network error, database error, etc.
      // Test that user sees appropriate error messages
      // Test that app doesn't crash
    });
  });
}
```

## ⚡ Performance Deep Dive

### Memory Profiling

#### 🔍 Understanding Memory Usage Patterns

```dart
// Memory-efficient transaction processing
class MemoryEfficientTransactionProcessor {
  // Problem: Loading all transactions into memory at once
  static List<Transaction> processTransactionsBad(List<Transaction> transactions) {
    // ❌ Creates multiple intermediate lists in memory
    final filtered = transactions.where((tx) => tx.date.year == 2024).toList();
    final sorted = filtered.sorted((a, b) => a.date.compareTo(b.date));
    final processed = sorted.map((tx) => _processTransaction(tx)).toList();
    
    return processed; // Multiple lists exist simultaneously
  }
  
  // Solution: Streaming approach
  static Iterable<Transaction> processTransactionsGood(List<Transaction> transactions) {
    // ✅ Lazy evaluation - only one item in memory at a time
    return transactions
        .where((tx) => tx.date.year == 2024)
        .sorted((a, b) => a.date.compareTo(b.date))
        .map((tx) => _processTransaction(tx)); // No intermediate lists
  }
  
  // Better: Async streaming for large datasets
  static Stream<Transaction> processTransactionsStream(List<Transaction> transactions) async* {
    final filtered = transactions.where((tx) => tx.date.year == 2024);
    final sorted = filtered.sorted((a, b) => a.date.compareTo(b.date));
    
    for (final transaction in sorted) {
      yield _processTransaction(transaction);
      
      // Allow other operations to run
      await Future.delayed(Duration.zero);
    }
  }
  
  static Transaction _processTransaction(Transaction tx) {
    // Some processing logic
    return tx;
  }
}
```

#### 🎯 Widget Memory Optimization

```dart
// Memory-efficient widget patterns
class EfficientTransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  
  const EfficientTransactionList({super.key, required this.transactions});
  
  @override
  Widget build(BuildContext context) {
    // ✅ ListView.builder only creates visible items
    return ListView.builder(
      itemCount: transactions.length,
      // Important: Provide itemExtent if all items same height
      itemExtent: 80.0, // Helps Flutter optimize scrolling
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        
        // ✅ Use const constructors when possible
        return TransactionItem(
          key: ValueKey(transaction.key), // ✅ Stable keys for performance
          transaction: transaction,
        );
      },
    );
  }
}

// Memory-efficient item widget
class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  
  const TransactionItem({super.key, required this.transaction});
  
  @override
  Widget build(BuildContext context) {
    // ✅ Extract expensive calculations
    final formattedDate = _formatDate(transaction.date);
    final formattedValue = _formatCurrency(transaction.value);
    
    return Card(
      // ✅ Use const where possible
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.isExpense 
              ? Colors.red.shade100 
              : Colors.green.shade100,
          child: Icon(
            transaction.isExpense ? Icons.remove : Icons.add,
            color: transaction.isExpense ? Colors.red : Colors.green,
          ),
        ),
        title: Text(transaction.title),
        subtitle: Text(formattedDate),
        trailing: Text(
          '${transaction.isExpense ? '-' : '+'} $formattedValue',
          style: TextStyle(
            color: transaction.isExpense ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  // ✅ Static methods don't hold references to widget
  static String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  static String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2)}';
  }
}
```

### Build Performance Optimization

#### 🚀 Widget Rebuilding Analysis

```dart
// Performance monitoring widget
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final String name;
  
  const PerformanceMonitor({
    super.key,
    required this.child,
    required this.name,
  });
  
  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  int _buildCount = 0;
  DateTime? _lastBuild;
  
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeSinceLastBuild = _lastBuild != null 
        ? now.difference(_lastBuild!).inMilliseconds
        : 0;
    
    _buildCount++;
    _lastBuild = now;
    
    // Log rebuilds in debug mode
    debugPrint('🔄 ${widget.name}: Build #$_buildCount (${timeSinceLastBuild}ms since last)');
    
    return widget.child;
  }
}

// Usage in your widgets
class MonitoredTransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PerformanceMonitor(
      name: 'TransactionList',
      child: BlocBuilder<TransactionBloc, TransactionState>(
        buildWhen: (previous, current) {
          // Only rebuild when transactions actually change
          if (previous is TransactionLoaded && current is TransactionLoaded) {
            return previous.transactions != current.transactions;
          }
          return true;
        },
        builder: (context, state) {
          if (state is TransactionLoaded) {
            return ListView.builder(
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                return PerformanceMonitor(
                  name: 'TransactionItem_$index',
                  child: TransactionItem(
                    key: ValueKey(state.transactions[index].key),
                    transaction: state.transactions[index],
                  ),
                );
              },
            );
          }
          return const LoadingWidget();
        },
      ),
    );
  }
}
```

## 🎯 Code Quality & Maintenance

### Automated Code Quality

#### 🤖 Static Analysis Configuration

```yaml
# analysis_options.yaml - Comprehensive linting
include: package:flutter_lints/flutter.yaml

analyzer:
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
  
  errors:
    # Treat warnings as errors in CI
    invalid_assignment: error
    missing_return: error
    dead_code: error
    unused_import: error
    unused_local_variable: error
  
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    # Performance rules
    avoid_function_literals_in_foreach_calls: true
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_const_literals_to_create_immutables: true
    
    # Error prone rules
    avoid_print: true
    avoid_returning_null_for_future: true
    close_sinks: true
    always_use_package_imports: true
    
    # Style rules
    always_declare_return_types: true
    prefer_single_quotes: true
    sort_constructors_first: true