import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../utils/utils.dart';

class LokasiListScreen extends StatelessWidget {
  const LokasiListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseRef = FirebaseDatabase.instance.ref('sewa_aktif');

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Lokasi'), centerTitle: true),
      body: StreamBuilder<DatabaseEvent>(
        stream: databaseRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('Tidak ada data lokasi.'));
          }

          final data = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          final lokasiList = data.keys.toList();

          return ListView.builder(
            itemCount: lokasiList.length,
            itemBuilder: (context, index) {
              final lokasi = lokasiList[index];
              final lokerData = Map<String, dynamic>.from(data[lokasi]);

              int totalLoker = lokerData.length;
              int lokerTerisi = 0;
              int lokerKosong = 0;

              for (var loker in lokerData.values) {
                if (loker is Map && loker['user_id'] != null) {
                  lokerTerisi++;
                } else {
                  lokerKosong++;
                }
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  leading: const Icon(Icons.location_on, size: 32),
                  title: Text(
                    namaLokasi(lokasi),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Total Loker: $totalLoker\nTerisi: $lokerTerisi | Kosong: $lokerKosong',
                    style: const TextStyle(height: 1.5),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
