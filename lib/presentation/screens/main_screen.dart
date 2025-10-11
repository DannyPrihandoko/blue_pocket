import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:blue_pocket/data/models/transaction_model.dart';
import 'package:blue_pocket/logic/bloc/transaction/transaction_bloc.dart';
import 'package:blue_pocket/presentation/screens/add_transaction_screen.dart';
import 'package:blue_pocket/presentation/screens/profile_screen.dart';
import '../widgets/warning_card.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  Map<String, List<TransactionModel>> _groupTransactionsByMonth(List<TransactionModel> transactions) {
    final Map<String, List<TransactionModel>> data = {};
    for (var trx in transactions) {
      String monthKey = DateFormat('MMMM yyyy', 'id_ID').format(trx.date);
      if (data[monthKey] == null) {
        data[monthKey] = [];
      }
      data[monthKey]!.add(trx);
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pocket'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading || state is TransactionInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TransactionLoaded) {
            final bool isDeficit = state.totalExpense > state.totalIncome;
            final groupedTransactions = _groupTransactionsByMonth(state.transactions);
            final sortedMonths = groupedTransactions.keys.toList();

            return CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                           _buildSummaryCard(context, state, currencyFormatter),
                           if (isDeficit) const WarningCard(),
                           const SizedBox(height: 20),
                           if (state.transactions.isNotEmpty)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Riwayat Transaksi', style: Theme.of(context).textTheme.titleLarge)
                              ),
                        ],
                      ),
                    ),
                  ]),
                ),
                if (state.transactions.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: Text("Belum ada transaksi.")),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final month = sortedMonths[index];
                        final transactionsInMonth = groupedTransactions[month]!;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                                child: Text(
                                  month,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              ...transactionsInMonth.map((trx) => _buildTransactionTile(context, trx, currencyFormatter)),
                            ],
                          ),
                        );
                      },
                      childCount: sortedMonths.length,
                    ),
                  ),
              ],
            );
          }
          return const Center(child: Text('Gagal memuat data'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, TransactionLoaded state, NumberFormat formatter) {
    return Card(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saldo Saat Ini', style: TextStyle(color: Colors.white70, fontSize: 16)),
            Text(
              formatter.format(state.totalIncome - state.totalExpense),
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildIncomeExpense('Pemasukan', formatter.format(state.totalIncome), Icons.arrow_upward, Colors.greenAccent)),
                const SizedBox(width: 16),
                Expanded(child: _buildIncomeExpense('Pengeluaran', formatter.format(state.totalExpense), Icons.arrow_downward, Colors.redAccent)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpense(String title, String amount, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70)),
              Text(
                amount, 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTransactionTile(BuildContext context, TransactionModel trx, NumberFormat formatter) {
    final isIncome = trx.type == TransactionType.income;
    return Dismissible(
      key: Key(trx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete_forever, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Konfirmasi Hapus"),
              content: const Text("Apakah Anda yakin ingin menghapus transaksi ini?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Batal"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        context.read<TransactionBloc>().add(DeleteTransaction(trx.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("'${trx.title}' telah dihapus")),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        child: ListTile(
          leading: Icon(
            isIncome ? Icons.add_circle : Icons.remove_circle,
            color: isIncome ? Colors.green : Colors.red,
          ),
          title: Text(trx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(DateFormat('EEEE, d MMMM', 'id_ID').format(trx.date)),
          trailing: Text(
            formatter.format(trx.amount),
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}