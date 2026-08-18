import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

// --------------------------------------------------
// APP
// --------------------------------------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Fruit App',
      routerConfig: router,
    );
  }
}

// --------------------------------------------------
// GO ROUTER
// --------------------------------------------------

final GoRouter router = GoRouter(
  initialLocation: '/',

  routes: [
    // HOME PAGE
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const FruitListPage();
      },

      // NESTED FRUIT ROUTE
      routes: [
        GoRoute(
          path: 'fruit/apple',
          builder: (context, state) {
            return const FruitDetailPage(
              name: 'Apple',
              image: 'assets/apple.png',
            );
          },
        ),

        GoRoute(
          path: 'fruit/banana',
          builder: (context, state) {
            return const FruitDetailPage(
              name: 'Banana',
              image: 'assets/banana.png',
            );
          },
        ),

        GoRoute(
          path: 'fruit/orange',
          builder: (context, state) {
            return const FruitDetailPage(
              name: 'Orange',
              image: 'assets/orange.png',
            );
          },
        ),

        GoRoute(
          path: 'fruit/grapes',
          builder: (context, state) {
            return const FruitDetailPage(
              name: 'Grapes',
              image: 'assets/grapes.png',
            );
          },
        ),

        GoRoute(
          path: 'fruit/watermelon',
          builder: (context, state) {
            return const FruitDetailPage(
              name: 'Watermelon',
              image: 'assets/watermelon.png',
            );
          },
        ),

        GoRoute(
          path: 'fruit/strawberry',
          builder: (context, state) {
            return const FruitDetailPage(
              name: 'Strawberry',
              image: 'assets/strawberry.png',
            );
          },
        ),
      ],
    ),
  ],
);

// --------------------------------------------------
// FRUIT LIST PAGE
// --------------------------------------------------

class FruitListPage extends StatelessWidget {
  const FruitListPage({super.key});

  final List<Map<String, String>> fruits = const [
    {
      'name': 'Apple',
      'route': '/fruit/apple',
      'image': 'assets/apple.png',
    },
    {
      'name': 'Banana',
      'route': '/fruit/banana',
      'image': 'assets/banana.png',
    },
    {
      'name': 'Orange',
      'route': '/fruit/orange',
      'image': 'assets/orange.png',
    },
    {
      'name': 'Grapes',
      'route': '/fruit/grapes',
      'image': 'assets/grapes.png',
    },
    {
      'name': 'Watermelon',
      'route': '/fruit/watermelon',
      'image': 'assets/watermelon.png',
    },
    {
      'name': 'Strawberry',
      'route': '/fruit/strawberry',
      'image': 'assets/strawberry.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text(
          'Fruits',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),

        itemCount: fruits.length,

        itemBuilder: (context, index) {
          final fruit = fruits[index];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 14),

            child: ListTile(
              contentPadding: const EdgeInsets.all(10),

              // FRUIT IMAGE
              leading: Image.asset(
                fruit['image']!,
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),

              // FRUIT NAME
              title: Text(
                fruit['name']!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: const Text(
                'View fruit',
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),

              // GO TO FRUIT ROUTE
              onTap: () {
                context.go(
                  fruit['route']!,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// --------------------------------------------------
// FRUIT DETAIL PAGE
// --------------------------------------------------

class FruitDetailPage extends StatelessWidget {
  final String name;
  final String image;

  const FruitDetailPage({
    super.key,
    required this.name,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // LARGE FRUIT IMAGE
            Container(
              width: 250,
              height: 250,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),

              child: Image.asset(
                image,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 30),

            // FRUIT NAME
            Text(
              name,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // BACK BUTTON
            ElevatedButton.icon(
              onPressed: () {
                context.go('/');
              },

              icon: const Icon(
                Icons.arrow_back,
              ),

              label: const Text(
                'Back to Fruits',
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}