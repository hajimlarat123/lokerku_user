class Sewa {
  final String id;
  final String userId;
  final String kodeLoker;
  final String status;
  final String startTime;
  final String endTime;

  Sewa({
    required this.id,
    required this.userId,
    required this.kodeLoker,
    required this.status,
    required this.startTime,
    required this.endTime,
  });

  factory Sewa.fromMap(Map<dynamic, dynamic> data, String id) {
    return Sewa(
      id: id,
      userId: data['user_id'],
      kodeLoker: data['kode_loker'],
      status: data['status'],
      startTime: data['start_time'],
      endTime: data['end_time'],
    );
  }
}
