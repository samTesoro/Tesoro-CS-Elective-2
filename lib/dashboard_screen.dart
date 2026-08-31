import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget box({double height = 100}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget menuItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade800),
          const SizedBox(width: 15),
          Text(
            label,
            style: const TextStyle(
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget sidebar({bool isDrawer = false}) {
    return Container(
      width: isDrawer ? double.infinity : 220,
      padding: const EdgeInsets.all(24),
      color: Colors.grey.shade200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.favorite, size: 45),
          const SizedBox(height: 40),
          const Divider(),

          menuItem(Icons.home, 'DASHBOARD'),
          menuItem(Icons.settings, 'SETTINGS'),
          menuItem(Icons.info, 'ABOUT'),
          menuItem(Icons.logout, 'LOGOUT'),
        ],
      ),
    );
  }

  Widget content(int columns) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: columns,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: List.generate(4, (_) => box()),
          ),

          const SizedBox(height: 16),

          box(height: 80),
          const SizedBox(height: 12),

          box(height: 80),
          const SizedBox(height: 12),

          box(height: 80),
          const SizedBox(height: 12),

          box(height: 80),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.iOS;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final isMobile = width < 600;
        final isDesktop = width >= 1000;

        return Scaffold(
          backgroundColor: Colors.grey.shade300,

          drawer: isDesktop
              ? null
              : Drawer(
                  child: SafeArea(
                    child: sidebar(isDrawer: true),
                  ),
                ),

          appBar: isDesktop
              ? null
              : isIOS
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(50),
                      child: CupertinoNavigationBar(
                        leading: Builder(
                          builder: (context) => CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: const Icon(
                              CupertinoIcons.bars,
                            ),
                          ),
                        ),
                      ),
                    )
                  : AppBar(
                      backgroundColor: Colors.grey.shade900,
                      foregroundColor: Colors.white,
                    ),

          body: isDesktop
              ? Row(
                  children: [
                    sidebar(),

                    Expanded(
                      flex: 3,
                      child: content(4),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Expanded(child: box()),
                            const SizedBox(height: 16),
                            Expanded(child: box()),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : content(isMobile ? 2 : 4),
        );
      },
    );
  }
}