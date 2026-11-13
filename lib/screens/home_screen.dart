import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _productsKey = GlobalKey();

  bool _isCartHovered = false;

  static const List<String> _categories = ProductProvider.categories;

  static const List<IconData> _categoryIcons = [
    Icons.print_outlined,
    Icons.description_outlined,
    Icons.menu_book_outlined,
    Icons.image_outlined,
  ];

  static const int _cartNavIndex = 2;

  int _navIndexForCategory(String? category) {
    if (category == null) return _cartNavIndex;
    final i = _categories.indexOf(category);
    return i >= 2 ? i + 1 : i;
  }

  @override
  void initState() {
    super.initState();
    _searchController.text = context.read<ProductProvider>().search;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollToProducts() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _productsKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _selectCategory(String? category) {
    final provider = context.read<ProductProvider>();
    provider.setCategory(
      provider.selectedCategory == category ? null : category,
    );
    _scrollToProducts();
  }

  void _clearFilters() {
    _searchController.clear();
    context.read<ProductProvider>().clearFilters();
  }

  void _openCart() {
    context.push('/cart');
  }

  void _openProduct(Product product) {
    context.push('/product/${product.id}', extra: product);
  }

  Widget _cartNavigationIcon() {
    final theme = Theme.of(context);
    final cartItemCount = context.watch<CartProvider>().itemCount;

    return Transform.translate(
      offset: const Offset(0, 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isCartHovered = true),
        onExit: (_) => setState(() => _isCartHovered = false),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Badge.count(
            count: cartItemCount,
            isLabelVisible: cartItemCount > 0,
            alignment: Alignment.topRight,
            offset: const Offset(4, -4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isCartHovered
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 8,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 28,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(ThemeData theme) {
    final heroTextColor = Colors.white;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: double.infinity,
        height: 280,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/hero_building.jpg',
              fit: BoxFit.cover,
            ),

            Container(
              color: theme.colorScheme.scrim.withValues(
                alpha: 0.52,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final year = Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '1965',
                              style: theme
                                  .textTheme.headlineLarge
                                  ?.copyWith(
                                    foreground: Paint()
                                      ..style =
                                          PaintingStyle.stroke
                                      ..strokeWidth = 1.5
                                      ..color = theme
                                          .colorScheme.onPrimary,
                                  ),
                            ),

                            Text(
                              '1965',
                              style: theme
                                  .textTheme.headlineLarge
                                  ?.copyWith(
                                    color: theme
                                        .colorScheme.primary,
                                  ),
                            ),
                          ],
                        );

                        if (constraints.maxWidth < 440) {
                          return Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'QUALITY PRINTS SINCE',
                                style: theme
                                    .textTheme.headlineLarge
                                    ?.copyWith(
                                      color: heroTextColor,
                                    ),
                              ),
                              year,
                            ],
                          );
                        }

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'QUALITY PRINTS SINCE ',
                              style: theme
                                  .textTheme.headlineLarge
                                  ?.copyWith(
                                    color: heroTextColor,
                                  ),
                            ),
                            year,
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Browse our selection of printing products and services.',
                      style:
                          theme.textTheme.bodyMedium?.copyWith(
                        color: heroTextColor.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(ProductProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: provider.selectedCategory == null,
            onSelected: (_) => provider.setCategory(null),
          ),
          for (var i = 0; i < _categories.length; i++) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              avatar: Icon(_categoryIcons[i], size: 18),
              label: Text(_categories[i]),
              selected: provider.selectedCategory == _categories[i],
              onSelected: (_) => provider.setCategory(_categories[i]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceFilter(ThemeData theme, ProductProvider provider) {
    if (!provider.hasPriceBounds) return const SizedBox.shrink();

    final min = provider.minPriceBound;
    final max = provider.maxPriceBound;
    final start = provider.minPrice.clamp(min, max);
    final end = provider.maxPrice.clamp(start, max);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        leading: Icon(Icons.tune, color: theme.colorScheme.primary),
        title: Text('Price range', style: theme.textTheme.titleMedium),
        subtitle: Text(
          provider.isPriceFiltered
              ? '${_peso(start)} – ${_peso(end)}'
              : 'Any price',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: provider.isPriceFiltered
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight:
                provider.isPriceFiltered ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        children: [
          RangeSlider(
            values: RangeValues(start, end),
            min: min,
            max: max,
            divisions: ((max - min) / ProductProvider.priceStep).round(),
            labels: RangeLabels(_peso(start), _peso(end)),
            onChanged: (values) =>
                provider.previewPriceRange(values.start, values.end),
            onChangeEnd: (values) =>
                provider.applyPriceRange(values.start, values.end),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(_peso(min), style: theme.textTheme.bodySmall),
                const Spacer(),
                TextButton(
                  onPressed:
                      provider.isPriceFiltered ? provider.resetPriceRange : null,
                  child: const Text('Reset'),
                ),
                const Spacer(),
                Text(_peso(max), style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProducts(ThemeData theme, ProductProvider provider) {
    if (provider.status == ProductStatus.loading && provider.products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.status == ProductStatus.error) {
      return _MessageView(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load products',
        message: provider.errorMessage,
        actionLabel: 'Try again',
        onAction: provider.fetchProducts,
      );
    }

    if (provider.products.isEmpty) {
      return _MessageView(
        icon: Icons.search_off_outlined,
        title: 'No products found',
        message: 'Try a different search, category, or price range.',
        actionLabel: provider.hasActiveFilters ? 'Clear filters' : null,
        onAction: provider.hasActiveFilters ? _clearFilters : null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 4,
          child: provider.status == ProductStatus.loading
              ? const LinearProgressIndicator()
              : null,
        ),
        const SizedBox(height: 12),
        _ProductGrid(
          products: provider.products,
          onTap: _openProduct,
        ),
        if (provider.totalPages > 1) ...[
          const SizedBox(height: 24),
          _PaginationBar(
            page: provider.page,
            totalPages: provider.totalPages,
            enabled: provider.status != ProductStatus.loading,
            onPageSelected: _goToPage,
          ),
        ],
      ],
    );
  }

  void _goToPage(int page) {
    context.read<ProductProvider>().goToPage(page);
    _scrollToProducts();
  }

  String _showingText(ProductProvider provider) {
    final total = provider.totalCount;
    if (total == 0) return 'No products';
    final noun = total == 1 ? 'product' : 'products';
    return 'Showing ${provider.firstItemNumber}–${provider.lastItemNumber} '
        'of $total $noun';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ProductProvider>();
    final isSearching = provider.search.trim().isNotEmpty;
    final title = provider.selectedCategory ?? 'All Products';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            tooltip: widget.themeMode == ThemeMode.dark
                ? 'Light mode'
                : 'Dark mode',
            onPressed: widget.onToggleTheme,
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
        ),
        titleSpacing: 8,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: provider.setSearch,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search, size: 22),
                    prefixIconConstraints: const BoxConstraints.tightFor(
                      width: 44,
                      height: 44,
                    ),
                    suffixIconConstraints: const BoxConstraints.tightFor(
                      width: 44,
                      height: 44,
                    ),
                    suffixIcon: isSearching
                        ? IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearch('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => context.read<AuthProvider>().signOut(),
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.fetchProducts,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isSearching) ...[
                _buildHero(theme),
                const SizedBox(height: 32),
              ],

              Text(
                isSearching ? 'Search Results' : title,
                key: _productsKey,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                isSearching
                    ? 'Results for "${provider.search.trim()}"'
                        '${provider.selectedCategory != null ? ' in ${provider.selectedCategory}' : ''}'
                        ' · ${_showingText(provider)}'
                    : _showingText(provider),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              _buildFilterChips(provider),
              const SizedBox(height: 16),

              _buildPriceFilter(theme, provider),
              const SizedBox(height: 8),

              _buildProducts(theme, provider),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndexForCategory(provider.selectedCategory),
        indicatorColor: provider.selectedCategory == null
            ? Colors.transparent
            : null,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        onDestinationSelected: (index) {
          if (index == _cartNavIndex) {
            _openCart();
            return;
          }
          final categoryIndex = index > _cartNavIndex ? index - 1 : index;
          _selectCategory(_categories[categoryIndex]);
        },
        destinations: [
          NavigationDestination(
            icon: Icon(_categoryIcons[0]),
            label: _categories[0],
          ),
          NavigationDestination(
            icon: Icon(_categoryIcons[1]),
            label: _categories[1],
          ),
          NavigationDestination(
            icon: _cartNavigationIcon(),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(_categoryIcons[2]),
            label: _categories[2],
          ),
          NavigationDestination(
            icon: Icon(_categoryIcons[3]),
            label: _categories[3],
          ),
        ],
      ),
    );
  }
}

String _peso(double value) {
  final digits = value.round().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }

  return '₱$buffer';
}

class _ProductGrid extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onTap;

  const _ProductGrid({
    required this.products,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columnCount;

        if (constraints.maxWidth >= 900) {
          columnCount = 4;
        } else if (constraints.maxWidth >= 600) {
          columnCount = 3;
        } else {
          columnCount = 2;
        }

        final cardAspectRatio = constraints.maxWidth < 600 ? 0.68 : 0.78;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: cardAspectRatio,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              key: ValueKey(product.id),
              product: product,
              onTap: () => onTap(product),
            );
          },
        );
      },
    );
  }
}

