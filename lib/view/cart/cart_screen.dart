import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../data/models/cart_item_model.dart';
import '../widget/custom_widget.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<CartViewModel>(
            builder: (context, cart, _) => cart.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Clear cart?'),
                  content: const Text('Remove all items from your cart?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        cart.clearCart();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear',
                          style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              ),
              child: const Text('Clear',
                  style: TextStyle(color: AppColors.error)),
            ),
          ),
        ],
      ),
      body: Consumer<CartViewModel>(
        builder: (context, cart, _) {
          if (cart.isEmpty) return _buildEmptyCart(context);
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _CartItemTile(item: cart.items[i]),
                ),
              ),
              _buildOrderSummary(context, cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: const BoxDecoration(
                color: AppColors.surfaceVariant, shape: BoxShape.circle),
            child: const Icon(Icons.shopping_bag_outlined,
                color: AppColors.textHint, size: 48),
          ),
          const SizedBox(height: 20),
          const Text('Your cart is empty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Add furniture to your cart to get started',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Browse Products',
            onPressed: () => Navigator.pop(context),
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartViewModel cart) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06),
              blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          children: [
            _summaryRow('Subtotal', '\$${cart.subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _summaryRow(
              'Shipping',
              cart.shippingCost == 0 ? 'FREE' : '\$${cart.shippingCost.toStringAsFixed(2)}',
              valueColor: cart.shippingCost == 0 ? AppColors.success : null,
            ),
            const SizedBox(height: 8),
            _summaryRow('Tax (5%)', '\$${cart.tax.toStringAsFixed(2)}'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: AppColors.border),
            ),
            _summaryRow('Total', '\$${cart.total.toStringAsFixed(2)}',
                isBold: true, fontSize: 18),
            const SizedBox(height: 16),
            if (cart.shippingCost > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Add \$${(500 - cart.subtotal).toStringAsFixed(0)} more for free shipping',
                  style: const TextStyle(fontSize: 12,
                      color: AppColors.info, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            PrimaryButton(
              label: 'Proceed to Checkout',
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment module coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
              icon: const Icon(Icons.lock_outline_rounded,
                  color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isBold = false, double fontSize = 14, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: fontSize,
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            )),
        Text(value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            )),
      ],
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItemModel item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartViewModel>();

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => cart.removeFromCart(item.product.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 24),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                item.product.thumbnailUrl ?? item.product.imageUrls.first,
                width: 90, height: 90, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    width: 90, height: 90, color: AppColors.surfaceVariant),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text(item.product.brand,
                      style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${item.subtotal.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      // Quantity controls
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            _QtyButton(
                              icon: Icons.remove_rounded,
                              onTap: () => cart.decrement(item.product.id),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Text('${item.quantity}',
                                  style: const TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary)),
                            ),
                            _QtyButton(
                              icon: Icons.add_rounded,
                              onTap: () => cart.increment(item.product.id),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}