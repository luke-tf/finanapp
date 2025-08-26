// database_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:finanapp/models/transaction.dart';

class DatabaseService {
  static Box<Transaction>? _transactionBox;
  static bool _isInitialized = false;

  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> initialize() async {
    if (_isInitialized && _transactionBox != null && _transactionBox!.isOpen) {
      return; // Já foi inicializado
    }

    try {
      // Inicializa o Hive com Flutter
      await Hive.initFlutter();

      // Registra o adapter apenas uma vez
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TransactionAdapter());
      }

      // Fecha o box se estiver aberto para reabrir
      if (_transactionBox?.isOpen == true) {
        await _transactionBox!.close();
      }

      // Abre o box
      _transactionBox = await Hive.openBox<Transaction>('transactions');
      _isInitialized = true;

      print('DatabaseService inicializado com sucesso');
    } catch (e) {
      print('Erro ao inicializar DatabaseService: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Box<Transaction> get _box {
    if (!_isInitialized ||
        _transactionBox == null ||
        !_transactionBox!.isOpen) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _transactionBox!;
  }

  Future<List<Transaction>> getAllTransactions() async {
    try {
      final transactions = _box.values.toList();

      // Filtra transações com dados válidos
      return transactions.where((transaction) {
        return transaction.title.isNotEmpty && transaction.value >= 0;
      }).toList();
    } catch (e) {
      print('Erro ao buscar transações: $e');
      return [];
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      // Validações antes de adicionar
      if (transaction.title.isEmpty) {
        throw Exception('Título não pode estar vazio');
      }
      if (transaction.value < 0) {
        throw Exception('Valor não pode ser negativo');
      }

      await _box.add(transaction);
      print('Transação adicionada: ${transaction.title}');
    } catch (e) {
      print('Erro ao adicionar transação: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(int key) async {
    try {
      if (key < 0) {
        throw Exception('Key inválida para deletar');
      }

      await _box.delete(key);
      print('Transação deletada com key: $key');
    } catch (e) {
      print('Erro ao deletar transação: $e');
      rethrow;
    }
  }

  // Método para limpar todos os dados (útil para debug)
  Future<void> clearAllData() async {
    try {
      await _box.clear();
      print('Todos os dados foram limpos');
    } catch (e) {
      print('Erro ao limpar dados: $e');
      rethrow;
    }
  }
}
