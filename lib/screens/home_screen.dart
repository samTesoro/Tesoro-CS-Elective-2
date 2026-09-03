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
  final List<IconData> _categoryIcons = [
    Icons.print_outlined,
    Icons.description_outlined,
    Icons.menu_book_outlined,
    Icons.image_outlined,
  ];
  int _selectedNavIndex = 0;

  void _scrollToCategory(String category) {
    setState(() {
      _selectedNavIndex = categories.indexOf(category) >= 2
          ? categories.indexOf(category) + 1
          : categories.indexOf(category);
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

      body: SingleChildScrollView(
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
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final year = Stack(
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
                                      );

                                      if (constraints.maxWidth < 440) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'QUALITY PRINTS SINCE',
                                              style: theme.textTheme.headlineLarge
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
                                            style: theme.textTheme.headlineLarge
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

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          if (index == 2) {
            setState(() {
              _selectedNavIndex = index;
            });
            return;
          }

          final categoryIndex = index > 2 ? index - 1 : index;
          _scrollToCategory(categories[categoryIndex]);
        },
        destinations: [
          NavigationDestination(
            icon: Icon(_categoryIcons[0]),
            selectedIcon: Icon(_categoryIcons[0]),
            label: categories[0],
          ),
          NavigationDestination(
            icon: Icon(_categoryIcons[1]),
            selectedIcon: Icon(_categoryIcons[1]),
            label: categories[1],
          ),
          NavigationDestination(
            icon: Transform.translate(
              offset: const Offset(0, 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 28,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            selectedIcon: Transform.translate(
              offset: const Offset(0, 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_cart,
                  size: 28,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(_categoryIcons[2]),
            selectedIcon: Icon(_categoryIcons[2]),
            label: categories[2],
          ),
          NavigationDestination(
            icon: Icon(_categoryIcons[3]),
            selectedIcon: Icon(_categoryIcons[3]),
            label: categories[3],
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

        final cardAspectRatio = constraints.maxWidth < 600 ? 0.68 : 0.78;

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
                    onTap: () {
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