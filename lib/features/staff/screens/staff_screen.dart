import 'package:flutter/material.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/shared/widgets/sidebar.dart';
import 'package:gosir/core/services/api_service.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/users');
      if (mounted) {
        setState(() {
          _items = res['data']['items'] ?? [];
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
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 6)) : null,
      appBar: isDesktop ? null : AppBar(title: const Text('Manajemen Staff')),
      body: Row(
        children: [
          if (isDesktop) const Sidebar(currentIndex: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Staff Pegawai', style: Theme.of(context).textTheme.displayMedium),
                            const Text('Kelola akun akses pegawai Kopitiam Arunika.',
                                style: TextStyle(color: AppColors.mutedForeground)),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Create User Modal
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text('Tambah Staff'),
                          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 45)),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: EdgeInsets.all(isDesktop ? 24 : 16),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return _staffCard(item);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _staffCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
        title: Text(item['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${item['username']} • ${item['role']}'),
        trailing: PopupMenuButton<String>(
          onSelected: (val) {
            // TODO: Actions
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Ubah')),
            const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: AppColors.destructive))),
          ],
        ),
      ),
    );
  }
}
