import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blue_pocket/data/models/log_model.dart';
import 'package:blue_pocket/data/repository/financial_repository.dart';

part 'log_event.dart';
part 'log_state.dart';

class LogBloc extends Bloc<LogEvent, LogState> {
  final FinancialRepository repository;

  LogBloc({required this.repository}) : super(LogInitial()) {
    on<LoadLogs>((event, emit) {
      try {
        emit(LogLoading());
        final logs = repository.getLogs();
        emit(LogLoaded(logs));
      } catch (e) {
        emit(LogError(e.toString()));
      }
    });
  }
}