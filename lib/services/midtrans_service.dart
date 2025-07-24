import 'dart:convert';
import 'package:http/http.dart' as http;

class MidtransService {
  static Future<Map<String, dynamic>?> getSnapToken({
    required String userId,
    required String lokasi,
    required String loker,
    required int durationHours,
  }) async {
    final url = Uri.parse('https://midtrans-backend-1.onrender.com/snap-token');

    final shortUserId = userId.substring(0, 8);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final orderId = '$lokasi-$loker-$shortUserId-$timestamp';
    final grossAmount = durationHours * 5000;

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'lokasi': lokasi,
        'loker': loker,
        'user_id': userId,
        'durasi_jam': durationHours,
        'order_id': orderId,
        'gross_amount': grossAmount,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'snapToken': data['token'], 'orderId': data['order_id']};
    } else {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getDendaSnapToken({
    required String userId,
    required String lokasi,
    required String loker,
    required int dendaJam,
  }) async {
    final url = Uri.parse('https://midtrans-backend-1.onrender.com/snap-token');

    final shortUserId = userId.substring(0, 8);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final orderId = 'denda-$lokasi-$loker-$shortUserId-$timestamp';
    final grossAmount = dendaJam * 5000;

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'lokasi': lokasi,
        'loker': loker,
        'user_id': userId,
        'durasi_jam': dendaJam,
        'order_id': orderId,
        'gross_amount': grossAmount,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'snapToken': data['token'], 'orderId': data['order_id']};
    } else {
      return null;
    }
  }
}
