# UI Components Documentation

**Screens & Widgets Catalog**

---

## Screens

### HomeScreen

**Location**: `lib/screens/home_screen.dart`

**Purpose**: Main application dashboard

**Components**:
- AppBar with title and refresh button
- BalanceDisplay (piggy bank + balance card)
- TradeList or EmptyTradesWidget
- FloatingActionButton (add trade)

**State Handling**:
```dart
TradeLoading → LoadingWidget
TradeError → ErrorDisplayWidget
TradeLoaded + empty → EmptyTradesWidget
TradeLoaded + data → BalanceDisplay + TradeList
```

**User Actions**:
| Action | Result |
|--------|--------|
| Tap FAB | Opens NewTradeForm modal |
| Long-press trade | Opens EditTradeScreen |
| Tap delete icon | Shows confirmation dialog |
| Pull down | Triggers RefreshTrades event |
| Tap refresh button | Triggers RefreshTrades event |

**Code Example**:
```dart
// Dispatch events
context.read<TradeBloc>().add(const RefreshTrades());

// Navigate to edit
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (ctx) => BlocProvider.value(
      value: context.read<TradeBloc>(),
      child: EditTradeScreen(trade: trade),
    ),
  ),
);
```

### EditTradeScreen

**Location**: `lib/screens/edit_trade_screen.dart`

**Purpose**: Edit existing trade

**Props**:
```dart
final Trade trade;  // Required - trade to edit
```

**Features**:
- Pre-populated form fields
- Real-time validation
- Disable form during save
- Loading indicator
- Auto-pop on success

**Workflow**:
1. Receive Trade via constructor
2. User modifies fields
3. On save: validate → update Trade properties → dispatch UpdateTrade
4. Listen for success/error
5. Pop screen on success

**Form Fields**:
- Title (TextFormField)
- Value (TextFormField with number keyboard)
- Type selector (Expense/Income toggle)
- Date (currently not editable, but stored)

**Validation**:
- Title: 1-100 chars, required
- Value: > 0, <= 999,999,999.99, required
- Shows inline errors

---

## Widgets

### Balance Widgets

#### BalanceDisplay

**Location**: `lib/widgets/balance/balance_display.dart`

**Purpose**: Combines image and card

**Props**:
```dart
final double currentBalance;
final Function getBalanceImagePath;
```

**Layout**:
```
┌─────────────────────┐
│   Piggy Bank Image  │
│                     │
├─────────────────────┤
│   Balance Card      │
│   Saldo Atual       │
│   R$ XXX.XX         │
└─────────────────────┘
```

#### BalanceImage

**Location**: `lib/widgets/balance/balance_image.dart`

**Props**:
```dart
final String imagePath;
```

**Features**:
- Responsive height (20% of screen)
- Contains fit for proper scaling
- Shows happy/neutral/sad pig

#### BalanceCard

**Location**: `lib/widgets/balance/balance_card.dart`

**Props**:
```dart
final double balance;
```

**Features**:
- Blue card background
- White text
- Currency formatting (R$ XXX.XX)
- Responsive padding

---

### Trade Widgets

#### NewTradeForm

**Location**: `lib/widgets/trade/new_trade_form.dart`

**Purpose**: Modal bottom sheet for adding trades

**Features**:
- Auto-focus on title field
- Character counter (0/100)
- Real-time validation
- Radio buttons for type selection
- Clear/Cancel/Save buttons
- Shows current balance hint
- Keyboard-aware (adjusts for keyboard)

**Form Structure**:
```
┌─────────────────────────────────────┐
│ Nova Transação                  [X] │
├─────────────────────────────────────┤
│ Título *                            │
│ [Input field]                       │
│                                     │
│ Valor (R$) *                        │
│ [Input field]                       │
│                                     │
│ Tipo de transação:                  │
│ [ Despesa ]  [ Receita ]           │
│                                     │
│ [Limpar] [Cancelar] [Salvar]       │
└─────────────────────────────────────┘
```

**State Management**:
- Local state for form fields
- BlocConsumer for submit handling
- Disables form during save

**Validation**:
- Title: Not empty, max 100 chars
- Value: > 0, <= 999,999,999.99
- Shows validation errors inline

#### TradeList

**Location**: `lib/widgets/trade/trade_list.dart`

**Props**:
```dart
final List<Trade> trades;
final Function(int) deleteTx;
final Function(int) editTx;
```

**Implementation**:
```dart
ListView.builder(
  itemCount: trades.length,
  itemBuilder: (context, index) {
    final trade = trades[index];
    return TradeItem(
      key: ValueKey(trade.key),
      ...
    );
  },
)
```

**Performance**:
- Uses ValueKey for optimal rebuilds
- ListView.builder for lazy loading

#### TradeItem

**Location**: `lib/widgets/trade/trade_item.dart`

**Props**:
```dart
final int id;             // Trade key
final String title;
final double value;
final DateTime date;
final bool isExpense;
final Function(int) deleteTx;
final Function(int) editTx;
```

