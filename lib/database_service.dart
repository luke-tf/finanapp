// database_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:finanapp/transaction.dart';

class DatabaseService {
  late Box<Transaction> _transactionBox;

  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);
    Hive.registerAdapter(TransactionAdapter());
    _transactionBox = await Hive.openBox<Transaction>('transactions');
  }

  Future<List<Transaction>> getAllTransactions() async {
    return _transactionBox.values.toList();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _transactionBox.add(transaction);
  }

  Future<void> deleteTransaction(int key) async {
    await _transactionBox.delete(key);
  }
}
