import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EmergencyDialog extends StatefulWidget {
  @override
  _EmergencyDialogState createState() => _EmergencyDialogState();
}

class _EmergencyDialogState extends State<EmergencyDialog> {
  final baslikCtrl = TextEditingController();
  final aciklamaCtrl = TextEditingController();
  GeoPoint? konum;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text("Acil Duyuru Yayınla"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: baslikCtrl, decoration: InputDecoration(labelText: "Başlık")),
            SizedBox(height: 12),
            TextField(controller: aciklamaCtrl, maxLines: 3, decoration: InputDecoration(labelText: "Açıklama")),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _getCurrentLocation,
                    child: Text("Buradayım"),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickOnMap,
                    child: Text("Haritadan Seç"),
                  ),
                ),
              ],
            ),
            if (konum != null) Text("📍 Konum Hazır", style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("İptal")),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text("YAYINLA", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _getCurrentLocation() async {
    Position pos = await Geolocator.getCurrentPosition();
    setState(() => konum = GeoPoint(pos.latitude, pos.longitude));
  }

  Future<void> _pickOnMap() async {
    // Daha önce yazdığımız _pickLocationOnMap mantığını buraya taşıyabilirsin
    // Basitlik için sadece fonksiyon adını bıraktım
  }

  void _submit() async {
    if (baslikCtrl.text.isEmpty) return;
    await FirebaseFirestore.instance.collection('acil_duyurular').add({
      'baslik': baslikCtrl.text,
      'aciklama': aciklamaCtrl.text,
      'konum': konum,
      'tarih': FieldValue.serverTimestamp(),
    });
    Navigator.pop(context);
  }
}