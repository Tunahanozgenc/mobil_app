import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/auth_service.dart';
import '../../core/constants/app_colors.dart';

class ProfilScreen extends StatefulWidget {
  @override
  _ProfilScreenState createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final AuthService _authService = AuthService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  void _cikisYap() async {
    await _authService.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/giris', (route) => false);
  }

  void _ayarDegistir(String ayarAdi, bool deger) async {
    if (_currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set({'ayarlar': {ayarAdi: deger}}, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(body: Center(child: Text("Oturum açılmamış")));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // MODERN SLIVER APPBAR
          SliverAppBar(
            expandedHeight: 60,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Profilim",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              background: Container(
                decoration: BoxDecoration(
                ),
              ),
            ),
            actions: [SizedBox(width: 56)],
          ),


          SliverToBoxAdapter(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return SizedBox(height: 300, child: Center(child: Text("Profil yüklenemedi")));
                }

                var userData = snapshot.data!.data() as Map<String, dynamic>;
                List<dynamic> takipEdilenler = userData['takipEdilenler'] ?? [];
                Map<String, dynamic> ayarlar = userData['ayarlar'] ?? {};

                return Column(
                  children: [
                    // PROFİL KARTI (Glassmorphism + Gradient)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: Offset(0, 10))
                        ],
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: (AppColors.primary ?? Colors.blue).withOpacity(0.15),
                            child: Text(
                              (userData['name'] ?? 'K')[0].toUpperCase(),
                              style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: AppColors.primary ?? Colors.blue),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            userData['name'] ?? 'İsimsiz Kullanıcı',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6),
                          Text(
                            userData['email'] ?? '',
                            style: TextStyle(color: Colors.grey[700], fontSize: 15),
                          ),
                          SizedBox(height: 16),
                          Chip(
                            avatar: Icon(Icons.school_rounded, color: Colors.orange[700], size: 20),
                            label: Text(
                              userData['birim'] ?? 'Birim Belirtilmemiş',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[900]),
                            ),
                            backgroundColor: Colors.orange[50],
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // BİLDİRİM TERCİHLERİ
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 26),
                          SizedBox(width: 12),
                          Text("Bildirim Tercihleri", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          _buildSwitchTile("Sağlık Bildirimleri", Icons.local_hospital_rounded, Colors.red, ayarlar['saglik'] ?? true, 'saglik'),
                          _divider(),
                          _buildSwitchTile("Güvenlik Bildirimleri", Icons.security_rounded, Colors.blue, ayarlar['guvenlik'] ?? true, 'guvenlik'),
                          _divider(),
                          _buildSwitchTile("Teknik Arıza", Icons.build_rounded, Colors.orange, ayarlar['teknik'] ?? true, 'teknik'),
                          _divider(),
                          _buildSwitchTile("Çevre Sorunları", Icons.park_rounded, Colors.green, ayarlar['cevre'] ?? true, 'cevre'),
                          _divider(),
                          _buildSwitchTile("Kayıp & Buluntu", Icons.search_rounded, Colors.purple, ayarlar['kayip'] ?? true, 'kayip'),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // TAKİP EDİLENLER
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(Icons.bookmark_rounded, color: AppColors.primary, size: 26),
                          SizedBox(width: 12),
                          Text("Takip Ettiklerim", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Spacer(),
                          Chip(
                            label: Text("${takipEdilenler.length}", style: TextStyle(fontWeight: FontWeight.bold)),
                            backgroundColor: (AppColors.primary ?? Colors.blue).withOpacity(0.15),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),

                    takipEdilenler.isEmpty
                        ? _bosTakipCard("Henüz hiçbir bildirimi takip etmiyorsun.")
                        : _buildTakipListesi(takipEdilenler),

                    SizedBox(height: 100),
                  ],
                );
              },
            ),
          ),
        ],
      ),

      // ÇIKIŞ FAB'I (sağ alt)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _cikisYap,
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        icon: Icon(Icons.logout_rounded),
        label: Text("Çıkış Yap"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSwitchTile(String title, IconData icon, Color color, bool value, String key) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color, size: 22)),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
      trailing: Switch(
        value: value,
        activeColor: color,
        onChanged: (val) => setState(() => _ayarDegistir(key, val)),
      ),
      onTap: () => setState(() => _ayarDegistir(key, !value)),
    );
  }

  Widget _divider() => Divider(height: 1, thickness: 0.5, indent: 72, color: Colors.grey[300]);

  Widget _buildTakipListesi(List<dynamic> takipIdleri) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bildirimler').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();

        var docs = snapshot.data!.docs.where((doc) => takipIdleri.contains(doc.id)).toList();
        if (docs.isEmpty) return _bosTakipCard("Takip edilen bildirimler silinmiş olabilir.");

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            var data = docs[i].data() as Map<String, dynamic>;
            var doc = docs[i];

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: _getTurColor(data['tur']).withOpacity(0.15),
                  child: Icon(_getTurIcon(data['tur']), color: _getTurColor(data['tur'])),
                ),
                title: Text(data['baslik'] ?? 'Başlık yok', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${data['tur']} • ${data['durum']}", style: TextStyle(color: Colors.grey[600])),
                trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                onTap: () => Navigator.pushNamed(context, '/bildirim-detay', arguments: doc),
              ),
            );
          },
        );
      },
    );
  }

  Widget _bosTakipCard(String mesaj) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.bookmark_border_rounded, size: 60, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(mesaj, style: TextStyle(fontSize: 16, color: Colors.grey[600]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // Renk ve ikonlar
  Color _getTurColor(String? tur) {
    switch (tur) {
      case 'Sağlık': return Colors.red.shade600;
      case 'Güvenlik': return Colors.blue.shade600;
      case 'Teknik': return Colors.orange.shade600;
      case 'Çevre': return Colors.green.shade600;
      case 'Kayıp-Buluntu': return Colors.purple.shade600;
      default: return Colors.grey.shade600;
    }
  }

  IconData _getTurIcon(String? tur) {
    switch (tur) {
      case 'Sağlık': return Icons.local_hospital_rounded;
      case 'Güvenlik': return Icons.security_rounded;
      case 'Teknik': return Icons.build_rounded;
      case 'Çevre': return Icons.park_rounded;
      case 'Kayıp-Buluntu': return Icons.search_rounded;
      default: return Icons.info_rounded;
    }
  }
}