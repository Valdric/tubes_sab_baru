import 'package:flutter/material.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/shared/widgets/sidebar.dart';
import 'package:gosir/core/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic> _profile = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/profile');
      if (mounted) {
        setState(() {
          _profile = res['data'] ?? {};
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.destructive),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: -1)) : null,
      appBar: isDesktop ? null : AppBar(title: const Text('Profil Saya')),
      body: Row(
        children: [
          if (isDesktop) const Sidebar(currentIndex: -1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Profil Saya', style: Theme.of(context).textTheme.displayMedium),
                        const Text('Kelola informasi akun Anda.', style: TextStyle(color: AppColors.mutedForeground)),
                        const SizedBox(height: 32),
                        _buildInfoCard(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _infoRow('Nama Lengkap', _profile['name'] ?? '-'),
          const Divider(),
          _infoRow('Username', _profile['username'] ?? '-'),
          const Divider(),
          _infoRow('Role / Akses', _profile['role'] ?? '-'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Update Profile Implementation
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(200, 45)),
            child: const Text('Ubah Profil'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.mutedForeground)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
