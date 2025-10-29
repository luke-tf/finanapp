import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanapp/services/database_service.dart';
import 'package:finanapp/blocs/trade/trade_barrel.dart';
import 'package:finanapp/utils/constants.dart';
import 'package:finanapp/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print(AppConstants.bankInitializingMessage);
    await DatabaseService().initialize();
    print(AppConstants.bankSuccessMessage);
    runApp(const FinanappApplication());
  } catch (e, stackTrace) {
    print('ERRO na inicialização: $e');
    print('StackTrace: $stackTrace');
    runApp(ErrorApp(error: e));
  }
}

class FinanappApplication extends StatelessWidget {
  const FinanappApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TradeBloc()..add(const LoadTrades()),
      child: MaterialApp(
        title: AppConstants.appName,
        theme: _buildAppTheme(),
        home: const HomeScreen(),
      ),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final dynamic error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(AppConstants.initErrorMessage),
              const SizedBox(height: 8),
              Text('$error', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}