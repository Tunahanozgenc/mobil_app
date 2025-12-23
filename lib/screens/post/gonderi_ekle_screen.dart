import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_colors.dart';

class GonderiEkleScreen extends StatefulWidget {
  @override
  _GonderiEkleScreenState createState() => _GonderiEkleScreenState();
}

class _GonderiEkleScreenState extends State<GonderiEkleScreen> {
  // Form Kontrolcüleri
  final TextEditingController _baslikController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();

  // Seçilen Değerler
  String _secilenTur = 'Genel';
  GeoPoint? _secilenKonum; // Enlem-Boylam verisi
  bool _isLoading = false;

  // Tür Listesi
  final List<String> _turler = ['Sağlık', 'Güvenlik', 'Teknik', 'Çevre', 'Kayıp-Buluntu', 'Genel'];

  // --- 1. MEVCUT KONUMU AL ---
  Future<void> _mevcutKonumuAl() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          _secilenKonum = GeoPoint(position.latitude, position.longitude);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Konum başarıyla alındı!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Konum izni verilmedi.")));
      }
    } catch (e) {
      print("Konum hatası: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- 2. HARİTADAN SEÇ ---
  void _haritadanSec() async {
    // Harita sayfasına git ve sonucu bekle
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HaritaSecimScreen()),
    );

    if (result != null) {
      setState(() {
        _secilenKonum = GeoPoint(result.latitude, result.longitude);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Haritadan konum seçildi.")));
    }
  }

  // --- 3. GÖNDERİYİ KAYDET ---
  void _gonderiyiPaylas() async {
    // Validasyonlar
    if (_baslikController.text.isEmpty) {
      _hataGoster("Lütfen bir başlık girin.");
      return;
    }
    if (_aciklamaController.text.isEmpty) {
      _hataGoster("Lütfen açıklama yazın.");
      return;
    }
    if (_secilenKonum == null) {
      _hataGoster("Lütfen konum seçin (GPS veya Harita).");
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;

      // Firestore'a Kayıt
      await FirebaseFirestore.instance.collection('bildirimler').add({
        'baslik': _baslikController.text.trim(),
        'aciklama': _aciklamaController.text.trim(),
        'tur': _secilenTur,
        'konum': _secilenKonum, // GeoPoint formatında
        'durum': 'Açık', // Varsayılan durum
        'userId': user?.uid,
        'userEmail': user?.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Başarılı
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text("Bildirim başarıyla oluşturuldu!")));

      // Formu temizle
      _baslikController.clear();
      _aciklamaController.clear();
      setState(() {
        _secilenKonum = null;
        _secilenTur = 'Genel';
        _isLoading = false;
      });

      // Kullanıcıyı Ana Sayfaya veya Profiline yönlendirebilirsin (Opsiyonel)
      // Navigator.pop(context);

    } catch (e) {
      setState(() => _isLoading = false);
      _hataGoster("Bir hata oluştu: $e");
    }
  }

  void _hataGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(mesaj)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Yeni Bildirim", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _gonderiyiPaylas,
            child: _isLoading
                ? CircularProgressIndicator(strokeWidth: 2)
                : Text("PAYLAŞ", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text("Bildirim Türü", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _secilenTur,
                  isExpanded: true,
                  items: _turler.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          _getTurIcon(value),
                          SizedBox(width: 10),
                          Text(value),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _secilenTur = newValue!;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),

            TextField(
              controller: _baslikController,
              decoration: InputDecoration(
                labelText: "Başlık",
                hintText: "Örn: Kütüphane önü buzlanma",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            SizedBox(height: 16),

            TextField(
              controller: _aciklamaController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Açıklama",
                hintText: "Olayı detaylıca anlatın...",
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            SizedBox(height: 20),

            Text("Konum Bilgisi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _mevcutKonumuAl,
                    icon: Icon(Icons.my_location),
                    label: Text("Mevcut Konum"),
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _haritadanSec,
                    icon: Icon(Icons.map),
                    label: Text("Haritadan Seç"),
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),

            if (_secilenKonum != null)
              Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Expanded(child: Text("Konum alındı: ${_secilenKonum!.latitude.toStringAsFixed(4)}, ${_secilenKonum!.longitude.toStringAsFixed(4)}")),
                    IconButton(
                      icon: Icon(Icons.close, size: 18, color: Colors.grey),
                      onPressed: () => setState(() => _secilenKonum = null),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // İkon Yardımcısı
  Widget _getTurIcon(String tur) {
    switch (tur) {
      case 'Sağlık': return Icon(Icons.local_hospital, color: Colors.red, size: 20);
      case 'Güvenlik': return Icon(Icons.security, color: Colors.blue, size: 20);
      case 'Teknik': return Icon(Icons.build, color: Colors.orange, size: 20);
      case 'Çevre': return Icon(Icons.park, color: Colors.green, size: 20);
      default: return Icon(Icons.info, color: Colors.grey, size: 20);
    }
  }
}

// --- EKSTRA: HARİTADAN SEÇİM EKRANI ---
// Kullanıcı "Haritadan Seç" dediğinde burası açılır
class HaritaSecimScreen extends StatefulWidget {
  @override
  _HaritaSecimScreenState createState() => _HaritaSecimScreenState();
}

class _HaritaSecimScreenState extends State<HaritaSecimScreen> {
  LatLng _pickedLocation = LatLng(39.9035, 41.2658); // Erzurum Merkez (Varsayılan)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Konumu İşaretle"), actions: [
        IconButton(
          icon: Icon(Icons.check),
          onPressed: () {
            Navigator.pop(context, _pickedLocation); // Seçilen konumu geri gönder
          },
        )
      ]),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _pickedLocation, zoom: 14),
        onTap: (LatLng pos) {
          setState(() {
            _pickedLocation = pos;
          });
        },
        markers: {
          Marker(
            markerId: MarkerId('secilen'),
            position: _pickedLocation,
          ),
        },
      ),
    );
  }
}