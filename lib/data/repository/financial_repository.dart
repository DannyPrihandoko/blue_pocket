import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/category_model.dart';
import '../models/log_model.dart';
import '../models/transaction_model.dart';

class FinancialRepository {
  final Box<TransactionModel> _transactionBox = Hive.box<TransactionModel>('transactions');
  final Box<CategoryModel> _categoryBox = Hive.box<CategoryModel>('categories');
  final Box<LogModel> _logBox = Hive.box<LogModel>('logs');

  List<TransactionModel> getTransactions() {
    return _transactionBox.values.toList();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    final transactionToDelete = _transactionBox.get(id);

    if (transactionToDelete != null) {
      final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
      final logDetail = "Transaksi '${transactionToDelete.title}' sejumlah ${currencyFormatter.format(transactionToDelete.amount)} telah dihapus.";
      
      final newLog = LogModel(
        id: const Uuid().v4(),
        action: "HAPUS TRANSAKSI",
        details: logDetail,
        timestamp: DateTime.now(),
      );
      await _logBox.put(newLog.id, newLog);
      await _transactionBox.delete(id);
    }
  }

  List<CategoryModel> getCategories() {
    return _categoryBox.values.toList();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _categoryBox.put(category.id, category);
  }

  Future<void> deleteCategory(String id) async {
    await _categoryBox.delete(id);
  }

  List<LogModel> getLogs() {
    final logs = _logBox.values.toList();
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }
}