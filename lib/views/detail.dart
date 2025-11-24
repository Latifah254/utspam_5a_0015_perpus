// lib/screens/detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utspam_5a_0015_perpus/models/transaction.dart';
import 'package:utspam_5a_0015_perpus/controller/perpus_controller.dart';
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
        return const Color(0xFF2E7D32);
      case StatusPeminjaman.selesai:
        return const Color(0xFF1976D2);
      case StatusPeminjaman.dibatalkan:
        return const Color(0xFFC62828);
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
        content: const Text(
          'Apakah Anda yakin ingin membatalkan peminjaman ini?',
        ),
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
              bool success = await PerpusController.updateTransaction(
                _transaction,
              );

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
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(color: Colors.white),
            ),
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Detail Peminjaman',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF800020),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[200],
              child: Image.asset(
                _transaction.book.coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.book, size: 80, color: Colors.grey),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _transaction.book.judul,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _transaction.book.genre,
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    'Nama Peminjam',
                    _transaction.namaPeminjam,
                    Icons.person_outline,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    'Lama Pinjam',
                    '${_transaction.lamaPinjam} hari',
                    Icons.calendar_today_outlined,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    'Tanggal Mulai',
                    DateFormat(
                      'dd MMMM yyyy',
                    ).format(_transaction.tanggalMulai),
                    Icons.event_outlined,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    'Tanggal Selesai',
                    DateFormat('dd MMMM yyyy').format(
                      _transaction.tanggalMulai.add(
                        Duration(days: _transaction.lamaPinjam),
                      ),
                    ),
                    Icons.event_available_outlined,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF800020).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Biaya',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                        Text(
                          'Rp ${_transaction.totalBiaya.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF800020),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_transaction.status == StatusPeminjaman.aktif) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _navigateToEdit,
                        child: const Text(
                          'EDIT PEMINJAMAN',
                          style: TextStyle(letterSpacing: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _cancelTransaction,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFC62828)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'BATALKAN',
                          style: TextStyle(
                            color: Color(0xFFC62828),
                            letterSpacing: 1,
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF800020), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C2C2C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
