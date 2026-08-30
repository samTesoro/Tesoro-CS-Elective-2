import 'package:flutter/material.dart';

import '../models/device_type.dart';
import '../widgets/adaptive_action_button.dart';
import '../widgets/dashboard_content.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  final List<String> destinations = [
    'Dashboard',
    'Settings',
    'About',
    'Logout',
  ];

  final List<IconData> destinationIcons = [
    Icons.dashboard_outlined,
    Icons.settings_outlined,
    Icons.info_outline,
    Icons.logout,
  ];

  @override
  Widget build(BuildContext context) {
    // MEDIAQUERY:
    // Used for whole-window decisions.
    final width = MediaQuery.sizeOf(context).width;

    // CENTRALIZED BREAKPOINT LOGIC
    final deviceType = deviceTypeOf(width);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Responsive Dashboard'),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: AdaptiveActionButton(),
            ),
          ],
        ),

        body: Row(
          children: [
            // MEDIUM DEVICE:
            // Icons-only NavigationRail
            if (deviceType == DeviceType.medium)
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: _onDestinationSelected,
                labelType: NavigationRailLabelType.none,
                destinations: _buildRailDestinations(),
              ),

            // EXPANDED + LARGE:
            // Extended NavigationRail with labels
            if (deviceType == DeviceType.expanded ||
                deviceType == DeviceType.large)
              NavigationRail(
                extended: true,
                selectedIndex: selectedIndex,
                onDestinationSelected: _onDestinationSelected,
                destinations: _buildRailDestinations(),
              ),

            // Flexible content area
            Expanded(
              child: _buildBody(deviceType),
            ),
          ],
        ),

        // COMPACT:
        // BottomNavigationBar
        bottomNavigationBar:
            deviceType == DeviceType.compact
                ? NavigationBar(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: _onDestinationSelected,
                    destinations: _buildBottomDestinations(),
                  )
                : null,
      ),
    );
  }

  void _onDestinationSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  List<NavigationRailDestination> _buildRailDestinations() {
    return List.generate(
      destinations.length,
      (index) {
        return NavigationRailDestination(
          icon: Icon(destinationIcons[index]),
          label: Text(destinations[index]),
        );
      },
    );
  }

  List<NavigationDestination> _buildBottomDestinations() {
    return List.generate(
      destinations.length,
      (index) {
        return NavigationDestination(
          icon: Icon(destinationIcons[index]),
          label: destinations[index],
        );
      },
    );
  }

  Widget _buildBody(DeviceType deviceType) {
    switch (selectedIndex) {
      case 0:
        if (deviceType == DeviceType.expanded ||
            deviceType == DeviceType.large) {
          return const DesktopDashboardLayout();
        }

        return const DashboardContent();

      case 1:
        return const Center(
          child: Text(
            'Settings',
            style: TextStyle(fontSize: 28),
          ),
        );

      case 2:
        return const Center(
          child: Text(
            'About',
            style: TextStyle(fontSize: 28),
          ),
        );

      case 3:
        return const Center(
          child: Text(
            'Logout',
            style: TextStyle(fontSize: 28),
          ),
        );

      default:
        return const DashboardContent();
    }
  }
}

class DesktopDashboardLayout extends StatelessWidget {
  const DesktopDashboardLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Main dashboard content
        const Expanded(
          flex: 3,
          child: DashboardContent(),
        ),

        // Secondary desktop panel
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'Desktop\nSide Panel',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
        ),
      ],
    );
  }
}