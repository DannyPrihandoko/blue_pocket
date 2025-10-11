import 'package:flutter/material.dart';
import 'package:blue_pocket/presentation/screens/category_screen.dart';
import 'package:blue_pocket/presentation/screens/log_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blue_pocket/logic/bloc/log/log_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            _buildProfileInfo('Nama', 'John Doe'),
            const Divider(),
            _buildProfileInfo('Email', 'john.doe@example.com'),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.category, color: Colors.blueAccent),
              title: const Text('Kelola Kategori'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoryScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.article, color: Colors.orangeAccent),
              title: const Text('Log Aktivitas'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.read<LogBloc>().add(LoadLogs()); 
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LogScreen()),
                );
              },
            ),
            const Divider(),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Edit Profil'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}