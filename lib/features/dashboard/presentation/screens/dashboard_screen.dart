import 'package:flutter/material.dart';

import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../calendar/presentation/screens/calendar_screen.dart';
import '../../../shop/presentation/screens/shop_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [const CalendarScreen(), const ShopScreen(), const AnalyticsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0x14000000),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Icon(Icons.calendar_month_rounded)),
                  label: 'Schedule',
                ),
                BottomNavigationBarItem(
                  icon: Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Icon(Icons.storefront_rounded)),
                  label: 'Store',
                ),
                BottomNavigationBarItem(
                  icon: Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Icon(Icons.analytics_rounded)),
                  label: 'Metrics',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
