// lib/controller/storage_controller.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/transaction.dart';

class PerpusController {
  static const String _usersKey = 'users';
  static const String _transactionsKey = 'transactions';
  static const String _currentUserKey = 'current_user';

  // Simpan user baru (registrasi)
  static Future<bool> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Ambil list user yang sudah ada
      List<User> users = await getAllUsers();
      
      // Cek apakah email atau username sudah ada
      bool emailExists = users.any((u) => u.email == user.email);
      bool usernameExists = users.any((u) => u.username == user.username);
      
      if (emailExists || usernameExists) {
        return false; // Email atau username sudah digunakan
      }
      
      // Tambah user baru
      users.add(user);
      
      // Convert ke JSON dan simpan
      List<String> usersJson = users.map((u) => jsonEncode(u.toJson())).toList();
      await prefs.setStringList(_usersKey, usersJson);
      
      return true;
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }

  // Ambil semua user
  static Future<List<User>> getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String>? usersJson = prefs.getStringList(_usersKey);
      
      if (usersJson == null) return [];
      
      return usersJson.map((json) => User.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  // Login - validasi user
  static Future<User?> login(String emailOrNik, String password) async {
    try {
      List<User> users = await getAllUsers();
      
      // Cari user berdasarkan email/NIK dan password
      User? user = users.firstWhere(
        (u) => (u.email == emailOrNik || u.nik == emailOrNik) && u.password == password,
        orElse: () => User(
          namaLengkap: '',
          nik: '',
          email: '',
          alamat: '',
          nomorTelepon: '',
          username: '',
          password: '',
        ),
      );
      
      if (user.email.isEmpty) return null;
      
      // Simpan current user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
      
      return user;
    } catch (e) {
      print('Error login: $e');
      return null;
    }
  }

  // Ambil current user yang login
  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userJson = prefs.getString(_currentUserKey);
      
      if (userJson == null) return null;
      
      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Simpan transaksi
  static Future<bool> saveTransaction(Transaction transaction) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Ambil list transaksi yang sudah ada
      List<Transaction> transactions = await getAllTransactions();
      
      // Tambah transaksi baru
      transactions.add(transaction);
      
      // Convert ke JSON dan simpan
      List<String> transactionsJson = transactions.map((t) => jsonEncode(t.toJson())).toList();
      await prefs.setStringList(_transactionsKey, transactionsJson);
      
      return true;
    } catch (e) {
      print('Error saving transaction: $e');
      return false;
    }
  }

  // Ambil semua transaksi
  static Future<List<Transaction>> getAllTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String>? transactionsJson = prefs.getStringList(_transactionsKey);
      
      if (transactionsJson == null) return [];
      
      return transactionsJson.map((json) => Transaction.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  // Update transaksi
  static Future<bool> updateTransaction(Transaction updatedTransaction) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Ambil semua transaksi
      List<Transaction> transactions = await getAllTransactions();
      
      // Cari index transaksi yang akan diupdate
      int index = transactions.indexWhere((t) => t.id == updatedTransaction.id);
      
      if (index == -1) return false;
      
      // Update transaksi
      transactions[index] = updatedTransaction;
      
      // Simpan kembali
      List<String> transactionsJson = transactions.map((t) => jsonEncode(t.toJson())).toList();
      await prefs.setStringList(_transactionsKey, transactionsJson);
      
      return true;
    } catch (e) {
      print('Error updating transaction: $e');
      return false;
    }
  }
}