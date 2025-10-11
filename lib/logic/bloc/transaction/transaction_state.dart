part of 'transaction_bloc.dart';

abstract class TransactionState {}
class TransactionInitial extends TransactionState {}
class TransactionLoading extends TransactionState {}
class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  final double totalIncome;
  final double totalExpense;
  TransactionLoaded(this.transactions, this.totalIncome, this.totalExpense);
}
class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);
}