import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constant/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/product_model.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../widget/custom_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  int _selectedImageIndex = 0;
  String? _selectedColor;
  late AnimationController _addToCartAnim;

  @override
  void initState() {
    super.initState();
    _addToCartAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _addToCartAnim.dispose();
    super.dispose();
  }

  void _handleAddToCart(ProductModel product) {
    final cart = context.read<CartViewModel>();
    _addToCartAnim.forward().then((_) => _addToCartAnim.reverse());
    cart.addToCart(product, selectedColor: _selectedColor);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('${product.name} added to cart'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, AppConstants.routeCart),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as ProductModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildImageSliver(product),
          SliverToBoxAdapter(child: _buildDetails(product)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(product),
    );
  }

  Widget _buildImageSliver(ProductModel product) {
    return SliverAppBar(
      expandedHeight: 380,
      pinned: true,
      backgroundColor: AppColors.surface,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.9),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 16),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Consumer<ProductViewModel>(
          builder: (context, vm, _) {
            final isWished = vm.isWishlisted(product.id);
            return Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: Icon(
                    isWished ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isWished ? AppColors.accent : AppColors.textPrimary,
                    size: 18,
                  ),
                  onPressed: () => vm.toggleWishlist(product.id),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              itemCount: product.imageUrls.length,
              onPageChanged: (i) => setState(() => _selectedImageIndex = i),
              itemBuilder: (_, i) => Image.network(
                product.imageUrls[i],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(Icons.image_outlined,
                      color: AppColors.textHint, size: 60),
                ),
              ),
            ),
            if (product.imageUrls.length > 1)
              Positioned(
                bottom: 16, left: 0, right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    product.imageUrls.length,
                        (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _selectedImageIndex == i ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _selectedImageIndex == i
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand + AR badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(product.brand,
                    style: const TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ),
              const SizedBox(width: 8),
              if (product.hasArModel)
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                      context, AppConstants.routeAR, arguments: product),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.primaryGradient),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.view_in_ar_rounded, color: Colors.white, size: 13),
                        SizedBox(width: 4),
                        Text('View in AR',
                            style: TextStyle(color: Colors.white,
                                fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Name
          Text(product.name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary, letterSpacing: -0.8, height: 1.2)),
          const SizedBox(height: 12),

          // Rating
          Row(
            children: [
              Row(
                children: List.generate(5, (i) => Icon(
                  i < product.rating.floor()
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: const Color(0xFFFBBC05), size: 18,
                )),
              ),
              const SizedBox(width: 8),
              Text('${product.rating} (${product.reviewCount} reviews)',
                  style: const TextStyle(fontSize: 13,
                      color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),

          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${product.effectivePrice.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary, letterSpacing: -1)),
              if (product.isOnSale) ...[
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('\$${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 18, color: AppColors.textHint,
                          decoration: TextDecoration.lineThrough)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('-${product.discountPercent.toInt()}%',
                      style: const TextStyle(color: AppColors.accent,
                          fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Colors
          if (product.colors.isNotEmpty) ...[
            const Text('Colors',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: product.colors.map((hex) {
                final color = Color(int.parse('0xFF${hex.replaceFirst('#', '')}'));
                final isSelected = _selectedColor == hex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(color: color.withOpacity(0.4),
                            blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Dimensions
          if (product.dimensions != null) ...[
            const Text('Dimensions',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDimItem('Width', '${product.dimensions!.width.toInt()} cm'),
                  Container(width: 1, height: 32, color: AppColors.border),
                  _buildDimItem('Height', '${product.dimensions!.height.toInt()} cm'),
                  Container(width: 1, height: 32, color: AppColors.border),
                  _buildDimItem('Depth', '${product.dimensions!.depth.toInt()} cm'),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Materials
          if (product.materials.isNotEmpty) ...[
            const Text('Materials',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: product.materials.map((m) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(m,
                    style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Description
          const Text('About this product',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Text(product.description,
              style: const TextStyle(fontSize: 14,
                  color: AppColors.textSecondary, height: 1.7)),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildDimItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
      ],
    );
  }

  Widget _buildBottomBar(ProductModel product) {
    return Consumer<CartViewModel>(
      builder: (context, cart, _) {
        final inCart = cart.isInCart(product.id);
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05),
                  blurRadius: 20, offset: const Offset(0, -4)),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // AR button
                Container(
                  width: 54, height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.view_in_ar_rounded,
                        color: AppColors.primary, size: 24),
                    onPressed: () => Navigator.pushNamed(
                        context, AppConstants.routeAR, arguments: product),
                  ),
                ),
                const SizedBox(width: 16),

                // Add to cart button
                Expanded(
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 0.95)
                        .animate(_addToCartAnim),
                    child: PrimaryButton(
                      label: inCart ? 'Added to Cart ✓' : 'Add to Cart',
                      onPressed: product.inStock
                          ? () => _handleAddToCart(product)
                          : null,
                      icon: inCart
                          ? null
                          : const Icon(Icons.shopping_bag_outlined,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}