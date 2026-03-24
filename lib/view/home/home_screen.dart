// lib/views/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constant/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/product_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../widget/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  int _currentBanner = 0;
  final PageController _bannerController = PageController();

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverAppBar(),
          ],
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                _buildCategoryChips(),
                _buildBannerSection(),
                _buildFeaturedSection(),
                _buildNewArrivalsSection(),
                _buildAllProductsSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Consumer<AuthViewModel>(
        builder: (context, vm, _) {
          final name = vm.currentUser?.fullName.split(' ').first ?? 'there';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $name 👋',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const Text(
                'Find your perfect piece',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        Consumer<ProductViewModel>(
          builder: (context, vm, _) => IconButton(
            onPressed: () {},
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.favorite_border_rounded,
                    color: AppColors.textPrimary, size: 24),
                if (vm.wishlist.isNotEmpty)
                  Positioned(
                    top: -4, right: -4,
                    child: Container(
                      width: 16, height: 16,
                      decoration: const BoxDecoration(
                          color: AppColors.accent, shape: BoxShape.circle),
                      child: Center(
                        child: Text('${vm.wishlist.length}',
                            style: const TextStyle(color: Colors.white,
                                fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Consumer<CartViewModel>(
          builder: (context, cart, _) => IconButton(
            onPressed: () => Navigator.pushNamed(context, AppConstants.routeCart),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag_outlined,
                    color: AppColors.textPrimary, size: 24),
                if (cart.itemCount > 0)
                  Positioned(
                    top: -4, right: -4,
                    child: Container(
                      width: 16, height: 16,
                      decoration: const BoxDecoration(
                          color: AppColors.accent, shape: BoxShape.circle),
                      child: Center(
                        child: Text('${cart.itemCount}',
                            style: const TextStyle(color: Colors.white,
                                fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Consumer<ProductViewModel>(
        builder: (context, vm, _) => TextField(
          controller: _searchController,
          onChanged: (val) {
            vm.search(val);
            setState(() => _isSearching = val.isNotEmpty);
          },
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Search furniture, decor...',
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppColors.textHint, size: 20),
            suffixIcon: _isSearching
                ? IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: AppColors.textHint, size: 18),
              onPressed: () {
                _searchController.clear();
                vm.clearSearch();
                setState(() => _isSearching = false);
              },
            )
                : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Consumer<ProductViewModel>(
      builder: (context, vm, _) {
        return SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            children: [
              _buildCategoryChip(
                label: 'All', emoji: '✨',
                isSelected: vm.selectedCategory == null,
                onTap: () => vm.selectCategory(null),
              ),
              const SizedBox(width: 8),
              ...ProductCategory.values.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildCategoryChip(
                  label: cat.label,
                  emoji: cat.emoji,
                  isSelected: vm.selectedCategory == cat,
                  onTap: () => vm.selectCategory(cat),
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    final banners = [
      _BannerData(
        title: 'Place it in\nyour space',
        subtitle: 'Try AR before you buy',
        gradient: AppColors.primaryGradient,
        icon: Icons.view_in_ar_rounded,
      ),
      _BannerData(
        title: 'Up to 30%\noff sofas',
        subtitle: 'Limited time offer',
        gradient: [AppColors.accent, AppColors.accentLight],
        icon: Icons.weekend_rounded,
      ),
      _BannerData(
        title: 'New arrivals\njust dropped',
        subtitle: 'Fresh styles this week',
        gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
        icon: Icons.new_releases_rounded,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _bannerController,
              itemCount: banners.length,
              onPageChanged: (i) => setState(() => _currentBanner = i),
              itemBuilder: (context, i) => _buildBannerCard(banners[i]),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              banners.length,
                  (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentBanner == i ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentBanner == i ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard(_BannerData data) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(data.title,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 22,
                      fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.5,
                    )),
                const SizedBox(height: 6),
                Text(data.subtitle,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Shop now →',
                      style: TextStyle(color: Colors.white,
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Icon(data.icon, color: Colors.white.withOpacity(0.25), size: 90),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Consumer<ProductViewModel>(
      builder: (context, vm, _) {
        if (vm.featuredProducts.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Featured', 'See all', () {}),
            SizedBox(
              height: 300,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                itemCount: vm.featuredProducts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) => SizedBox(
                  width: 200,
                  child: ProductCard(product: vm.featuredProducts[i]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNewArrivalsSection() {
    return Consumer<ProductViewModel>(
      builder: (context, vm, _) {
        if (vm.newArrivals.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('New Arrivals ✨', 'See all', () {}),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                itemCount: vm.newArrivals.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) => _buildCompactCard(vm.newArrivals[i]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompactCard(ProductModel product) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
          context, AppConstants.routeProductDetail, arguments: product),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                product.thumbnailUrl ?? product.imageUrls.first,
                height: 110, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(height: 110, color: AppColors.surfaceVariant),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12,
                          fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('\$${product.effectivePrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllProductsSection() {
    return Consumer<ProductViewModel>(
      builder: (context, vm, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isSearching
                        ? '${vm.displayedProducts.length} results'
                        : vm.selectedCategory != null
                        ? vm.selectedCategory!.label
                        : 'All Products',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary, letterSpacing: -0.4),
                  ),
                  _buildSortButton(vm),
                ],
              ),
            ),
            if (vm.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2.5),
                ),
              )
            else if (vm.displayedProducts.isEmpty)
              _buildEmptyState(vm)
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: vm.displayedProducts.length,
                  itemBuilder: (context, i) =>
                      ProductCard(product: vm.displayedProducts[i]),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSortButton(ProductViewModel vm) {
    return GestureDetector(
      onTap: () => _showSortSheet(vm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.tune_rounded, size: 15, color: AppColors.textSecondary),
            SizedBox(width: 6),
            Text('Sort',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  void _showSortSheet(ProductViewModel vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        final options = {
          SortOption.none: 'Default',
          SortOption.priceAsc: 'Price: Low to High',
          SortOption.priceDesc: 'Price: High to Low',
          SortOption.rating: 'Top Rated',
          SortOption.newest: 'Newest First',
        };
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sort by',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              ...options.entries.map((entry) => RadioListTile<SortOption>(
                title: Text(entry.value),
                value: entry.key,
                groupValue: vm.sortOption,
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  vm.sortBy(val!);
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ProductViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, color: AppColors.textHint, size: 56),
            const SizedBox(height: 16),
            const Text('No products found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Try a different search or category',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                vm.clearSearch();
                vm.selectCategory(null);
                _searchController.clear();
                setState(() => _isSearching = false);
              },
              child: const Text('Clear filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionLabel, VoidCallback onAction) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, letterSpacing: -0.4)),
          GestureDetector(
            onTap: onAction,
            child: const Text('See all',
                style: TextStyle(fontSize: 13, color: AppColors.accent,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', true, () {}),
              _buildNavItem(Icons.explore_outlined, 'Explore', false, () {}),
              _buildNavItem(Icons.view_in_ar_rounded, 'AR View', false,
                      () => Navigator.pushNamed(context, AppConstants.routeAR)),
              _buildNavItem(Icons.shopping_bag_outlined, 'Cart', false,
                      () => Navigator.pushNamed(context, AppConstants.routeCart)),
              _buildNavItem(Icons.person_outline_rounded, 'Profile', false,
                      () => Navigator.pushNamed(context, AppConstants.routeProfile)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isActive ? AppColors.primary : AppColors.textHint, size: 22),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppColors.primary : AppColors.textHint,
                )),
          ],
        ),
      ),
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;

  _BannerData({
    required this.title, required this.subtitle,
    required this.gradient, required this.icon,
  });
}