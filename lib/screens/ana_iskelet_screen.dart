import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

// --- SAYFALAR ---
import 'home/anasayfa_screen.dart';
import 'discovery/harita_screen.dart';
import 'profile/profil_screen.dart';
import 'content/gonderi_ekle_screen.dart'; // Ekleme Sayfası

class AnaIskeletScreen extends StatefulWidget {
  @override
  _AnaIskeletScreenState createState() => _AnaIskeletScreenState();
}

class _AnaIskeletScreenState extends State<AnaIskeletScreen> {
  int _seciliIndex = 0; // Başlangıçta Ana Sayfa

  // Sayfaların Listesi (Artık 4 Elemanlı)
  final List<Widget> _sayfalar = [
    AnasayfaScreen(),     // 0
    HaritaScreen(),       // 1
    GonderiEkleScreen(),  // 2 (Artık burası da bir sekme)
    ProfilScreen(),       // 3
  ];

  // Tıklama Fonksiyonu (Düz Mantık)
  void _onItemTapped(int index) {
    setState(() {
      _seciliIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Seçili sayfayı ekrana bas
      body: _sayfalar[_seciliIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _seciliIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: false, // Temiz görünüm için kapalı kalsın

          items: [
            // 0. ANA SAYFA
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Ana Sayfa',
            ),

            // 1. HARİTA
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Harita',
            ),

            // 2. EKLE (ORTADA - TAB OLARAK)
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined, size: 28), // Normal İkon
              activeIcon: Icon(Icons.add_box, size: 28),    // Seçili İkon
              label: 'Ekle',
            ),

            // 3. PROFİL
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}