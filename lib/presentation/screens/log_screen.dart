// lib/presentation/screens/log_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:blue_pocket/logic/bloc/log/log_bloc.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Aktivitas'),
      ),
      body: BlocBuilder<LogBloc, LogState>(
        builder: (context, state) {
          if (state is LogLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LogLoaded) {
            if (state.logs.isEmpty) {
              return const Center(child: Text('Belum ada aktivitas tercatat.'));
            }
            return ListView.builder(
              itemCount: state.logs.length,
              itemBuilder: (context, index) {
                final log = state.logs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.history, color: Colors.grey),
                    title: Text(log.action, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.details),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(log.timestamp),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Gagal memuat log.'));
        },
      ),
    );
  }
}