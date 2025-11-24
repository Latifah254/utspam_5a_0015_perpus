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
        judul: 'Laskar Pelangi',
        genre: 'Novel',
        hargaPinjam: 5000,
        coverUrl: 'https://images.tokopedia.net/img/cache/700/product-1/2020/8/25/8452952/8452952_8d0f6f5d-c5a1-4a6e-8e3c-9c3e7f5f5e5f_700_700.jpg',
        sinopsis: 'Kisah inspiratif 10 anak dari keluarga miskin di Belitung yang berjuang meraih mimpi.',
      ),
      Book(
        id: '2',
        judul: 'Bumi Manusia',
        genre: 'Sejarah',
        hargaPinjam: 7000,
        coverUrl: 'https://upload.wikimedia.org/wikipedia/id/3/3f/Bumi_Manusia.jpg',
        sinopsis: 'Novel karya Pramoedya Ananta Toer yang menceritakan perjalanan Minke.',
      ),
      Book(
        id: '3',
        judul: 'Harry Potter',
        genre: 'Fantasy',
        hargaPinjam: 10000,
        coverUrl: 'https://m.media-amazon.com/images/I/81YOuOGFCJL.jpg',
        sinopsis: 'Petualangan seorang penyihir muda di Hogwarts School of Witchcraft.',
      ),
      Book(
        id: '4',
        judul: 'Atomic Habits',
        genre: 'Self-Help',
        hargaPinjam: 8000,
        coverUrl: 'https://m.media-amazon.com/images/I/51Tlm0GZTXL.jpg',
        sinopsis: 'Panduan praktis membangun kebiasaan baik dan menghilangkan kebiasaan buruk.',
      ),
      Book(
        id: '5',
        judul: 'Sapiens',
        genre: 'Non-Fiksi',
        hargaPinjam: 9000,
        coverUrl: 'https://m.media-amazon.com/images/I/713jIoMO3UL.jpg',
        sinopsis: 'Sejarah singkat umat manusia dari zaman batu hingga era modern.',
      ),
    ];
  }
}