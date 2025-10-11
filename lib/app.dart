import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blue_pocket/logic/bloc/category/category_bloc.dart';
import 'package:blue_pocket/logic/bloc/log/log_bloc.dart';
import 'package:blue_pocket/logic/bloc/transaction/transaction_bloc.dart';
import 'package:blue_pocket/presentation/screens/splash_screen.dart';
import 'config/theme.dart';
import 'data/repository/financial_repository.dart';

class BluePocketApp extends StatelessWidget {
  const BluePocketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => FinancialRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => TransactionBloc(
              repository: context.read<FinancialRepository>(),
            )..add(LoadTransactions()),
          ),
          BlocProvider(
            create: (context) => CategoryBloc(
              repository: context.read<FinancialRepository>(),
            )..add(LoadCategories()),
          ),
          BlocProvider(
            create: (context) => LogBloc(
              repository: context.read<FinancialRepository>(),
            )..add(LoadLogs()),
          ),
        ],
        child: MaterialApp(
          title: 'Blue Pocket',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}