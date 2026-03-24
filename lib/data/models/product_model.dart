
import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductCategory { sofas, chairs, tables, beds, storage, lighting, decor, rugs }

extension ProductCategoryExtension on ProductCategory {
  String get label {
    switch (this) {
      case ProductCategory.sofas:    return 'Sofas';
      case ProductCategory.chairs:   return 'Chairs';
      case ProductCategory.tables:   return 'Tables';
      case ProductCategory.beds:     return 'Beds';
      case ProductCategory.storage:  return 'Storage';
      case ProductCategory.lighting: return 'Lighting';
      case ProductCategory.decor:    return 'Decor';
      case ProductCategory.rugs:     return 'Rugs';
    }
  }

  String get emoji {
    switch (this) {
      case ProductCategory.sofas:    return '🛋️';
      case ProductCategory.chairs:   return '🪑';
      case ProductCategory.tables:   return '🪵';
      case ProductCategory.beds:     return '🛏️';
      case ProductCategory.storage:  return '🗄️';
      case ProductCategory.lighting: return '💡';
      case ProductCategory.decor:    return '🖼️';
      case ProductCategory.rugs:     return '🏠';
    }
  }

  static ProductCategory fromString(String value) {
    return ProductCategory.values.firstWhere(
          (e) => e.name == value,
      orElse: () => ProductCategory.decor,
    );
  }
}

class ProductDimensions {
  final double width;
  final double height;
  final double depth;

  const ProductDimensions({required this.width, required this.height, required this.depth});

