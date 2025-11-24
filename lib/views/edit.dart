// lib/screens/edit_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utspam_5a_0015_perpus/models/transaction.dart';
import 'package:utspam_5a_0015_perpus/controller/perpus_controller.dart';

class EditScreen extends StatefulWidget {
  final Transaction transaction;

  const EditScreen({Key? key, required this.transaction}) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lamaPinjamController = TextEditingController();
  final _namaPeminjamController = TextEditingController();

  late DateTime _tanggalMulai;
  double _totalBiaya = 0;

  @override
  void initState() {
    super.initState();
    // Load data dari transaction
    _namaPeminjamController.text = widget.transaction.namaPeminjam;
    _lamaPinjamController.text = widget.transaction.lamaPinjam.toString();
    _tanggalMulai = widget.transaction.tanggalMulai;
    _totalBiaya = widget.transaction.totalBiaya;

    _lamaPinjamController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _lamaPinjamController.dispose();
    _namaPeminjamController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    if (_lamaPinjamController.text.isNotEmpty) {
      int lamaPinjam = int.tryParse(_lamaPinjamController.text) ?? 0;
      setState(() {
        _totalBiaya = widget.transaction.book.hargaPinjam * lamaPinjam;
      });
    } else {
      setState(() {
        _totalBiaya = 0;
      });
    }
  }

  Future<void> _selectDate() async {
    // Allow selecting from the original date or today, whichever is earlier
    DateTime minDate = widget.transaction.tanggalMulai.isBefore(DateTime.now())
        ? widget.transaction.tanggalMulai
        : DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalMulai,
      firstDate: minDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _tanggalMulai) {
      setState(() {
        _tanggalMulai = picked;
      });
    }
  }

  Future<void> _updateTransaction() async {
    if (_formKey.currentState!.validate()) {
      // Update transaction object
      Transaction updatedTransaction = Transaction(
        id: widget.transaction.id,
        book: widget.transaction.book,
        namaPeminjam: _namaPeminjamController.text,
        lamaPinjam: int.parse(_lamaPinjamController.text),
        tanggalMulai: _tanggalMulai,
        totalBiaya: _totalBiaya,
        status: widget.transaction.status,
      );

      bool success = await PerpusController.updateTransaction(
        updatedTransaction,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peminjaman berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );

        // Kembali ke detail dengan data terbaru
        Navigator.pop(context, updatedTransaction);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Update gagal. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Edit Peminjaman',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF800020),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      widget.transaction.book.coverUrl,
                      width: 70,
                      height: 105,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 70,
                          height: 105,
                          color: Colors.grey[300],
                          child: const Icon(Icons.book),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.transaction.book.judul,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.transaction.book.genre,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Rp ${widget.transaction.book.hargaPinjam.toStringAsFixed(0)}/hari',
                          style: const TextStyle(
                            color: Color(0xFF800020),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _namaPeminjamController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Peminjam',
                        labelStyle: TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(color: Color(0xFF800020)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama peminjam wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lamaPinjamController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Lama Pinjam (hari)',
                        labelStyle: TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(color: Color(0xFF800020)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lama pinjam wajib diisi';
                        }
                        int? days = int.tryParse(value);
                        if (days == null || days <= 0) {
                          return 'Lama pinjam harus berupa angka positif';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Mulai',
                          labelStyle: TextStyle(color: Colors.grey),
                          floatingLabelStyle: TextStyle(
                            color: Color(0xFF800020),
                          ),
                        ),
                        child: Text(
                          DateFormat('dd MMMM yyyy').format(_tanggalMulai),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
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
                              fontSize: 16,
                              color: Color(0xFF2C2C2C),
                            ),
                          ),
                          Text(
                            'Rp ${_totalBiaya.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF800020),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateTransaction,
                        child: const Text(
                          'SIMPAN PERUBAHAN',
                          style: TextStyle(letterSpacing: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
