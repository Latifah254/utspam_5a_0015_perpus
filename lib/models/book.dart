// lib/models/book.dart

class Book {
  final String id;
  final String judul;
  final String genre;
  final double hargaPinjam; // harga per hari
  final String coverUrl;
  final String sinopsis;

  Book({
    required this.id,
    required this.judul,
    required this.genre,
    required this.hargaPinjam,
    required this.coverUrl,
    required this.sinopsis,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'genre': genre,
      'hargaPinjam': hargaPinjam,
      'coverUrl': coverUrl,
      'sinopsis': sinopsis,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      judul: json['judul'],
      genre: json['genre'],
      hargaPinjam: json['hargaPinjam'].toDouble(),
      coverUrl: json['coverUrl'],
      sinopsis: json['sinopsis'],
    );
  }

  // Data dummy untuk buku-buku
  static List<Book> getDummyBooks() {
    return [
      Book(
        id: '1',
        judul: 'Kalkulus dan Geometri Analitik',
        genre: 'Matematika',
        hargaPinjam: 5000,
        coverUrl: 'lib/assets/Kalkulus dan Geometri Analitik.jpg',
        sinopsis:
            'Buku teks komprehensif tentang kalkulus diferensial, integral, dan geometri analitik.',
      ),
      Book(
        id: '2',
        judul: 'Aljabar Linear Elementer',
        genre: 'Matematika',
        hargaPinjam: 7000,
        coverUrl: 'lib/assets/Aljabar Linear Elementer.png',
        sinopsis:
            'Pengantar aljabar linear mencakup matriks, vektor, dan transformasi linear.',
      ),
      Book(
        id: '3',
        judul: 'Matematika Diskrit',
        genre: 'Matematika',
        hargaPinjam: 10000,
        coverUrl: 'lib/assets/Matematika Diskrit.jpg',
        sinopsis:
            'Pembahasan lengkap tentang logika, himpunan, graf, dan teori bilangan.',
      ),
      Book(
        id: '4',
        judul: 'Statistika dan Probabilitas',
        genre: 'Matematika',
        hargaPinjam: 8000,
        coverUrl: 'lib/assets/Statistika dan Probabilitas.jpg',
        sinopsis:
            'Panduan praktis memahami konsep statistika deskriptif dan inferensial.',
      ),
      Book(
        id: '5',
        judul: 'Persamaan Diferensial',
        genre: 'Matematika',
        hargaPinjam: 9000,
        coverUrl: 'lib/assets/Persamaan Diferensial.jpg',
        sinopsis:
            'Metode penyelesaian persamaan diferensial biasa dan parsial.',
      ),
    ];
  }
}
