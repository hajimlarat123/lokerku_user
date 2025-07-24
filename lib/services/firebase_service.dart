import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final auth = FirebaseAuth.instance;
  final db = FirebaseDatabase.instance.ref();

  Future<void> loginAnonymously() async {
    await auth.signInAnonymously();
  }

  DatabaseReference getLokerRef() {
    return db.child("sewa");
  }

  Future<void> tulisSewaAktif({
    required String lokasiId,
    required String lokerId,
    required String userId,
    required int durasiJam,
    required String userNama,
    required String userEmail,
  }) async {
    final now = DateTime.now();
    final expiredAt = now.add(Duration(hours: durasiJam));

    final data = {
      'user_id': userId,
      'user_nama': userNama,
      'user_email': userEmail,
      'status': 'dipakai',
      'waktu_mulai': now.millisecondsSinceEpoch,
      'durasi_jam': durasiJam,
      'expired_at': expiredAt.millisecondsSinceEpoch,
    };

    await db.child('sewa_aktif/$lokasiId/$lokerId').set(data);
  }

  Future<void> tulisSewaHistory({
    required String lokasiId,
    required String lokerId,
    required String userId,
    required int durasiJam,
    required int hargaTotal,
    required String userNama,
    required String userEmail,
  }) async {
    final now = DateTime.now();
    final expiredAt = now.add(Duration(hours: durasiJam));

    final data = {
      'user_id': userId,
      'user_nama': userNama,
      'user_email': userEmail,
      'lokasi_id': lokasiId,
      'loker_id': lokerId,
      'waktu_mulai': now.millisecondsSinceEpoch,
      'expired_at': expiredAt.millisecondsSinceEpoch,
      'durasi_jam': durasiJam,
      'harga_total': hargaTotal,
    };

    await db.child('sewa_history').push().set(data); // Auto ID
  }

  Future<void> perpanjangMasaDenda({
    required String lokasiId,
    required String lokerId,
    required String userId,
    required int durasiMenit,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final newExpired = now + (durasiMenit * 60 * 1000);

    final db = FirebaseDatabase.instance;

    // ✅ Perpanjang waktu sewa
    await db.ref('sewa_aktif/$lokasiId/$lokerId/expired_at').set(newExpired);

    // ✅ Hapus aktivitas terakhir agar tidak terbaca sebagai "masukan_barang"
    await db.ref('perintah_buka/$lokasiId/$lokerId/aktivitas').remove();
  }
}
