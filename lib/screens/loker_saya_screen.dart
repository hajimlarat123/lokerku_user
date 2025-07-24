import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/midtrans_service.dart';
import '../screens/sewa_loker_screen.dart';
import 'package:lokerbarufiks/utils/utils.dart';

class LokerSayaScreen extends StatelessWidget {
  const LokerSayaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    final ref = FirebaseDatabase.instance.ref('sewa_aktif');

    if (userId == null) {
      return const Scaffold(body: Center(child: Text("Anda belum login.")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Loker Saya')),
      body: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: Text('Tidak ada loker aktif.'));
          }

          final Map data = snapshot.data!.snapshot.value as Map;
          final List<Map<String, dynamic>> userLockers = [];

          data.forEach((lokasiId, lokers) {
            final lokerMap = Map<String, dynamic>.from(lokers);
            lokerMap.forEach((lokerId, detail) {
              final info = Map<String, dynamic>.from(detail);
              if (info['user_id'] == userId &&
                  lokasiId != 'denda' &&
                  lokerId != 'denda') {
                info['lokasi_id'] = lokasiId;
                info['loker_id'] = lokerId;
                userLockers.add(info);
              }
            });
          });

          if (userLockers.isEmpty) {
            return const Center(child: Text("Tidak ada loker yang Anda sewa."));
          }

          return ListView.builder(
            itemCount: userLockers.length,
            itemBuilder: (context, index) {
              final item = userLockers[index];
              final expiredAt =
                  int.tryParse(item['expired_at'].toString()) ?? 0;
              final expiredTime = DateTime.fromMillisecondsSinceEpoch(
                expiredAt,
              );
              final waktuKadaluarsa = DateFormat(
                'dd MMM yyyy, HH:mm',
              ).format(expiredTime);

              final now = DateTime.now();
              final remainingDuration = expiredTime.difference(now);
              final minutesLeft = remainingDuration.inMinutes;

              final lokasiId = item['lokasi_id'];
              final lokerId = item['loker_id'];

              // 🎨 Tentukan warna kartu
              Color cardColor;
              if (minutesLeft <= 0) {
                cardColor = Colors.red.shade100;
              } else if (minutesLeft <= 30) {
                cardColor = Colors.yellow.shade100;
              } else {
                cardColor = Colors.white;
              }

              final isExpired = minutesLeft <= 0;

              return FutureBuilder<DataSnapshot>(
                future: FirebaseDatabase.instance
                    .ref('perintah_buka/$lokasiId/$lokerId')
                    .get(),
                builder: (context, perintahSnapshot) {
                  String? lastAktivitas;
                  if (perintahSnapshot.hasData &&
                      perintahSnapshot.data!.exists) {
                    final data = perintahSnapshot.data!.value as Map;
                    lastAktivitas = data['aktivitas']?.toString();
                  }

                  final bool needsDenda =
                      isExpired && lastAktivitas == 'masukan_barang';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    color: cardColor,
                    child: ListTile(
                      title: Text(
                        '${namaLoker(lokerId)} - ${namaLokasi(lokasiId)}',
                      ),
                      subtitle: Text('Kadaluarsa: $waktuKadaluarsa'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: needsDenda
                              ? Colors.orange
                              : Colors.blue,
                        ),
                        onPressed: () async {
                          const durasiJam = 1;
                          const hargaPerJam = 5000;
                          final totalHarga = hargaPerJam * durasiJam;

                          final snapResult = needsDenda
                              ? await MidtransService.getDendaSnapToken(
                                  userId: userId,
                                  lokasi: lokasiId,
                                  loker: lokerId,
                                  dendaJam: durasiJam,
                                )
                              : await MidtransService.getSnapToken(
                                  userId: userId,
                                  lokasi: lokasiId,
                                  loker: lokerId,
                                  durationHours: durasiJam,
                                );

                          if (snapResult == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gagal mendapatkan Snap Token'),
                              ),
                            );
                            return;
                          }

                          final snapToken = snapResult['snapToken'];
                          final orderId = snapResult['orderId'];

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SewaLokerScreen(
                                snapToken: snapToken,
                                orderId: orderId,
                                price: totalHarga,
                                lokasiId: lokasiId,
                                lokerId: lokerId,
                                durasi: durasiJam,
                                userId: userId,
                                isDenda: needsDenda,
                              ),
                            ),
                          );
                        },
                        child: Text(needsDenda ? 'Bayar Denda' : 'Perpanjang'),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
