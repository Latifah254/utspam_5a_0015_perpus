import 'book.dart';

enum StatusPeminjaman { aktif, selesai, dibatalkan }

class Transaction {
  final String id;
  final Book book;
  final String namaPeminjam;
  final int lamaPinjam; // dalam hari
  final DateTime tanggalMulai;
  final double totalBiaya;
  StatusPeminjaman status;

  Transaction({
    required this.id,
    required this.book,
    required this.namaPeminjam,
    required this.lamaPinjam,
    required this.tanggalMulai,
    required this.totalBiaya,
    this.status = StatusPeminjaman.aktif,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book': book.toJson(),
      'namaPeminjam': namaPeminjam,
      'lamaPinjam': lamaPinjam,
      'tanggalMulai': tanggalMulai.toIso8601String(),
      'totalBiaya': totalBiaya,
      'status': status.toString().split('.').last,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    StatusPeminjaman status;
    switch (json['status']) {
      case 'aktif':
        status = StatusPeminjaman.aktif;
        break;
      case 'selesai':
        status = StatusPeminjaman.selesai;
        break;
      case 'dibatalkan':
        status = StatusPeminjaman.dibatalkan;
        break;
      default:
        status = StatusPeminjaman.aktif;
    }

    return Transaction(
      id: json['id'],
      book: Book.fromJson(json['book']),
      namaPeminjam: json['namaPeminjam'],
      lamaPinjam: json['lamaPinjam'],
      tanggalMulai: DateTime.parse(json['tanggalMulai']),
      totalBiaya: json['totalBiaya'].toDouble(),
      status: status,
    );
  }
}