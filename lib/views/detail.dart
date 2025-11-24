// lib/screens/detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utspam_a_0015_perpus/models/transaction.dart';
import 'package:utspam_a_0015_perpus/controller/perpus_controller.dart';
import 'edit.dart';

class DetailScreen extends StatefulWidget {
  final Transaction transaction;

  const DetailScreen({Key? key, required this.transaction}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Transaction _transaction;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
  }

  Color _getStatusColor() {
    switch (_transaction.status) {
      case StatusPeminjaman.aktif:
        return Colors.green;
      case StatusPeminjaman.selesai:
        return Colors.blue;
      case StatusPeminjaman.dibatalkan:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (_transaction.status) {
      case StatusPeminjaman.aktif:
        return 'Aktif';
      case StatusPeminjaman.selesai:
        return 'Selesai';
      case StatusPeminjaman.dibatalkan:
        return 'Dibatalkan';
    }
  }

  Future<void> _cancelTransaction() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembatalan'),
        content: const Text('Apakah Anda yakin ingin membatalkan peminjaman ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Update status
              _transaction.status = StatusPeminjaman.dibatalkan;
              bool success = await PerpusController.updateTransaction(_transaction);
              
              if (success) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Peminjaman berhasil dibatalkan'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditScreen(transaction: _transaction),
      ),
    );

    // Jika ada update, refresh data
    if (result != null && result is Transaction) {
      setState(() {
        _transaction = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Peminjaman'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Buku
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey[200],
              child: Image.network(
                _transaction.book.coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.book, size: 100, color: Colors.grey),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Judul Buku
                  Text(
                    _transaction.book.judul,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _transaction.book.genre,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Detail Info Cards
                  _buildInfoCard('Nama Peminjam', _transaction.namaPeminjam, Icons.person),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    'Lama Pinjam',
                    '${_transaction.lamaPinjam} hari',
                    Icons.calendar_today,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    'Tanggal Mulai',
                    DateFormat('dd MMMM yyyy').format(_transaction.tanggalMulai),
                    Icons.event,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    'Tanggal Selesai',
                    DateFormat('dd MMMM yyyy').format(
                      _transaction.tanggalMulai.add(
                        Duration(days: _transaction.lamaPinjam),
                      ),
                    ),
                    Icons.event_available,
                  ),
                  const SizedBox(height: 24),

                  // Total Biaya
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Biaya',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rp ${_transaction.totalBiaya.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Tombol Aksi
                  if (_transaction.status == StatusPeminjaman.aktif) ...[
                    // Tombol Edit
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToEdit,
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          'Edit Peminjaman',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Tombol Batalkan
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _cancelTransaction,
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text(
                          'Batalkan Peminjaman',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}