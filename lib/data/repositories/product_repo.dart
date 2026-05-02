import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constant/app_constants.dart';
import '../models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _products => _firestore.collection(AppConstants.productsCollection);

  Future<List<ProductModel>> getAllProducts() async {
    try {
      return ProductModel.getMockProducts();
      // Uncomment for Firestore:
      // final snapshot = await _products.orderBy('createdAt', descending: true).get();
      // return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    } catch (e) {
      return ProductModel.getMockProducts();
    }
  }

  Future<List<ProductModel>> getProductsByCategory(ProductCategory category) async {
    final all = await getAllProducts();
    return all.where((p) => p.category == category).toList();
  }

  Future<List<ProductModel>> getFeaturedProducts() async {
    final all = await getAllProducts();
    return all.where((p) => p.isFeatured).toList();
  }

  Future<List<ProductModel>> getNewArrivals() async {
    final all = await getAllProducts();
    return all.where((p) => p.isNew).toList();
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final all = await getAllProducts();
    final q = query.toLowerCase();
    return all.where((p) =>
    p.name.toLowerCase().contains(q) ||
        p.description.toLowerCase().contains(q) ||
        p.brand.toLowerCase().contains(q)
    ).toList();
  }

  Future<ProductModel?> getProductById(String id) async {
    final all = await getAllProducts();
    try { return all.firstWhere((p) => p.id == id); }
    catch (e) { return null; }
  }

  Future<void> seedProducts() async {
    final products = ProductModel.getMockProducts();
    final batch = _firestore.batch();
    for (final product in products) {
      batch.set(_products.doc(product.id), product.toFirestore());
    }
    await batch.commit();
  }
}