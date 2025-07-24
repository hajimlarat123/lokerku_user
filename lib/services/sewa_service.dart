import 'package:firebase_database/firebase_database.dart';
import '../models/sewa_model.dart';

class SewaService {
  final _db = FirebaseDatabase.instance.ref();

  Future<SewaModel?> getSewaAktif(String userId, String lokerId) async {
    final snapshot = await _db
        .child('sewa_aktif')
        .orderByChild('userId')
        .equalTo(userId)
        .once();

    if (snapshot.snapshot.value != null) {
      Map data = snapshot.snapshot.value as Map;

      for (var entry in data.entries) {
        var value = Map<String, dynamic>.from(entry.value);
        if (value['lokerId'] == lokerId && value['status'] == 'aktif') {
          return SewaModel.fromMap(entry.key, value);
        }
      }
    }
    return null;
  }

  Future<void> bukaLoker(String lokasiId, String lokerId) async {
    await _db.child('kontrol_loker/$lokasiId/$lokerId').set({'buka': true});
  }
}
