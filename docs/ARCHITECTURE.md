# Architecture Documentation

**Version**: 1.0.0  
**Last Updated**: October 2024

---

## Overview

Finanapp follows **Clean Architecture** principles with clear separation of concerns across three distinct layers.

## Architecture Layers

```
┌──────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                        │
│  ┌────────────┐  ┌────────────┐  ┌────────────────────────┐  │
│  │  Screens   │  │  Widgets   │  │    BLoC (UI State)     │  │
│  └────────────┘  └────────────┘  └────────────────────────┘  │
├──────────────────────────────────────────────────────────────┤
│                   BUSINESS LOGIC LAYER                        │
│  ┌────────────────────┐  ┌──────────────────────────────┐   │
│  │  TradeService      │  │  ErrorHandler                │   │
│  │  (Repository)      │  │  (Error Management)          │   │
│  └────────────────────┘  └──────────────────────────────┘   │
├──────────────────────────────────────────────────────────────┤
│                        DATA LAYER                             │
│  ┌────────────────────┐  ┌──────────────────────────────┐   │
│  │  DatabaseService   │  │  Trade Model                 │   │
│  │  (Hive)            │  │  (Data Entity)               │   │
│  └────────────────────┘  └──────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

## Data Flow

### Read Flow
```
Widget → TradeBloc → TradeService → DatabaseService → Hive
  ↑                      ↓
  └── TradeState ────────┘
```

### Write Flow
```
User Input → Widget → TradeBloc Event
                         ↓
                    TradeService (validates)
                         ↓
                    DatabaseService (persists)
                         ↓
                    Hive (stores)
                         ↓
                    TradeBloc emits new state
                         ↓
                    Widget rebuilds
```

## Layer Responsibilities

### Presentation Layer

**Screens** (`lib/screens/`)
- Display UI structure
- Handle user interactions
- Navigate between screens
- Listen to BLoC state changes

**Widgets** (`lib/widgets/`)
- Reusable UI components
- Display data from props
- Emit callbacks for user actions
- No business logic

**BLoC** (`lib/blocs/`)
- Manage UI state
- Process user events
- Coordinate between UI and services
- Emit state changes

### Business Logic Layer

**Services** (`lib/services/`)
- Implement business rules
- Validate input data
- Transform data for UI
- Coordinate database operations

**Error Handler**
- Centralize error management
- Convert exceptions to user messages
- Provide UI feedback methods

### Data Layer

**Database Service**
- Low-level Hive operations
- Data persistence
- Query execution
- Transaction management

**Models** (`lib/models/`)
- Data structures
- Hive annotations
- Data validation (basic)

## Key Design Decisions

### 1. BLoC Pattern
**Why**: Predictable, testable state management that separates UI from business logic.

**Benefits**:
- Clear separation of concerns
- Easy to test
- Reactive programming model
- Time-travel debugging support

### 2. Hive Database
**Why**: Fast, lightweight, offline-first NoSQL database.

**Benefits**:
- No native dependencies
- Type-safe with code generation
- Works on all Flutter platforms
- Fast read/write operations
- No SQL knowledge required

### 3. Single Responsibility Principle
**Why**: Each class/file has one clear purpose.

**Benefits**:
- Easier to understand
- Simpler to test
- Reduced coupling
- Better maintainability

### 4. Dependency Injection
**Why**: Services passed via constructors for testability.

**Benefits**:
- Easy to mock in tests
- Clear dependencies
- Flexible configuration
- Better testability

### 5. Immutable State
**Why**: State objects are immutable using `copyWith` pattern.

**Benefits**:
- Predictable state changes
- Easy to debug
- Prevents accidental mutations
- Required by BLoC pattern

## Project Structure

```
lib/
├── blocs/                    # State management (BLoC)
│   └── trade/
│       ├── trade_bloc.dart
│       ├── trade_event.dart
│       ├── trade_state.dart
│       └── trade_barrel.dart
├── models/                   # Data entities
│   ├── trade.dart
│   └── trade.g.dart         # Generated
├── screens/                  # Full-page views
│   ├── home_screen.dart
│   └── edit_trade_screen.dart
├── services/                 # Business logic
│   ├── database_service.dart
│   ├── trade_service.dart
│   └── error_handler.dart
├── utils/                    # Helpers & constants
│   └── constants.dart
├── widgets/                  # Reusable components
│   ├── balance/
│   ├── trade/
│   ├── common/
│   └── error/
└── main.dart                 # Entry point
```

## Communication Rules

### Layer Communication

✅ **Allowed**:
- Presentation → Business Logic → Data
- Each layer can only talk to the layer directly below it

❌ **Not Allowed**:
- Widgets directly accessing DatabaseService
- Models knowing about BLoC
- Services importing widgets

### Dependency Direction

```
Presentation (depends on) → Business Logic (depends on) → Data
```

Data layer has no dependencies on other layers.

## State Management Flow

### Event → State Cycle

```
1. User Action (tap button)
2. Widget dispatches Event
3. BLoC receives Event
4. BLoC calls Service method
5. Service validates & processes
6. Service calls Database
7. Database returns result
8. Service returns to BLoC
9. BLoC emits new State
10. Widget rebuilds with new State
```

### Error Flow

```
Exception → Service catches → ErrorHandler converts → AppError
                                                          ↓
BLoC emits TradeError state → Widget shows error UI
```

## Scalability Considerations

### Current Design Supports

- Adding new trade types
- Multiple data sources (future cloud sync)
- Additional features (categories, budgets)
- Internationalization
- Theming

### Future Enhancements

**Could Add**:
- Repository pattern for multiple data sources
- Use cases layer between BLoC and Services
- Dependency injection framework (get_it)
- Feature-based folder structure

**When Needed**:
- App grows beyond 20 screens
- Multiple teams working on codebase
- Complex business rules
- Multiple platforms with different logic

## Performance Considerations

### Optimizations in Place

1. **Const Constructors**: Reduces widget rebuilds
2. **ValueKey**: Optimizes ListView performance
3. **Lazy Loading**: ListView.builder for efficient lists
4. **Equatable**: Prevents unnecessary state emissions
5. **Pure Functions**: Calculations without side effects

### Future Optimizations

- Pagination for large datasets (>1000 trades)
- Caching filtered results
- Lazy database queries
- Background isolates for heavy operations

## Testing Strategy

Each layer is independently testable:

**Presentation**: Widget tests, Golden tests  
**Business Logic**: BLoC tests, Unit tests  
**Data**: Unit tests, Integration tests

See [TESTING_GUIDE.md](TESTING_GUIDE.md) for details.

---

**Next**: [STATE_MANAGEMENT.md](STATE_MANAGEMENT.md) - BLoC patterns and flows