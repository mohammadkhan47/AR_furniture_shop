import 'product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  int quantity;
  final String? selectedColor;

  CartItemModel({
    required this.id, required this.product,
    this.quantity = 1, this.selectedColor,
  });

  double get subtotal => product.effectivePrice * quantity;

  CartItemModel copyWith({int? quantity, String? selectedColor}) => CartItemModel(
    id: id, product: product,
    quantity: quantity ?? this.quantity,
    selectedColor: selectedColor ?? this.selectedColor,
  );
}