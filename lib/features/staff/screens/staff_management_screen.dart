import 'package:flutter/material.dart';
import 'package:tubes_ppm_sab/core/theme/app_colors.dart';
import 'package:tubes_ppm_sab/shared/widgets/sidebar.dart';
import 'package:tubes_ppm_sab/core/services/api_service.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _staffMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.get('/users');
      if (mounted) {
        setState(() {
          if (response is List) {
            _staffMembers = response;
          } else if (response is Map && response['data'] != null) {
            _staffMembers = response['data'] is List ? response['data'] : (response['data']['items'] ?? []);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load staff: $e')));
      }
    }
  }

  Future<void> _deleteStaff(String id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this staff member?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _api.delete('/users/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Staff member deleted!')));
        _fetchStaff();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  void _showForm([Map<String, dynamic>? staff]) {
    final nameController = TextEditingController(text: staff?['name'] ?? '');
    final usernameController = TextEditingController(text: staff?['username'] ?? '');
    final passwordController = TextEditingController();
    String selectedRole = staff?['role'] ?? 'ADMIN';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(staff == null ? 'Add Staff' : 'Edit Staff'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Full Name')),
                const SizedBox(height: 8),
                TextField(controller: usernameController, decoration: const InputDecoration(hintText: 'Username')),
                const SizedBox(height: 8),
                if (staff == null)
                  TextField(controller: passwordController, decoration: const InputDecoration(hintText: 'Password'), obscureText: true),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: ['SUPERADMIN', 'ADMIN']
                      .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedRole = val!),
                  decoration: const InputDecoration(hintText: 'Role'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || usernameController.text.isEmpty) return;
                if (staff == null && passwordController.text.isEmpty) return;
                
                Navigator.pop(context);
                setState(() => _isLoading = true);
                try {
                  final data = {
                    'name': nameController.text.trim(),
                    'username': usernameController.text.trim(),
                    'role': selectedRole,
                  };
                  if (staff == null) {
                    data['password'] = passwordController.text;
                    await _api.post('/users', data);
                  } else {
                    await _api.put('/users/${staff['id']}', data);
                  }
                  _fetchStaff();
                } catch (e) {
                  if (mounted) {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Operation failed: $e')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      drawer: !isDesktop ? const Drawer(child: Sidebar(currentIndex: 7)) : null,
      appBar: isDesktop ? null : AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Staff', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Builder(builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.onSurfaceVariant),
          onPressed: () => Scaffold.of(context).openDrawer(),
        )),
      ),
      body: Row(
        children: [
          if (isDesktop) const Sidebar(currentIndex: 7),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _staffMembers.isEmpty
                    ? const Center(child: Text('No staff found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: _staffMembers.length,
                        itemBuilder: (context, index) {
                          final staff = _staffMembers[index];
                          return _staffTile(staff);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add, color: AppColors.onPrimary),
      ),
    );
  }

  Widget _staffTile(Map<String, dynamic> staff) {
    final String name = staff['name'] ?? 'Unknown';
    final String role = staff['role'] ?? 'Staff';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryContainer,
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(role, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
            onPressed: () => _showForm(staff),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            onPressed: () => _deleteStaff(staff['id'].toString()),
          ),
        ],
      ),
    );
  }
}
