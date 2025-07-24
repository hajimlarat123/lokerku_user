import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  String formatTime(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd MMM yyyy HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('User belum login.')));
    }

    final ref = FirebaseDatabase.instance.ref('notifikasi/${user.uid}');

    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi Anda")),
      body: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Belum ada notifikasi."));
          }

          final data = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          final notifs = data.entries.toList()
            ..sort((a, b) {
              final aTime = a.value['timestamp'] ?? 0;
              final bTime = b.value['timestamp'] ?? 0;
              return bTime.compareTo(aTime);
            });

          return ListView.builder(
            itemCount: notifs.length,
            itemBuilder: (context, index) {
              final item = Map<String, dynamic>.from(notifs[index].value);
              return ListTile(
                leading: const Icon(Icons.notifications_active),
                title: Text(item['title'] ?? 'Tanpa Judul'),
                subtitle: Text(
                  '${item['body'] ?? ''}\n${formatTime(item['timestamp'] ?? 0)}',
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
