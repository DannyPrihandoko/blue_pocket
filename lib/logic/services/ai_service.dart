import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // Untuk debug print
import '../../data/models/transaction_model.dart';

class AiService {
  // API Key Anda sudah dimasukkan di sini
  static const _apiKey = 'YOUR_GOOGLE_GENERATIVE_AI_API_KEY';

  late final GenerativeModel _model;

  AiService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
    );
  }

  Future<String?> getFinancialAdvice(
      List<TransactionModel> transactions) async {
    // Validasi sederhana jika transaksi kosong
    if (transactions.isEmpty)
      return "Belum ada data transaksi untuk dianalisis.";

    // 1. Pre-processing Data: Ubah List transaksi jadi ringkasan text
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    double totalIncome = 0;
    double totalExpense = 0;
    StringBuffer details = StringBuffer();

    // Mengurutkan transaksi dari yang terbaru
    final sortedTrx = List<TransactionModel>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Ambil maksimal 50 transaksi terakhir agar prompt tidak kepanjangan & hemat token
    final recentTrx = sortedTrx.take(50);

    for (var trx in recentTrx) {
      String typeStr =
          trx.type == TransactionType.income ? "Pemasukan" : "Pengeluaran";
      details.writeln(
          "- $typeStr: ${trx.title} sebesar ${formatter.format(trx.amount)} pada tanggal ${DateFormat('d MMM').format(trx.date)}");

      if (trx.type == TransactionType.income) {
        totalIncome += trx.amount;
      } else {
        totalExpense += trx.amount;
      }
    }

    double balance = totalIncome - totalExpense;

    // 2. Prompt Engineering (Instruksi ke AI)
    final prompt = '''
      Bertindaklah sebagai konsultan keuangan pribadi yang bijak, ramah, dan solutif.
      Bahasa: Bahasa Indonesia.
      
      Berikut adalah ringkasan keuangan saya bulan ini:
      - Total Pemasukan: ${formatter.format(totalIncome)}
      - Total Pengeluaran: ${formatter.format(totalExpense)}
      - Sisa Saldo: ${formatter.format(balance)}
      
      Detail transaksi terakhir:
      ${details.toString()}
      
      Tugasmu:
      1. Berikan analisis singkat tentang kebiasaan belanja saya.
      2. Jika pengeluaran lebih besar dari pemasukan, berikan peringatan keras tapi sopan.
      3. Berikan 3 saran konkret dan bisa dilakukan segera untuk menghemat uang berdasarkan data di atas.
      4. Gunakan format Markdown (bold, bullet points) agar mudah dibaca.
    ''';

    try {
      // Debug print untuk memastikan request terkirim (bisa dilihat di Debug Console)
      if (kDebugMode) {
        print("Mengirim data ke Gemini...");
      }

      // 3. Kirim ke AI
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        return "AI tidak memberikan respon. Silakan coba lagi.";
      }

      return response.text;
    } catch (e) {
      // Menangkap error spesifik
      if (kDebugMode) {
        print("Gemini Error: $e");
      }

      if (e.toString().contains("SocketException") ||
          e.toString().contains("ClientException")) {
        return "Gagal terhubung ke internet. Pastikan koneksi Anda lancar.";
      } else if (e.toString().contains("API key not valid")) {
        return "Kunci API tidak valid. Periksa kembali konfigurasi Anda.";
      }

      return "Maaf, terjadi kesalahan saat menghubungi AI:\n$e";
    }
  }
}
