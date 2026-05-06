import 'package:cliente_estacionamiento/features/home/presentation/home_screen.dart';
import 'package:cliente_estacionamiento/features/profile/presentation/profile_screen.dart';
import 'package:cliente_estacionamiento/features/reservation/presentation/reservation_principal_screen.dart';
import 'package:cliente_estacionamiento/features/ticket/presentation/ticket_principal_screen.dart';
import 'package:flutter/material.dart';
import '../../features/widgets/app_bottom_nav.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    ReservationScreen(),
    TicketScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}