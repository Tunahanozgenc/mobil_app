import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import 'bildirimler_screen.dart'; // Bildirim sayfası importu

class AnasayfaScreen extends StatefulWidget {
  @override
  _AnasayfaScreenState createState() => _AnasayfaScreenState();
}

class _AnasayfaScreenState extends State<AnasayfaScreen> {
  String _aramaMetni = "";
  String _secilenKategori = "Tümü";
  bool _sadeceAciklar = false;

  final List<String> _kategoriler = [
    "Tümü",
    "Sağlık",
    "Güvenlik",
    "Teknik",
    "Çevre",
    "Kayıp-Buluntu"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FD), // Premium arka plan rengi
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          // 1. MODERN SLIVERAPPBAR
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: EdgeInsetsDirectional.only(start: 20, bottom: 16),
              title: Text(
                "Kampüs Akışı",
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.notifications_active_outlined, color: Colors.black87),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BildirimlerScreen()),
                    );
                  },
                ),
              ),
            ],
          ),

          // 2. ÇOKLU ACİL DURUM KAYDIRICISI (Slider)
          _buildEmergencySlider(),

          // 3. ARAMA VE FİLTRELEME PANELİ
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  _buildSearchBar(),
                  _buildCategoryFilter(),
                  _buildStatusSwitch(),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),

          // 4. BİLDİRİM LİSTESİ
          _buildBildirimListesi(),

          SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom nav için boşluk
        ],
      ),
    );
  }

  // --- WIDGET FONKSİYONLARI ---

  Widget _buildEmergencySlider() {
    return SliverToBoxAdapter(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('acil_duyurular')
            .orderBy('tarih', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return SizedBox.shrink();
          var docs = snapshot.data!.docs;
          return Container(
            height: 160,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.9),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var doc = docs[index];
                var data = doc.data() as Map<String, dynamic>;
                return _buildEmergencyCard(data, doc, index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmergencyCard(Map<String, dynamic> data, DocumentSnapshot doc, int index) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/bildirim-detay', arguments: doc),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: index == 0
                ? [Color(0xFFFF416C), Color(0xFFFF4B2B)] // En yeni duyuru kırmızı
                : [Color(0xFFF2994A), Color(0xFFF2C94C)], // Diğerleri turuncu/sarı
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: (index == 0 ? Color(0xFFFF416C) : Color(0xFFF2994A)).withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 8)
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(Icons.campaign_rounded, color: Colors.white, size: 30),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "ACİL DURUM ${index + 1}",
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)
                  ),
                  Text(data['baslik'] ?? '', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18), maxLines: 1),
                  Text(data['aciklama'] ?? data['mesaj'] ?? '', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13), maxLines: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        onChanged: (v) => setState(() => _aramaMetni = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: "Kampüste neler oluyor?",
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
          filled: true,
          fillColor: Color(0xFFF5F7FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        itemCount: _kategoriler.length,
        itemBuilder: (context, i) {
          final kat = _kategoriler[i];
          final isSelected = _secilenKategori == kat;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: ChoiceChip(
              label: Text(kat),
              selected: isSelected,
              onSelected: (_) => setState(() => _secilenKategori = kat),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              ),
              backgroundColor: Colors.white,
              elevation: isSelected ? 4 : 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey[200]!),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusSwitch() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text("Sadece Aktif Olaylar", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600])),
          Spacer(),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: _sadeceAciklar,
              onChanged: (v) => setState(() => _sadeceAciklar = v),
              activeColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBildirimListesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bildirimler')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return SliverFillRemaining(child: _bosDurum("Huzurlu bir kampüs, bildirim yok."));

        var filtered = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          bool matchCat = _secilenKategori == "Tümü" || data['tur'] == _secilenKategori;
          bool matchSearch = data['baslik'].toString().toLowerCase().contains(_aramaMetni);
          bool matchStatus = !_sadeceAciklar || data['durum'] == 'Açık';
          return matchCat && matchSearch && matchStatus;
        }).toList();

        if (filtered.isEmpty) return SliverFillRemaining(child: _bosDurum("Sonuç bulunamadı."));

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildModernCard(filtered[i]),
              childCount: filtered.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String tur = data['tur'] ?? 'Genel';
    final String durum = data['durum'] ?? 'Açık';
    final Color color = _getCategoryColor(tur);
    final IconData icon = _getCategoryIcon(tur);

    return Container(
      margin: EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: Offset(0, 8))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/bildirim-detay', arguments: doc),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tur.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
                            Text(data['baslik'] ?? 'Başlık Yok', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
                          ],
                        ),
                      ),
                      _buildStatusBadge(durum),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    data['aciklama'] ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.access_time_filled_rounded, size: 14, color: Colors.grey[400]),
                      SizedBox(width: 5),
                      Text(
                        _formatDate(data['createdAt']),
                        style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      Spacer(),
                      Text("Detayları Gör", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                      Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String durum) {
    Color bColor;
    switch (durum) {
      case 'Açık': bColor = Colors.red; break;
      case 'İnceleniyor': bColor = Colors.orange; break;
      case 'Çözüldü': bColor = Colors.green; break;
      default: bColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(
        durum.toUpperCase(),
        style: TextStyle(color: bColor, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Widget _bosDurum(String mesaj) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(mesaj, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // --- YARDIMCI METODLAR ---

  Color _getCategoryColor(String tur) {
    switch (tur) {
      case 'Sağlık': return Color(0xFFFF5A5F);
      case 'Güvenlik': return Color(0xFF415EB6);
      case 'Teknik': return Color(0xFFFFB400);
      case 'Çevre': return Color(0xFF00A699);
      case 'Kayıp-Buluntu': return Color(0xFF8E44AD);
      default: return Colors.blueGrey;
    }
  }

  IconData _getCategoryIcon(String tur) {
    switch (tur) {
      case 'Sağlık': return Icons.local_hospital_rounded;
      case 'Güvenlik': return Icons.admin_panel_settings_rounded;
      case 'Teknik': return Icons.settings_suggest_rounded;
      case 'Çevre': return Icons.eco_rounded;
      case 'Kayıp-Buluntu': return Icons.person_search_rounded;
      default: return Icons.info_rounded;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "Şimdi";
    DateTime date = (timestamp as Timestamp).toDate();
    return "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}