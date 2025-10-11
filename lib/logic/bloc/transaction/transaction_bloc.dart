import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blue_pocket/data/models/transaction_model.dart';
import 'package:blue_pocket/data/repository/financial_repository.dart';
part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final FinancialRepository repository;

  TransactionBloc({required this.repository}) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  void _onLoadTransactions(LoadTransactions event, Emitter<TransactionState> emit) {
    try {
      emit(TransactionLoading());
      final transactions = repository.getTransactions();
      _calculateAndEmitTotals(transactions, emit);
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  void _onAddTransaction(AddTransaction event, Emitter<TransactionState> emit) async {
    try {
      await repository.addTransaction(event.transaction);
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  void _onDeleteTransaction(DeleteTransaction event, Emitter<TransactionState> emit) async {
     try {
      await repository.deleteTransaction(event.transactionId);
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
  
  void _calculateAndEmitTotals(List<TransactionModel> transactions, Emitter<TransactionState> emit) {
    double income = 0;
    double expense = 0;
    for (var trx in transactions) {
      if (trx.type == TransactionType.income) {
        income += trx.amount;
      } else {
        expense += trx.amount;
      }
    }
    transactions.sort((a, b) => b.date.compareTo(a.date));
    emit(TransactionLoaded(transactions, income, expense));
  }
}