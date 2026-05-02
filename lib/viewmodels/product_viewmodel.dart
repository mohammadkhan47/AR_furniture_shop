import 'package:flutter/foundation.dart';
import '../data/models/product_model.dart';
import '../data/repositories/product_repo.dart';

enum SortOption { none, priceAsc, priceDesc, rating, newest }

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repo;

  ProductViewModel({ProductRepository? repo})
      : _repo = repo ?? ProductRepository() {
    loadAllProducts();
  }

  List<ProductModel> _allProducts = [];
  List<ProductModel> _displayedProducts = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _newArrivals = [];
  final Set<String> _wishlist = {};
  ProductCategory? _selectedCategory;
  String _searchQuery = '';
  SortOption _sortOption = SortOption.none;
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get displayedProducts => _displayedProducts;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get newArrivals => _newArrivals;
  Set<String> get wishlist => _wishlist;
  ProductCategory? get selectedCategory => _selectedCategory;
  SortOption get sortOption => _sortOption;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool isWishlisted(String id) => _wishlist.contains(id);

  Future<void> loadAllProducts() async {
    _setLoading(true);
    try {
      _allProducts = await _repo.getAllProducts();
      _featuredProducts = _allProducts.where((p) => p.isFeatured).toList();
      _newArrivals = _allProducts.where((p) => p.isNew).toList();
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Failed to load products.';
    }
    _setLoading(false);
  }

  void selectCategory(ProductCategory? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
  }

  void sortBy(SortOption option) {
    _sortOption = option;
    _applyFilters();
  }

  void toggleWishlist(String productId) {
    if (_wishlist.contains(productId)) {
      _wishlist.remove(productId);
    } else {
      _wishlist.add(productId);
    }
    notifyListeners();
  }

  void _applyFilters() {
    var filtered = List<ProductModel>.from(_allProducts);
    if (_selectedCategory != null) {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((p) =>
      p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.category.label.toLowerCase().contains(q)
      ).toList();
    }
    switch (_sortOption) {
      case SortOption.priceAsc:  filtered.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice)); break;
      case SortOption.priceDesc: filtered.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice)); break;
      case SortOption.rating:    filtered.sort((a, b) => b.rating.compareTo(a.rating)); break;
      case SortOption.newest:    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt)); break;
      case SortOption.none: break;
    }
    _displayedProducts = filtered;
    notifyListeners();
  }

  void _setLoading(bool value) { _isLoading = value; notifyListeners(); }
  void clearError() { _errorMessage = null; notifyListeners(); }
}