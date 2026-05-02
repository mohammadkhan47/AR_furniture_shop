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
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    // AR View opens as separate screen
    if (index == 2) {
      Navigator.pushNamed(context, AppConstants.routeAR);
      return;
    }
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // disable swipe
        children: [
          _HomePage(),
          _ExplorePage(),
          const SizedBox(), // AR — handled separately
          _CartPageWrapper(),
          _ProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: _buildNavItem(0, Icons.home_rounded, 'Home')),
              Expanded(child: _buildNavItem(1, Icons.explore_outlined, 'Explore')),
              Expanded(child: _buildNavItem(2, Icons.view_in_ar_rounded, 'AR View')),
              Expanded(child: _buildNavItem(3, Icons.shopping_bag_outlined, 'Cart')),
              Expanded(child: _buildNavItem(4, Icons.person_outline_rounded, 'Profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    // AR is index 2 — never stays selected
    final isActive = index == 2 ? false : _currentIndex == index;

    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AR gets special gradient icon
            index == 2
                ? Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.view_in_ar_rounded,
                color: Colors.white,
                size: 22,
              ),
            )
                : Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textHint,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── HOME PAGE ────────────────────────────────────────────────────────────────
class _HomePage extends StatefulWidget {
  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
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
    return SafeArea(
      child: NestedScrollView(
        headerSliverBuilder: (context, _) => [_buildSliverAppBar()],
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hello, $name 👋',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w400, color: AppColors.textSecondary)),
              const Text('Find your perfect piece',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary, letterSpacing: -0.4)),
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
              borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Consumer<ProductViewModel>(
      builder: (context, vm, _) => SizedBox(
        height: 60,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          children: [
            _chip(label: 'All', emoji: '✨',
                isSelected: vm.selectedCategory == null,
                onTap: () => vm.selectCategory(null)),
            const SizedBox(width: 8),
            ...ProductCategory.values.map((cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _chip(
                label: cat.label, emoji: cat.emoji,
                isSelected: vm.selectedCategory == cat,
                onTap: () => vm.selectCategory(cat),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _chip({
    required String label, required String emoji,
    required bool isSelected, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
            Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    final banners = [
      _BannerData(title: 'Place it in\nyour space',
          subtitle: 'Try AR before you buy',
          gradient: AppColors.primaryGradient,
          icon: Icons.view_in_ar_rounded),
      _BannerData(title: 'Up to 30%\noff sofas',
          subtitle: 'Limited time offer',
          gradient: [AppColors.accent, AppColors.accentLight],
          icon: Icons.weekend_rounded),
      _BannerData(title: 'New arrivals\njust dropped',
          subtitle: 'Fresh styles this week',
          gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
          icon: Icons.new_releases_rounded),
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
              itemBuilder: (_, i) => _bannerCard(banners[i]),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentBanner == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentBanner == i ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _bannerCard(_BannerData data) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // ← REDUCED PADDING
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // ← ADD THIS
              children: [
                Text(
                  data.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18, // ← REDUCED FROM 20
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4), // ← REDUCED FROM 6
                Text(
                  data.subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10), // ← REDUCED FROM 14
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6), // ← REDUCED PADDING
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Shop now →',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11, // ← REDUCED FROM 12
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            data.icon,
            color: Colors.white.withOpacity(0.25),
            size: 65, // ← REDUCED FROM 70
          ),
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
            _sectionHeader('Featured', () {}),
            SizedBox(
              height: 320,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                itemCount: vm.featuredProducts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) => SizedBox(
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
            _sectionHeader('New Arrivals ✨', () {}),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                itemCount: vm.newArrivals.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) => _compactCard(vm.newArrivals[i]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _compactCard(ProductModel product) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context,
          AppConstants.routeProductDetail, arguments: product),
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
                  Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
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
                  Flexible(
                    child: Text(
                      _isSearching
                          ? '${vm.displayedProducts.length} results'
                          : vm.selectedCategory != null
                          ? vm.selectedCategory!.label
                          : 'All Products',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary, letterSpacing: -0.4),
                    ),
                  ),
                  _sortButton(vm),
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
              _emptyState(vm)
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.55,
                  ),
                  itemCount: vm.displayedProducts.length,
                  itemBuilder: (_, i) =>
                      ProductCard(product: vm.displayedProducts[i]),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _sortButton(ProductViewModel vm) {
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded, size: 15, color: AppColors.textSecondary),
            SizedBox(width: 6),
            Text('Sort', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
              const Text('Sort by', style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              ...options.entries.map((e) => RadioListTile<SortOption>(
                title: Text(e.value),
                value: e.key,
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

  Widget _emptyState(ProductViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded,
                color: AppColors.textHint, size: 56),
            const SizedBox(height: 16),
            const Text('No products found', style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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

  Widget _sectionHeader(String title, VoidCallback onAction) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary, letterSpacing: -0.4)),
          GestureDetector(
            onTap: onAction,
            child: const Text('See all', style: TextStyle(fontSize: 13,
                color: AppColors.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── EXPLORE PAGE ─────────────────────────────────────────────────────────────
class













_ExplorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Explore',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary, letterSpacing: -1)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.1,
                ),
                itemCount: ProductCategory.values.length,
                itemBuilder: (context, i) {
                  final cat = ProductCategory.values[i];
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(cat.emoji,
                              style: const TextStyle(fontSize: 40)),
                          const SizedBox(height: 10),
                          Text(cat.label,
                              style: const TextStyle(fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CART PAGE WRAPPER ────────────────────────────────────────────────────────
class _CartPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Reuse CartScreen directly
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const _InlineCartPage(),
      ),
    );
  }
}

class _InlineCartPage extends StatelessWidget {
  const _InlineCartPage();

  @override
  Widget build(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (context, cart, _) {
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('My Cart',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary, letterSpacing: -1)),
                    if (!cart.isEmpty)
                      TextButton(
                        onPressed: () => cart.clearCart(),
                        child: const Text('Clear',
                            style: TextStyle(color: AppColors.error)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (cart.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100, height: 100,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceVariant,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shopping_bag_outlined,
                              color: AppColors.textHint, size: 48),
                        ),
                        const SizedBox(height: 20),
                        const Text('Your cart is empty',
                            style: TextStyle(fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        const Text('Add items to get started',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              else ...[
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final item = cart.items[i];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                item.product.thumbnailUrl ??
                                    item.product.imageUrls.first,
                                width: 80, height: 80, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 80, height: 80,
                                  color: AppColors.surfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary)),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          '\$${item.subtotal.toStringAsFixed(0)}',
                                          style: const TextStyle(fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary)),
                                      Row(
                                        children: [
                                          _qtyBtn(Icons.remove_rounded,
                                                  () => cart.decrement(item.product.id)),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text('${item.quantity}',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700)),
                                          ),
                                          _qtyBtn(Icons.add_rounded,
                                                  () => cart.increment(item.product.id)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                          Text('\$${cart.total.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Proceed to Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: AppColors.textPrimary),
      ),
    );
  }
}

// ─── PROFILE PAGE ─────────────────────────────────────────────────────────────
class _ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        final user = vm.currentUser;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!) : null,
                  child: user?.photoUrl == null
                      ? Text(
                      user?.fullName.isNotEmpty == true
                          ? user!.fullName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 36,
                          fontWeight: FontWeight.w700, color: Colors.white))
                      : null,
                ),
                const SizedBox(height: 16),
                Text(user?.fullName ?? 'User',
                    style: const TextStyle(fontSize: 22,
                        fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(user?.email ?? '',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 32),
                // Menu items
                _profileItem(Icons.shopping_bag_outlined, 'My Orders', () {}),
                _profileItem(Icons.favorite_border_rounded, 'Wishlist', () {}),
                _profileItem(Icons.location_on_outlined, 'Addresses', () {}),
                _profileItem(Icons.payment_outlined, 'Payment Methods', () {}),
                _profileItem(Icons.settings_outlined, 'Settings', () {}),
                _profileItem(Icons.help_outline_rounded, 'Help & Support', () {}),
                const SizedBox(height: 16),
                // Logout
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await vm.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(
                            context, AppConstants.routeLogin);
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                    label: const Text('Sign Out',
                        style: TextStyle(color: AppColors.error,
                            fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
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

  Widget _profileItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 15,
                      fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textHint, size: 14),
          ],
        ),
      ),
    );
  }
}

// ─── Banner Data ──────────────────────────────────────────────────────────────
class _BannerData {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;

  _BannerData({required this.title, required this.subtitle,
    required this.gradient, required this.icon});
}