class _MessageView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 70, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int page;
  final int totalPages;
  final bool enabled;
  final ValueChanged<int> onPageSelected;

  const _PaginationBar({
    required this.page,
    required this.totalPages,
    required this.enabled,
    required this.onPageSelected,
  });

  static const int _maxVisiblePages = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    var first = page - _maxVisiblePages ~/ 2;
    if (first < 0) first = 0;
    var last = first + _maxVisiblePages - 1;
    if (last > totalPages - 1) {
      last = totalPages - 1;
      first = (last - _maxVisiblePages + 1).clamp(0, last);
    }

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            IconButton.outlined(
              tooltip: 'Previous page',
              onPressed: enabled && page > 0
                  ? () => onPageSelected(page - 1)
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            for (var i = first; i <= last; i++)
              SizedBox(
                width: 44,
                height: 44,
                child: i == page
                    ? FilledButton(
                        onPressed: null,
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.zero,
                          disabledBackgroundColor: theme.colorScheme.primary,
                          disabledForegroundColor: theme.colorScheme.onPrimary,
                        ),
                        child: Text('${i + 1}'),
                      )
                    : OutlinedButton(
                        onPressed: enabled ? () => onPageSelected(i) : null,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Text('${i + 1}'),
                      ),
              ),
            IconButton.outlined(
              tooltip: 'Next page',
              onPressed: enabled && page < totalPages - 1
                  ? () => onPageSelected(page + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Page ${page + 1} of $totalPages',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
