part of 'log_bloc.dart';

abstract class LogState {}

class LogInitial extends LogState {}
class LogLoading extends LogState {}
class LogLoaded extends LogState {
  final List<LogModel> logs;
  LogLoaded(this.logs);
}
class LogError extends LogState {
  final String message;
  LogError(this.message);
}