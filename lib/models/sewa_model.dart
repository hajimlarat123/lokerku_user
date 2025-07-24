class SewaModel {
  final String id;
  final String lokasiId;
  final String lokerId;
  final String userId;
  final String status;
  final int startTime;
  final int endTime;

  SewaModel({
    required this.id,
    required this.lokasiId,
    required this.lokerId,
    required this.userId,
    required this.status,
    required this.startTime,
    required this.endTime,
  });

  factory SewaModel.fromMap(String id, Map<String, dynamic> data) {
    return SewaModel(
      id: id,
      lokasiId: data['lokasiId'],
      lokerId: data['lokerId'],
      userId: data['userId'],
      status: data['status'],
      startTime: data['startTime'],
      endTime: data['endTime'],
    );
  }

  Map<String, dynamic> toJson() => {
    'lokasi_id': lokasiId,
    'loker_id': lokerId,
    'user_id': userId,
    'status': status,
    'waktu_mulai': startTime,
    'expired_at': endTime,
  };
}
