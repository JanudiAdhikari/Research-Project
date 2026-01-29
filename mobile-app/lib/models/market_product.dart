class MarketProduct {
  final String id;
  final String name;
  final double price;
  final String unit;
  final String? imageUrl;

  MarketProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    this.imageUrl,
  });

  factory MarketProduct.fromJson(Map<String, dynamic> json) {
    return MarketProduct(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Product',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      unit: json['unit']?.toString() ?? '',
      imageUrl:
          json['imageUrl']?.toString() ??
          json['image']?.toString() ??
          json['image_url']?.toString(),
    );
  }
}