**Layout**:
```
┌──────────────────────────────────────────────┐
│ [●] Coffee Shop                  -R$ 5.50 [🗑] │
│     28/10/2024                                │
└──────────────────────────────────────────────┘
```

**Features**:
- Colored indicator (red=expense, green=income)
- Formatted date (dd/MM/yyyy)
- Formatted value with sign
- Delete button (shows confirmation)
- Long-press to edit
- Card elevation for depth

**User Actions**:
| Action | Result |
|--------|--------|
| Tap | Nothing (could add navigation) |
| Long-press | Opens EditTradeScreen |
| Tap delete icon | Shows confirmation dialog |

#### EmptyTradesWidget

**Location**: `lib/widgets/trade/empty_trades_widget.dart`

**Props**:
```dart
final VoidCallback onAddTrade;
```

**Purpose**: Shown when no trades exist

**Layout**:
```
┌─────────────────────────────────┐
│                                 │
│         [Large Icon]            │
│                                 │
│   Nenhuma transação ainda       │
│   Comece adicionando sua        │
│   primeira transação            │
│                                 │
│   [Primeira Transação]          │
│                                 │
└─────────────────────────────────┘
```

**Features**:
- Responsive icon size
- Centered layout
- Call-to-action button
- Grey color scheme

---

### Common Widgets

#### LoadingWidget

**Location**: `lib/widgets/common/loading_widget.dart`

**Props**:
```dart
final String? message;  // Optional custom message
```

**Layout**:
```
┌─────────────────┐
│                 │
│   [Spinner]     │
│   Carregando... │
│                 │
└─────────────────┘
```

**Usage**:
```dart
if (state is TradeLoading) {
  return const LoadingWidget();
}
```

---

### Error Widgets

#### ErrorDisplayWidget

**Location**: `lib/widgets/error/error_display_widget.dart`

**Props**:
```dart
final AppError error;
final VoidCallback onRetry;
```

**Layout**:
```
┌───────────────────────────────┐
│        [Error Icon]           │
│                               │
│   Ops! Algo deu errado        │
│   [Error message]             │
│                               │
│ [Tentar Novamente] [Detalhes] │
└───────────────────────────────┘
```

**Features**:
- Icon colored by error type
- User-friendly message
- Retry button
- Details button (opens dialog)
- Handles all ErrorTypes

---

## Widget Best Practices

### Construction

✅ **Use const constructors**:
```dart
const LoadingWidget()
const EmptyTradesWidget(onAddTrade: _showForm)
```

✅ **Key parameter first**:
```dart
const TradeItem({
  super.key,
  required this.id,
  required this.title,
})
```

### Extraction

✅ **Extract complex widgets**:
```dart
// Bad - huge build method
Widget build(BuildContext context) {
  return Column(
    children: [
      // 100 lines of widget code
    ],
  );
}

// Good - extracted widgets
Widget build(BuildContext context) {
  return Column(
    children: [
      _buildHeader(),
      _buildContent(),
      _buildFooter(),
    ],
  );
}
```

### State Access

✅ **Read BLoC properly**:
```dart
// Reading state
context.read<TradeBloc>()

// Watching for changes
context.watch<TradeBloc>()

// Selecting specific data
context.select((TradeBloc bloc) => bloc.state.trades)
```

### Responsiveness

✅ **Use MediaQuery**:
```dart
final width = MediaQuery.of(context).size.width;
final padding = width > 600 ? 24.0 : 16.0;
```

✅ **Use responsive helpers**:
```dart
AppConstants.getResponsivePadding(context)
AppConstants.getResponsiveIconSize(context)
```

---

## Common Patterns

### Modal Bottom Sheet

```dart
void _showForm() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (ctx) => BlocProvider.value(
      value: context.read<TradeBloc>(),
      child: const NewTradeForm(),
    ),
  );
}
```

### Confirmation Dialog

```dart
void _showDeleteDialog(int tradeId) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Confirmar exclusão'),
      content: Text('Deseja excluir esta transação?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            context.read<TradeBloc>().add(
              DeleteTrade(key: tradeId),
            );
          },
          child: Text('Excluir'),
        ),
      ],
    ),
  );
}
```

### Navigation with BLoC

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (ctx) => BlocProvider.value(
      value: context.read<TradeBloc>(),
      child: EditTradeScreen(trade: trade),
    ),
  ),
);
```

### Pull to Refresh

```dart
RefreshIndicator(
  onRefresh: () async {
    context.read<TradeBloc>().add(const RefreshTrades());
  },
  child: ListView(...),
)
```

---

## Theming

### Current Theme

Defined in `main.dart`:

```dart
ThemeData(
  primarySwatch: Colors.blue,
  useMaterial3: true,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.blueAccent,
    foregroundColor: Colors.white,
  ),
)
```

### Color Usage

| Element | Color |
|---------|-------|
| Primary | Blue Accent |
| Expense | Red / Red Accent |
| Income | Green |
| Background | Grey.shade50 |
| Cards | White |
| Error | Red |
| Warning | Orange |
| Success | Green |

---

**Next**: [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) - Workflow and conventions