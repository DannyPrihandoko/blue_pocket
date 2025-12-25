// lib/presentation/screens/financial_analysis_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Wajib install package ini
import '../../data/models/transaction_model.dart';
import '../../logic/services/ai_service.dart'; // Pastikan path ini sesuai dengan file AiService Anda

class FinancialAnalysisScreen extends StatelessWidget {
  final List<TransactionModel> transactions;

  const FinancialAnalysisScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analisis Cerdas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<String?>(
        // Memanggil fungsi AI segera setelah halaman dibangun
        future: AiService().getFinancialAdvice(transactions),
        builder: (context, snapshot) {
          // 1. Tampilan saat Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    "AI sedang menganalisis data keuanganmu...",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            );
          }

          // 2. Tampilan jika Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Terjadi kesalahan: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          // 3. Tampilan Hasil (Sukses)
          final result = snapshot.data ??
              "Tidak ada analisis yang dapat diberikan saat ini.";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header opsional
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Berikut adalah saran pengelolaan keuangan berdasarkan riwayat transaksimu.",
                          style: TextStyle(color: Colors.blue.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Widget Markdown untuk merender teks hasil AI
                MarkdownBody(
                  data: result,
                  styleSheet: MarkdownStyleSheet(
                    h1: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                    h2: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                    p: const TextStyle(
                        fontSize: 16, height: 1.5, color: Colors.black87),
                    listBullet: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
