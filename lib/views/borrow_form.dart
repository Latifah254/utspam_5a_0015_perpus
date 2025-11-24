// lib/screens/borrow_form_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utspam_5a_0015_perpus/models/book.dart';
import 'package:utspam_5a_0015_perpus/models/transaction.dart';
import 'package:utspam_5a_0015_perpus/models/user.dart';
import 'package:utspam_5a_0015_perpus/controller/perpus_controller.dart';
import 'home.dart';

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

        // Navigasi kembali ke home dengan tab riwayat (index 1)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(initialTabIndex: 1),
          ),
          (route) => false,
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
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF800020)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Form Peminjaman',
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
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.book.genre,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Rp ${widget.book.hargaPinjam.toStringAsFixed(0)}/hari',
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
                      initialValue: _currentUser?.namaLengkap ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Nama Peminjam',
                        labelStyle: TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(color: Color(0xFF800020)),
                      ),
                      enabled: false,
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
                        onPressed: _submitForm,
                        child: const Text(
                          'KONFIRMASI',
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
