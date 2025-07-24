import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'pilih_loker_screen.dart';
import 'qr_scanner_screen.dart';
import 'notification_screen.dart'; // Tambahkan ini

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _bukaSewaLoker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Lokasi Loker',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3 / 2,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildLokasiCard(
                    context,
                    icon: Icons.directions_bus,
                    label: 'Terminal Arjosari',
                    lokasiId: 'lokasi01',
                  ),
                  _buildLokasiCard(
                    context,
                    icon: Icons.train,
                    label: 'Stasiun Malang Kota Baru',
                    lokasiId: 'lokasi02',
                  ),
                  _buildLokasiCard(
                    context,
                    icon: Icons.location_city,
                    label: 'Malang Town Square',
                    lokasiId: 'lokasi03',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLokasiCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String lokasiId,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PilihLokerScreen(lokasi: lokasiId)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade100),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _bukaQRScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Jenis Aktivitas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildQRModeCard(
                    context,
                    icon: Icons.login,
                    label: 'Masukan Barang',
                    mode: 'masukan_barang',
                  ),
                  _buildQRModeCard(
                    context,
                    icon: Icons.logout,
                    label: 'Ambil Barang',
                    mode: 'ambil_barang',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQRModeCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String mode,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => QRScannerScreen(mode: mode)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade100),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _bukaNotifikasi(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        centerTitle: true,
        leading: user != null
            ? Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Tooltip(
                  message: 'Akun Anda',
                  child: Center(
                    child: Text(
                      user.email ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset("assets/images/Logo.png", height: 80),
            const SizedBox(height: 20),
            const Text(
              "Selamat datang di Aplikasi Loker Otomatis!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.lock,
                    label: 'Sewa Loker',
                    onTap: () => _bukaSewaLoker(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.lock_open,
                    label: 'Loker Saya',
                    onTap: () => Navigator.pushNamed(context, '/loker-saya'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.qr_code,
                    label: 'Scan QR',
                    onTap: () => _bukaQRScanner(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.location_on,
                    label: 'Daftar Lokasi',
                    onTap: () => Navigator.pushNamed(context, '/lokasi_list'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications,
                    label: 'Notifikasi',
                    onTap: () => _bukaNotifikasi(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.logout,
                    label: 'Keluar',
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.blue),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