  factory ProductDimensions.fromMap(Map<String, dynamic> map) => ProductDimensions(
    width: (map['width'] ?? 0).toDouble(),
    height: (map['height'] ?? 0).toDouble(),
    depth: (map['depth'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toMap() => {'width': width, 'height': height, 'depth': depth};
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final ProductCategory category;
  final List<String> imageUrls;
  final String? arModelUrl;
  final String? thumbnailUrl;
  final List<String> colors;
  final List<String> materials;
  final ProductDimensions? dimensions;
  final double rating;
  final int reviewCount;
  final int stockCount;
  final bool isFeatured;
  final bool isNew;
  final String brand;
  final DateTime createdAt;

  ProductModel({
    required this.id, required this.name, required this.description,
    required this.price, this.discountPrice, required this.category,
    required this.imageUrls, this.arModelUrl, this.thumbnailUrl,
    this.colors = const [], this.materials = const [], this.dimensions,
    this.rating = 0.0, this.reviewCount = 0, this.stockCount = 0,
    this.isFeatured = false, this.isNew = false, this.brand = '',
    required this.createdAt,
  });

  bool get isOnSale => discountPrice != null && discountPrice! < price;
  double get effectivePrice => discountPrice ?? price;
  double get discountPercent => isOnSale ? ((price - discountPrice!) / price * 100).roundToDouble() : 0;
  bool get inStock => stockCount > 0;
  bool get hasArModel => arModelUrl != null && arModelUrl!.isNotEmpty;

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      discountPrice: data['discountPrice'] != null ? (data['discountPrice']).toDouble() : null,
      category: ProductCategoryExtension.fromString(data['category'] ?? 'decor'),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      arModelUrl: data['arModelUrl'],
      thumbnailUrl: data['thumbnailUrl'],
      colors: List<String>.from(data['colors'] ?? []),
      materials: List<String>.from(data['materials'] ?? []),
      dimensions: data['dimensions'] != null ? ProductDimensions.fromMap(data['dimensions']) : null,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      stockCount: data['stockCount'] ?? 0,
      isFeatured: data['isFeatured'] ?? false,
      isNew: data['isNew'] ?? false,
      brand: data['brand'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name, 'description': description, 'price': price,
    'discountPrice': discountPrice, 'category': category.name,
    'imageUrls': imageUrls, 'arModelUrl': arModelUrl, 'thumbnailUrl': thumbnailUrl,
    'colors': colors, 'materials': materials, 'dimensions': dimensions?.toMap(),
    'rating': rating, 'reviewCount': reviewCount, 'stockCount': stockCount,
    'isFeatured': isFeatured, 'isNew': isNew, 'brand': brand,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  static List<ProductModel> getMockProducts() {
    return [
      ProductModel(
        id: 'p001', name: 'Oslo Cloud Sofa',
        description: 'Sink into pure comfort with the Oslo Cloud Sofa. Engineered for deep relaxation with premium memory foam cushions and a solid oak frame.',
        price: 1299.00, discountPrice: 999.00, category: ProductCategory.sofas,
        imageUrls: ['https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800'],
        thumbnailUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400',
        colors: ['#C4A882', '#6B7280', '#1A1A2E'],
        materials: ['Memory Foam', 'Oak Wood', 'Premium Fabric'],
        dimensions: ProductDimensions(width: 240, height: 85, depth: 95),
        rating: 4.8, reviewCount: 124, stockCount: 8,
        isFeatured: true, isNew: false, brand: 'NordicHome', createdAt: DateTime.now(),
      ),
      ProductModel(
        id: 'p002', name: 'Arc Floor Lamp',
        description: 'A sculptural floor lamp that transforms any corner into a design statement.',
        price: 349.00, category: ProductCategory.lighting,
        imageUrls: ['https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800'],
        thumbnailUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        colors: ['#F5F5DC', '#1A1A2E', '#C0C0C0'],
        materials: ['Brushed Steel', 'Marble Base'],
        dimensions: ProductDimensions(width: 35, height: 180, depth: 35),
        rating: 4.6, reviewCount: 89, stockCount: 15,
        isFeatured: true, isNew: true, brand: 'LuxeLighting', createdAt: DateTime.now(),
      ),
      ProductModel(
        id: 'p003', name: 'Ember Lounge Chair',
        description: 'The Ember is a bold statement in modern seating — curved form, rich boucle upholstery, and solid walnut legs.',
        price: 849.00, discountPrice: 699.00, category: ProductCategory.chairs,
        imageUrls: ['https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=800'],
        thumbnailUrl: 'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=400',
        colors: ['#E8D5C4', '#4A4A4A', '#8B7355'],
        materials: ['Boucle Fabric', 'Walnut Wood'],
        dimensions: ProductDimensions(width: 80, height: 82, depth: 78),
        rating: 4.9, reviewCount: 203, stockCount: 5,
        isFeatured: true, isNew: false, brand: 'Artisan Co.', createdAt: DateTime.now(),
      ),
      ProductModel(
        id: 'p004', name: 'Slab Coffee Table',
        description: 'Raw concrete aesthetic meets precision craftsmanship.',
        price: 599.00, category: ProductCategory.tables,
        imageUrls: ['https://images.unsplash.com/photo-1532372320572-cda25653a26d?w=800'],
        thumbnailUrl: 'https://images.unsplash.com/photo-1532372320572-cda25653a26d?w=400',
        colors: ['#9CA3AF', '#6B7280', '#374151'],
        materials: ['Concrete', 'Steel Legs'],
        dimensions: ProductDimensions(width: 120, height: 42, depth: 60),
        rating: 4.5, reviewCount: 67, stockCount: 12,
        isFeatured: false, isNew: true, brand: 'RawForm', createdAt: DateTime.now(),
      ),
      ProductModel(
        id: 'p005', name: 'Haven Platform Bed',
        description: 'Low-profile platform bed with integrated headboard and hidden storage drawers.',
        price: 1599.00, discountPrice: 1299.00, category: ProductCategory.beds,
        imageUrls: ['https://images.unsplash.com/photo-1505693314120-0d443867891c?w=800'],
        thumbnailUrl: 'https://images.unsplash.com/photo-1505693314120-0d443867891c?w=400',
        colors: ['#F5F0E8', '#8B7355', '#1A1A2E'],
        materials: ['Solid Ash Wood', 'Linen Fabric'],
        dimensions: ProductDimensions(width: 200, height: 95, depth: 220),
        rating: 4.7, reviewCount: 156, stockCount: 6,
        isFeatured: true, isNew: false, brand: 'SleepLoft', createdAt: DateTime.now(),
      ),
      ProductModel(
        id: 'p006', name: 'Woven Jute Rug 2×3m',
        description: 'Hand-loomed jute rug in a natural herringbone weave.',
        price: 289.00, category: ProductCategory.rugs,
        imageUrls: ['https://images.unsplash.com/photo-1600166898405-da9535204843?w=800'],
        thumbnailUrl: 'https://images.unsplash.com/photo-1600166898405-da9535204843?w=400',
        colors: ['#C4A882', '#D4B896'],
        materials: ['Natural Jute'],
        dimensions: ProductDimensions(width: 200, height: 1, depth: 300),
        rating: 4.4, reviewCount: 44, stockCount: 20,
        isFeatured: false, isNew: false, brand: 'EarthWeave', createdAt: DateTime.now(),
      ),
      ProductModel(
        id: 'p007', name: 'Arch Bookshelf',
        description: 'Geometric arch-shaped shelving unit.',
        price: 479.00, category: ProductCategory.storage,
        imageUrls: ['https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800'],
        thumbnailUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400',
        colors: ['#F5F5DC', '#1A1A2E'],
        materials: ['MDF', 'Powder-Coated Steel'],
        dimensions: ProductDimensions(width: 90, height: 180, depth: 30),
        rating: 4.6, reviewCount: 91, stockCount: 9,
        isFeatured: false, isNew: true, brand: 'ShelfLife', createdAt: DateTime.now(),
      ),
      ProductModel(
        id: 'p008', name: 'Ceramic Vase Set',
        description: 'Trio of hand-thrown ceramic vases in matte earth tones.',
        price: 129.00, category: ProductCategory.decor,
        imageUrls: ['https://images.unsplash.com/photo-1612196808214-b7e239e5e5df?w=800'],
        thumbnailUrl: 'https://images.unsplash.com/photo-1612196808214-b7e239e5e5df?w=400',
        colors: ['#C4A882', '#8B6914', '#4A4A4A'],
        materials: ['Stoneware Ceramic'],
        rating: 4.8, reviewCount: 312, stockCount: 35,
        isFeatured: false, isNew: false, brand: 'ClayStudio', createdAt: DateTime.now(),
      ),
    ];
  }
}