// lib/screens/edit_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utspam_a_0015_perpus/models/transaction.dart';
import 'package:utspam_a_0015_perpus/controller/perpus_controller.dart';

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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalMulai,
      firstDate: DateTime.now(),
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

      bool success = await PerpusController.updateTransaction(updatedTransaction);

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
      appBar: AppBar(
        title: const Text('Edit Peminjaman'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Detail Buku (readonly)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.transaction.book.coverUrl,
                          width: 80,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 120,
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.transaction.book.genre,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rp ${widget.transaction.book.hargaPinjam.toStringAsFixed(0)}/hari',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Nama Peminjam (editable)
              TextFormField(
                controller: _namaPeminjamController,
                decoration: const InputDecoration(
                  labelText: 'Nama Peminjam',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama peminjam wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Lama Pinjam
              TextFormField(
                controller: _lamaPinjamController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Lama Pinjam (hari)',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan jumlah hari',
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

              // Tanggal Mulai
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Mulai Pinjam',
                    prefixIcon: Icon(Icons.event),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('dd MMMM yyyy').format(_tanggalMulai),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Total Biaya
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Biaya:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rp ${_totalBiaya.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Update
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _updateTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SIMPAN PERUBAHAN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}