class FarmPlot {
  final String id;
  final String name;
  final String crop;
  final double area;

  FarmPlot({
    required this.id,
    required this.name,
    required this.crop,
    required this.area,
  });

  factory FarmPlot.fromJson(Map<String, dynamic> json) {
    return FarmPlot(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Untitled',
      crop: json['crop']?.toString() ?? '',
      area: (json['area'] is num)
          ? (json['area'] as num).toDouble()
          : double.tryParse(json['area']?.toString() ?? '') ?? 0.0,
    );
  }
}
