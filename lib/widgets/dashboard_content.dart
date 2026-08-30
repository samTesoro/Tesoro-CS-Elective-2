import 'package:flutter/material.dart';
import 'dashboard_card.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;

        if (constraints.maxWidth < 500) {
          columns = 2;
        } else if (constraints.maxWidth < 800) {
          columns = 3;
        } else {
          columns = 4;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard Overview',
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 20),

              OrientationBuilder(
  builder: (context, orientation) {
    final isPortrait =
        orientation == Orientation.portrait;

    return GridView.count(
      crossAxisCount: isPortrait
          ? columns
          : columns + 1,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: const [
        DashboardCard(
          title: 'Analytics',
          icon: Icons.analytics_outlined,
        ),
        DashboardCard(
          title: 'Users',
          icon: Icons.people_outline,
        ),
        DashboardCard(
          title: 'Messages',
          icon: Icons.message_outlined,
        ),
        DashboardCard(
          title: 'Settings',
          icon: Icons.settings_outlined,
        ),
      ],
    );
  },
),

              const SizedBox(height: 20),

              const _WidePanel(
                title: 'Recent Activity',
              ),

              const SizedBox(height: 12),

              const _WidePanel(
                title: 'Performance',
              ),

              const SizedBox(height: 12),

              const _WidePanel(
                title: 'Statistics',
              ),

              const SizedBox(height: 24),

              const _AdaptiveControls(),
            ],
          ),
        );
      },
    );
  }
}

class _WidePanel extends StatelessWidget {
  final String title;

  const _WidePanel({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 100,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _AdaptiveControls extends StatefulWidget {
  const _AdaptiveControls();

  @override
  State<_AdaptiveControls> createState() => _AdaptiveControlsState();
}

class _AdaptiveControlsState extends State<_AdaptiveControls> {
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Notifications'),

        const Spacer(),

        Switch.adaptive(
          value: notifications,
          onChanged: (value) {
            setState(() {
              notifications = value;
            });
          },
        ),

        const SizedBox(width: 16),

        const CircularProgressIndicator.adaptive(),
      ],
    );
  }
}