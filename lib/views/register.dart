// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:utspam_5a_0015_perpus/controller/perpus_controller.dart';
import 'package:utspam_5a_0015_perpus/models/user.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _emailController = TextEditingController();
  final _alamatController = TextEditingController();
  final _telpController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    _telpController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validasi email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email wajib diisi';
    }
    if (!value.endsWith('@gmail.com')) {
      return 'Email harus berformat @gmail.com';
    }
    return null;
  }

  // Validasi nomor telepon
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon wajib diisi';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Nomor telepon harus berupa angka';
    }
    return null;
  }

  // Validasi password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  // Validasi field wajib
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  // Proses registrasi
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      User newUser = User(
        namaLengkap: _namaController.text,
        nik: _nikController.text,
        email: _emailController.text,
        alamat: _alamatController.text,
        nomorTelepon: _telpController.text,
        username: _usernameController.text,
        password: _passwordController.text,
      );

      bool success = await PerpusController.saveUser(newUser);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil! Silakan login.'),
            backgroundColor: Colors.green,
          ),
        );

        // Pindah ke halaman login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email, Username, atau NIK sudah digunakan!'),
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
        title: const Text('Daftar Akun', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF800020),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF800020)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        labelStyle: TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(color: Color(0xFF800020)),
                      ),
                      validator: (value) =>
                          _validateRequired(value, 'Nama lengkap'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nikController,
                      decoration: const InputDecoration(
                        labelText: 'NIK',
                        labelStyle: TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(color: Color(0xFF800020)),
                      ),
                      validator: (value) => _validateRequired(value, 'NIK'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(color: Color(0xFF800020)),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _alamatController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Alamat',
                        labelStyle: TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(color: Color(0xFF800020)),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) => _validateRequired(value, 'Alamat'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telpController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                        labelStyle: TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(color: Color(0xFF800020)),
                      ),
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(color: Color(0xFF800020)),
                      ),
                      validator: (value) =>
                          _validateRequired(value, 'Username'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(color: Color(0xFF800020)),
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _register,
                      child: const Text(
                        'DAFTAR',
                        style: TextStyle(letterSpacing: 1),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sudah punya akun? Login',
                          style: TextStyle(color: Color(0xFF800020)),
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
