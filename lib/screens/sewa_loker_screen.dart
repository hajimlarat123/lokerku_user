import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../screens/midtrans_webview_screen.dart';

class SewaLokerScreen extends StatelessWidget {
  final String snapToken;
  final String orderId;
  final int price;
  final String lokasiId;
  final String lokerId;
  final int durasi;
  final String userId;
  final bool isDenda;

  const SewaLokerScreen({
    Key? key,
    required this.snapToken,
    required this.orderId,
    required this.price,
    required this.lokasiId,
    required this.lokerId,
    required this.durasi,
    required this.userId,
    this.isDenda = false,
  }) : super(key: key);

  Future<void> _launchPayment(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? '-';
    final userNama = user?.displayName ?? '-';
    final firebaseService = FirebaseService();

    // Callback setelah pembayaran berhasil
    Future<void> handleAfterPayment(BuildContext context) async {
      try {
        if (isDenda) {
          await firebaseService.perpanjangMasaDenda(
            lokasiId: lokasiId,
            lokerId: lokerId,
            userId: userId,
            durasiMenit: 5,
          );
        } else {
          // Hanya tulis ke sewa_aktif, karena sewa_history ditulis oleh webhook
          await firebaseService.tulisSewaAktif(
            lokasiId: lokasiId,
            lokerId: lokerId,
            userId: userId,
            durasiJam: durasi,
            userNama: userNama,
            userEmail: userEmail,
          );
        }

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Pembayaran berhasil.')));
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        print('❌ Gagal handleAfterPayment: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
        }
      }
    }

    // Buka Midtrans Snap WebView
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MidtransWebViewScreen(
          snapToken: snapToken,
          onFinish: () => handleAfterPayment(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran Loker'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.payment, size: 64, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    'Order ID: $orderId',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Total Bayar: Rp $price',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchPayment(context),
                      icon: const Icon(Icons.open_in_browser),
                      label: Text(isDenda ? 'Bayar Denda' : 'Bayar Sekarang'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
