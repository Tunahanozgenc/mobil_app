import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/screens/content/bildirim_detay_screen.dart';

// --- EKRANLAR ---
import 'screens/admin/admin_screen.dart';
import 'screens/auth/giris_screen.dart';
import 'screens/auth/kayit_ol_screen.dart';
import 'screens/auth/sifremi_unuttum_screen.dart';
import 'screens/ana_iskelet_screen.dart';
import 'screens/profile/profil_screen.dart';
import 'screens/content/gonderi_ekle_screen.dart';
// 👇 YENİ EKLENEN IMPORT (Detay Sayfası için)

// --- TEMALAR & SERVİSLER ---
import 'core/theme/app_theme.dart';
import 'core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stumedia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // AuthWrapper: Uygulama açılışında kontrol noktası
      home: AuthWrapper(),

      // ROTALAR
      routes: {
        '/giris': (context) => GirisScreen(),
        '/kayit': (context) => KayitOlScreen(),
        '/sifremi-unuttum': (context) => SifremiUnuttumScreen(),
        '/anasayfa': (context) => AnaIskeletScreen(),
        '/profil': (context) => ProfilScreen(),
        '/kitap-baslangic': (context) => GonderiEkleScreen(),
        '/admin': (context) => AdminScreen(),

        // 👇 YENİ EKLENEN ROTA (Haritadan buraya yönlenecek)
        '/bildirim-detay': (context) => BildirimDetayScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 1. ADIM: Firebase Auth durumunu dinle
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {

        // Bağlantı bekleniyorsa
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // KULLANICI GİRİŞ YAPMIŞSA
        if (snapshot.hasData && snapshot.data != null) {
          User loggedInUser = snapshot.data!;

          // 2. ADIM: ROL KONTROLÜ
          return FutureBuilder<String>(
            future: AuthService().getUserRole(loggedInUser),
            builder: (context, roleSnapshot) {

              // Rol verisi beklenirken
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              // Rol verisi geldiyse
              if (roleSnapshot.hasData) {
                String role = roleSnapshot.data!;

                if (role == 'admin') {
                  return AdminScreen();
                } else {
                  return AnaIskeletScreen();
                }
              }

              // Hata/Belirsizlik durumunda Ana Sayfa
              return AnaIskeletScreen();
            },
          );
        }

        // GİRİŞ YAPMAMIŞSA -> Giriş Ekranı
        return GirisScreen();
      },
    );
  }
}