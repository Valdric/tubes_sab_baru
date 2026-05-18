import 'package:flutter/material.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/shared/widgets/sidebar.dart';
import 'package:gosir/shared/widgets/mobile_bottom_nav.dart';
import 'package:gosir/core/services/api_service.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _staff = [];
  bool _isLoading = true;
  String _myRole = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/users', params: _searchQuery.isNotEmpty ? {'search': _searchQuery} : null);
      final me = await _api.get('/auth/me');
      if (mounted) {
        setState(() {
          _staff = res['data']['items'] ?? [];
          _myRole = me['data']['role'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteStaff(int id) async {
    try {
      await _api.delete('/users/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff berhasil dihapus'), backgroundColor: Colors.green),
        );
        _fetchData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showFormModal({Map<String, dynamic>? item}) {
    final nameController = TextEditingController(text: item?['name'] ?? '');
    final usernameController = TextEditingController(text: item?['username'] ?? '');
    final passwordController = TextEditingController();
    String selectedRole = item?['role'] ?? 'CASHIER';
    final bool isEdit = item != null;
    String? errorText;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEdit ? 'Ubah Data Staff' : 'Tambah Staff Baru', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameController,
                  decoration: _inputDecoration('Misal: Andi Wijaya'),
                ),
                const SizedBox(height: 16),
                const Text('Username', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: usernameController,
                  decoration: _inputDecoration('andi_wijaya'),
                  enabled: !isEdit,
                ),
                if (!isEdit) ...[
                  const SizedBox(height: 16),
                  const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: passwordController,
                    decoration: _inputDecoration('Min. 6 Karakter'),
                    obscureText: true,
                  ),
                ],
                const SizedBox(height: 16),
                const Text('Role', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: ['SUPERADMIN', 'ADMIN', 'CASHIER', 'KITCHEN']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) => setModalState(() => selectedRole = val!),
                  decoration: _inputDecoration(''),
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 8),
                  Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ]
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || usernameController.text.isEmpty) {
                  setModalState(() => errorText = 'Harap isi semua field');
                  return;
                }
                if (!isEdit && passwordController.text.length < 6) {
                  setModalState(() => errorText = 'Password minimal 6 karakter');
                  return;
                }

                try {
                  final data = {
                    'name': nameController.text.trim(),
                    'username': usernameController.text.trim(),
                    'role': selectedRole,
                  };
                  if (!isEdit) data['password'] = passwordController.text;

                  if (isEdit) {
                    await _api.put('/users/${item['id']}', data);
                  } else {
                    await _api.post('/users', data);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    _fetchData();
                  }
                } catch (e) {
                  setModalState(() => errorText = e.toString());
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF065F46), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;
    final bool isAdmin = _myRole.toUpperCase() == 'ADMIN' || _myRole.toUpperCase() == 'SUPERADMIN';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 6)) : null,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              title: const Text('Manajemen Staff', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              iconTheme: const IconThemeData(color: Colors.black),
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) const Sidebar(currentIndex: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Daftar Staff & Pegawai', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black)),
                            const SizedBox(height: 4),
                            const Text('Kelola hak akses dan informasi pegawai toko Anda.', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        if (isAdmin)
                          ElevatedButton.icon(
                            onPressed: () => _showFormModal(),
                            icon: const Icon(Icons.person_add_alt_1),
                            label: const Text('Tambah Pegawai'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF065F46), foregroundColor: Colors.white, minimumSize: const Size(200, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          ),
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : 16.0, vertical: 8.0),
                  child: TextField(
                    onChanged: (v) {
                      setState(() => _searchQuery = v);
                      _fetchData();
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari staff...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF065F46)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                          itemCount: _staff.length,
                          itemBuilder: (context, index) {
                            final item = _staff[index];
                            return _staffTile(item, isAdmin);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: null,
    );
  }

  Widget _staffTile(Map<String, dynamic> item, bool isAdmin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF065F46).withOpacity(0.1),
          child: Text(item['name']?[0].toUpperCase() ?? '?', style: const TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        title: Text(item['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('@${item['username']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(item['role'] ?? '-', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ],
        ),
        trailing: isAdmin
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showFormModal(item: item)),
                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _showDeleteConfirm(item)),
                ],
              )
            : null,
      ),
    );
  }

  void _showDeleteConfirm(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pegawai'),
        content: Text('Apakah Anda yakin ingin menghapus "${item['name']}"? User ini tidak akan bisa login lagi.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteStaff(item['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
