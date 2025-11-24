// lib/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utspam_a_0015_perpus/models/transaction.dart';
import 'package:utspam_a_0015_perpus/controller/perpus_controller.dart';
import 'detail.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    List<Transaction> transactions = await PerpusController.getAllTransactions();
    setState(() {
      _transactions = transactions.reversed.toList(); // Terbaru di atas
      _isLoading = false;
    });
  }

  // Refresh data ketika kembali dari detail
  void _refreshData() {
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Peminjaman'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada riwayat peminjaman',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    return TransactionCard(
                      transaction: _transactions[index],
                      onTap: () async {
                        // Push dengan Navigator.push agar bisa kembali
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              transaction: _transactions[index],
                            ),
                          ),
                        );
                        // Refresh data setelah kembali
                        _refreshData();
                      },
                    );
                  },
                ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const TransactionCard({
    Key? key,
    required this.transaction,
    required this.onTap,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (transaction.status) {
      case StatusPeminjaman.aktif:
        return Colors.green;
      case StatusPeminjaman.selesai:
        return Colors.blue;
      case StatusPeminjaman.dibatalkan:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (transaction.status) {
      case StatusPeminjaman.aktif:
        return 'Aktif';
      case StatusPeminjaman.selesai:
        return 'Selesai';
      case StatusPeminjaman.dibatalkan:
        return 'Dibatalkan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Cover Buku
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  transaction.book.coverUrl,
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 90,
                      color: Colors.grey[300],
                      child: const Icon(Icons.book),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Info Transaksi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.book.judul,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      transaction.namaPeminjam,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(transaction.tanggalMulai),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(),
                            style: TextStyle(
                              color: _getStatusColor(),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Rp ${transaction.totalBiaya.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}