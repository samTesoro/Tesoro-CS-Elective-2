import 'package:flutter/material.dart';
import '../products/all_products.dart';
import '../widgets/product_card.dart';
import '../models/product.dart';
import 'package:go_router/go_router.dart';

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

  final List<String> categories = [
    'Printers',
    'Flyers',
    'Brochures',
    'Tarpaulins',
  ];

  final Map<String, GlobalKey> _categoryKeys = {
    'Printers': GlobalKey(),
    'Flyers': GlobalKey(),
    'Brochures': GlobalKey(),
    'Tarpaulins': GlobalKey(),
  };
  String _selectedCategory = 'Printers';

  void _scrollToCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });

    final context = _categoryKeys[category]?.currentContext;

    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Product> _productsByCategory(String category) {
    return allProducts
        .where((product) => product.category == category)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heroTextColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 60,
              width: 70,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
        ],
      ),

      // Category Navigation
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: theme.colorScheme.surfaceContainer,
            child: Row(
              children: categories.map((category) {
                final isSelected = _selectedCategory == category;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface.withValues(alpha: 0),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () => _scrollToCategory(category),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 12,
                          ),
                          child: Text(
                            category,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section
                  ClipRRect(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'QUALITY PRINTS SINCE ',
                                        style: theme.textTheme.headlineLarge
                                            ?.copyWith(
                                              color: heroTextColor,
                                            ),
                                      ),
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Text(
                                            '1965',
                                            style: theme.textTheme.headlineLarge
                                                ?.copyWith(
                                                  foreground: Paint()
                                                    ..style = PaintingStyle.stroke
                                                    ..strokeWidth = 1.5
                                                    ..color = theme
                                                        .colorScheme.onPrimary,
                                                ),
                                          ),
                                          Text(
                                            '1965',
                                            style: theme.textTheme.headlineLarge
                                                ?.copyWith(
                                                  color: theme.colorScheme.primary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Browse our selection of printing products and services.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
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
                  ),

                  const SizedBox(height: 32),

                  // Category Sections
                  ...categories.map((category) {
                    final products = _productsByCategory(category);

                    return _CategorySection(
                      key: _categoryKeys[category],
                      category: category,
                      products: products,
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<Product> products;

  const _CategorySection({
    super.key,
    required this.category,
    required this.products,
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

        final cardAspectRatio = constraints.maxWidth < 600 ? 0.45 : 0.58;

        return Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columnCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: cardAspectRatio,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: products[index],
                    onSeeMore: () {
                      context.push(
                        '/product/${products[index].name}',
                        extra: products[index],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}