import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/sewa_loker_screen.dart';
import '../services/midtrans_service.dart';
import '../utils/utils.dart';
import '../utils/notification_helper.dart';
import 'package:intl/intl.dart';

class PilihLokerScreen extends StatefulWidget {
  final String lokasi;
  const PilihLokerScreen({Key? key, required this.lokasi}) : super(key: key);

  @override
  State<PilihLokerScreen> createState() => _PilihLokerScreenState();
}

class _PilihLokerScreenState extends State<PilihLokerScreen> {
  final database = FirebaseDatabase.instance;
  String selectedDuration = '1';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Loker - ${namaLokasi(widget.lokasi)}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text(
                  "Durasi Sewa:",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedDuration,
                    isExpanded: true,
                    items: ['1', '2', '3', '4']
                        .map(
                          (val) => DropdownMenuItem(
                            value: val,
                            child: Text('$val Jam'),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() => selectedDuration = val!);
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isLoading) const CircularProgressIndicator(),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: database.ref('sewa_aktif/${widget.lokasi}').onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Gagal mengambil data'));
                }

                final data = snapshot.data?.snapshot.value;
                if (data == null || data is! Map) {
                  return const Center(child: Text('Tidak ada loker tersedia.'));
                }

                final lokerMap = Map<String, dynamic>.from(data);

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: lokerMap.entries.map((entry) {
                    final lokerId = entry.key;
                    final info = Map<String, dynamic>.from(entry.value);
                    final status = info['status'];
                    final isKosong = status == 'kosong';

                    String? countdown;
                    if (!isKosong && info.containsKey('expired_at')) {
                      final expiredAt = int.tryParse(
                        info['expired_at'].toString(),
                      );
                      if (expiredAt != null) {
                        final now = DateTime.now().millisecondsSinceEpoch;
                        final diffMs = expiredAt - now;
                        if (diffMs > 0) {
                          final minutes = (diffMs / 60000).ceil();
                          final expiredTime = DateFormat('HH:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(expiredAt),
                          );
                          countdown =
                              '$minutes menit tersisa (sampai $expiredTime)';
                        } else {
                          countdown = 'Kadaluarsa';
                        }
                      }
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          namaLoker(lokerId),
                        ), // Ganti dari 'Loker $lokerId'
                        subtitle: Text(
                          isKosong
                              ? 'Status: Kosong'
                              : 'Status: Terisi${countdown != null ? ' - $countdown' : ''}',
                        ),
                        trailing: isKosong
                            ? ElevatedButton(
                                onPressed: () => _handleSewa(lokerId),
                                child: const Text('Sewa'),
                              )
                            : const Icon(Icons.lock, color: Colors.grey),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSewa(String lokerId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login terlebih dahulu.')),
      );
      return;
    }

    final userId = user.uid;
    final duration = int.tryParse(selectedDuration) ?? 1;
    final totalHarga = duration * 5000;

    setState(() => isLoading = true);

    try {
      final result = await MidtransService.getSnapToken(
        userId: userId,
        lokasi: widget.lokasi,
        loker: lokerId,
        durationHours: duration,
      );

      setState(() => isLoading = false);

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mendapatkan Snap Token')),
        );
        return;
      }

      final snapToken = result['snapToken'];
      final orderId = result['orderId'];

      // Hitung expiredAt (waktu sekarang + durasi)
      final now = DateTime.now();
      final expiredAt = now
          .add(Duration(hours: duration))
          .millisecondsSinceEpoch;

      // Jadwalkan notifikasi 10 menit sebelum sewa habis
      await NotificationHelper().scheduleSewaReminder(
        lokerId: lokerId,
        expiredAt: expiredAt,
        userId: userId,
      );

      // Buka halaman pembayaran
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SewaLokerScreen(
            snapToken: snapToken,
            orderId: orderId,
            price: totalHarga,
            lokasiId: widget.lokasi,
            lokerId: lokerId,
            durasi: duration,
            userId: userId,
          ),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }
}
