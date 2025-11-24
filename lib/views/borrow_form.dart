// lib/screens/borrow_form_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utspam_a_0015_perpus/models/book.dart';
import 'package:utspam_a_0015_perpus/models/transaction.dart';
import 'package:utspam_a_0015_perpus/models/user.dart';
import 'package:utspam_a_0015_perpus/controller/perpus_controller.dart';
import 'history.dart';

class BorrowFormScreen extends StatefulWidget {
  final Book book;

  const BorrowFormScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<BorrowFormScreen> createState() => _BorrowFormScreenState();
}

class _BorrowFormScreenState extends State<BorrowFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lamaPinjamController = TextEditingController();
  
  DateTime _tanggalMulai = DateTime.now();
  double _totalBiaya = 0;
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _lamaPinjamController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _lamaPinjamController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    User? user = await PerpusController.getCurrentUser();
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  void _calculateTotal() {
    if (_lamaPinjamController.text.isNotEmpty) {
      int lamaPinjam = int.tryParse(_lamaPinjamController.text) ?? 0;
      setState(() {
        _totalBiaya = widget.book.hargaPinjam * lamaPinjam;
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Buat transaksi baru
      Transaction newTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        book: widget.book,
        namaPeminjam: _currentUser?.namaLengkap ?? '',
        lamaPinjam: int.parse(_lamaPinjamController.text),
        tanggalMulai: _tanggalMulai,
        totalBiaya: _totalBiaya,
        status: StatusPeminjaman.aktif,
      );

      bool success = await PerpusController.saveTransaction(newTransaction);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peminjaman berhasil!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigasi ke halaman riwayat dengan pushReplacement
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HistoryScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peminjaman gagal. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Peminjaman'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Detail Buku
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.book.coverUrl,
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
                              widget.book.judul,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.book.genre,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rp ${widget.book.hargaPinjam.toStringAsFixed(0)}/hari',
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

              // Nama Peminjam (readonly)
              TextFormField(
                initialValue: _currentUser?.namaLengkap ?? '',
                decoration: const InputDecoration(
                  labelText: 'Nama Peminjam',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                enabled: false,
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

              // Tombol Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'KONFIRMASI PEMINJAMAN',
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