class Product {
  final int id; // 商品ID
  final String name; // 商品名
  final String manufacturer; // メーカー
  final String category; // カテゴリー
  final double price; // 値段
  final String releaseDate; // リリース日
  final String description; // 商品説明
  final int productNumber; // 商品番号

  Product({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.category,
    required this.price,
    required this.releaseDate,
    required this.description,
    required this.productNumber, // 商品番号を追加
  });

  // JSONデータをProductオブジェクトに変換
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'], // 商品IDを取得
      name: json['name'],
      manufacturer: json['manufacturer'],
      category: json['category'],
      price: json['price'].toDouble(),
      releaseDate: json['release_date'],
      description: json['description'] ?? '',
      productNumber: json['product_number'], // 商品番号を取得
    );
  }

  // ProductオブジェクトをJSON形式に変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'manufacturer': manufacturer,
      'category': category,
      'price': price,
      'release_date': releaseDate,
      'description': description,
      'product_number': productNumber, // 商品番号を含める
    };
  }
}
