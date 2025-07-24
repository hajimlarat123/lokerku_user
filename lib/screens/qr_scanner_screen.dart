import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  final String mode; // 'masukan_barang' atau 'ambil_barang'
  const QRScannerScreen({super.key, required this.mode});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String? lokasi;
  String? loker;
  String? statusMessage;
  bool isValid = false;
  bool isChecking = false;

  final userId = FirebaseAuth.instance.currentUser?.uid;

  void _handleBarcode(String code) async {
    if (isChecking || isValid) return;

    setState(() {
      isChecking = true;
      statusMessage = 'Mengecek data sewa...';
    });

    try {
      final parts = code.split('-');
      if (parts.length != 2) throw Exception('Format QR tidak valid');

      final lokasiScanned = parts[0];
      final lokerScanned = parts[1];

      final ref = FirebaseDatabase.instance.ref(
        'sewa_aktif/$lokasiScanned/$lokerScanned',
      );

      final snapshot = await ref.get();
      final data = snapshot.value as Map?;

      if (data == null) {
        setState(() {
          statusMessage = 'Loker belum disewa.';
        });
      } else if (data['user_id'] == userId) {
        final expiredAt = data['expired_at'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;

        if (now > expiredAt) {
          setState(() {
            statusMessage = 'Waktu sewa sudah habis.';
          });
        } else {
          setState(() {
            lokasi = lokasiScanned;
            loker = lokerScanned;
            isValid = true;
            statusMessage = 'Loker cocok! Silakan buka.';
          });
        }
      } else {
        setState(() {
          statusMessage = 'Kamu bukan penyewa loker ini.';
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = 'QR tidak valid.';
      });
    } finally {
      setState(() {
        isChecking = false;
      });
    }
  }

  void _bukaLoker() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final path = 'perintah_buka/$lokasi/$loker';

    await FirebaseDatabase.instance.ref(path).set({
      'perintah': true,
      'timestamp': now,
      'user_id': userId,
      'aktivitas': widget.mode,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perintah buka loker dikirim')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Loker')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (BarcodeCapture capture) {
              final barcode = capture.barcodes.first;
              if (barcode.rawValue != null) {
                _handleBarcode(barcode.rawValue!);
              }
            },
          ),
          if (statusMessage != null || isValid)
            Positioned(
              bottom: 60,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Text(
                    statusMessage ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  if (isValid)
                    ElevatedButton(
                      onPressed: _bukaLoker,
                      child: const Text('Buka Loker'),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
