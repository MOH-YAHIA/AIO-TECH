class ProductAnalysisModel {
  final int id;
  final String name;
  final String? category;
  final String? brand;
  final String? description;
  final String? sentimentSummary;
  final String pros;
  final String cons;
  final double currentPriceEgp;
  final String? imageUrl;
  final double? globalRating;
  final String? globalUsdPrice;
  final DateTime? lastAiUpdate;
  final DateTime savedAt;

  ProductAnalysisModel({
    required this.id,
    required this.name,
    this.category,
    this.brand,
    this.description,
    this.sentimentSummary,
    required this.pros,
    required this.cons,
    required this.currentPriceEgp,
    this.imageUrl,
    this.globalRating,
    this.globalUsdPrice,
    this.lastAiUpdate,
    required this.savedAt,
  });

  factory ProductAnalysisModel.fromJson(Map<String, dynamic> json) {
    return ProductAnalysisModel(
      id:               json['id'],
      name:             json['name'],
      category:         json['category'],
      brand:            json['brand'],
      description:      json['description'],
      sentimentSummary: json['sentimentSummary'],
      pros:             json['pros'] ?? '[]',
      cons:             json['cons'] ?? '[]',
      currentPriceEgp:  (json['currentPriceEgp'] as num).toDouble(),
      imageUrl:         json['imageUrl'],
      globalRating:     json['globalRating'] != null
          ? (json['globalRating'] as num).toDouble()
          : null,
      globalUsdPrice:   json['globalUsdPrice'],
      lastAiUpdate:     json['lastAiUpdate'] != null
          ? DateTime.tryParse(json['lastAiUpdate'])
          : null,
      savedAt:          DateTime.parse(json['savedAt']),
    );
  }
}